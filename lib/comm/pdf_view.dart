import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart';
import 'dart:io'; // 引入 dart:io 来判断平台
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:gongke/comm/pdfium_api_tools.dart';
import 'package:gongke/comm/thumbnail_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gongke/providers/pdf_provider.dart';
import 'package:gongke/comm/tts_tools.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:gongke/comm/shared_preferences.dart';
import 'package:gongke/comm/audio_tools.dart';

class PdfViewerPage extends ConsumerStatefulWidget {
  final JingShuData jingshu; //jingshu对象

  const PdfViewerPage({super.key, required this.jingshu});

  @override
  ConsumerState<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends ConsumerState<PdfViewerPage> {
  List<PageCache> _pageCaches = []; // 缓存的页码列表，包含缩略图和文本，已经生成的page的image也缓存在这里
  final Map<int, Future<List<Uint8List>>> _doublePageFutures = {};
  String _bookName = ''; //经书或善书名称
  PdfDocument? _document;
  PdfDocument? _document2; //这个变量用于getpage，不能和_document混用，否则报错
  PdfController? _pdfController; //这是pdfx的controller
  String? _errorMessage; //报错的信息
  PageController? _pageController; //这是双页显示的controller

  int _pages = 0; //文档总页码
  int _currentIndex = 0; //当前读到的双页分组序号
  int _page = 1; //记录单页模式下的页码
  bool _isDoublePage = false; //是否双页模式

  // 全局管理焦点节点
  final FocusNode focusNode = FocusNode();

  //当前页码，即当前阅读到的页码
  late int _curPage = 1; //初始值为1

  //模式显示缩略图
  bool _showThumbnailFlag = true;

  //是否显示木鱼背景音乐
  bool _showMuyuFlag = false;
  bool _muyuIsPlaying = false; //木鱼是否正在播放

  //pdfdoc
  late PDFDoc pdfdoc;
  late WinPDFDoc windoc;
  //tts工具类
  TtsTools ttstools = TtsTools(); // TTS工具类实例
  bool isOnGonging = false; //是否正在播放声音

  // 根据条件得出当前是否显示双页，true需要显示双页
  bool _getIsDoubleFlag() {
    bool result = false; // 默认显示单页

    // 获取当前屏幕方向
    final orientation = MediaQuery.of(context).orientation;
    // 根据屏幕方向设置双页模式标志
    if (Platform.isWindows || Platform.isAndroid || Platform.isIOS) {
      // Android 和 iOS 平台根据屏幕宽度判断
      final screenWidth = MediaQuery.of(context).size.width;
      //print('当前屏幕宽度: $screenWidth');
      if (screenWidth > 600 && orientation == Orientation.landscape) {
        // 如果屏幕宽度大于600，显示双页
        result = true;
      } else {
        // 否则显示单页
        result = false;
      }
    } else {
      // 其他平台默认显示单页
      result = false;
    }
    return result;
  }

  final ValueNotifier<Object?> _taskDataListenable = ValueNotifier(null);
  void _onReceiveTaskData(Object data) {
    //print('--------------------------接收到数据: $data');
    _taskDataListenable.value = data;
    if (data is Map && data['buttonPressed'] == 'btn_stop') {
      ttstools.stop(); // 页面中你的 TTS 停止方法
      setState(() {
        isOnGonging = false;
      });
    } else if (data is Map && data['buttonPressed'] == 'btn_start') {
      // 开始播放的代码
      _listenText(_page);
      setState(() {
        isOnGonging = true;
      });
    }
  }

  Future<void> setPhoneWakeLock(bool isEnable) async {
    final flag = await getBoolValue('allow_wakelock_flag') ?? false; //是否允许防止息屏
    if (flag) {
      if (isEnable) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    //print('----------------------initState 开始');
    _doublePageFutures.clear();
    _pageCaches.clear();
    _bookName = widget.jingshu.name;

    Future<void> initAsync() async {
      //print('----------------------initState 初始化_pageController');
      if (widget.jingshu.type.contains('shanshu')) {
        await _getCurPage();
        _page = _curPage; // 设置初始页码
        _currentIndex = _singePageToDoublePage(_curPage);
        _pageController = PageController(initialPage: _currentIndex);
        //print('----------------------------取到上一次的页码: $_curPage');
      } else {
        _page = 1; // 设置初始页码
        _currentIndex = 0; // 双页模式下的初始索引
        _pageController = PageController(initialPage: _currentIndex);
      }
      //print('----------------------initState 初始化focusNode');
      // isPad().then((value) {
      //   _isPad = value;
      // });
      focusNode.requestFocus();
      // 添加焦点监听
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          focusNode.requestFocus();
        }
      });
      //print('----------------------initState 初始化初始化前台服务');
      //初始化前台服务
      FlutterForegroundTask.initCommunicationPort();
      // Add a callback to receive data sent from the TaskHandler.
      FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await requestPermissions();
          initService();

          ref.read(pdfLoadingDoneProvider.notifier).state = false;
          ref.read(pdfTextDoneProvider.notifier).state = false;
          ref.read(pdfControllerProvider.notifier).state = null;
          ref.read(pdfThumbnailDoneProvider.notifier).state = false;

          await _loadPdf(_curPage);
          //print('----------------------加载 PDF 完成1');

          if (widget.jingshu.type.contains('shanshu') &&
              (Platform.isIOS || Platform.isAndroid || Platform.isWindows)) {
            await _loadPdfText();
            //print('----------------------加载 PDF text 完成');
          }

          await _copyPage(); //复制一份页码缓存，用于双页显示和缩略图显示
          ref.read(pdfThumbnailDoneProvider.notifier).state = true;

          //print('----------------------加载 PDF text 完成');

          // ✅ 在加载完成后更新 Provider 状态
          ref.read(pdfControllerProvider.notifier).state = _pdfController;
          ref.read(pdfLoadingDoneProvider.notifier).state = true;
          //print('----------------------加载 initAsync 完成');
        } catch (e, st) {
          print('加载 PDF 时出现错误: $e\n$st');
          setState(() {
            _errorMessage = e.toString();
          });
          ref.read(pdfLoadingDoneProvider.notifier).state = false;
          ref.read(pdfTextDoneProvider.notifier).state = false;
        }
      });
    }

    // 调用异步初始化函数
    initAsync();

    //设置 TTS 回调函数
    if (widget.jingshu.type.contains('shanshu')) {
      ttstools.flutterTts.setCompletionHandler(() {
        ttsCallBackOnCompletion(_page);
      });
    }

    //print('--------------------------initstate 完成');
  }

  Future<void> _loadPdf(int curPage) async {
    if (!mounted) return Future.value();
    try {
      //print('------------------------进入 _loadPdf 方法');
      if (widget.jingshu.type == 'shanshu' ||
          widget.jingshu.type == 'jingshu') {
        _document = await PdfDocument.openAsset(
          'assets/pdfs/${widget.jingshu.fileUrl}',
        );
      } else {
        _document = await PdfDocument.openFile(widget.jingshu.fileUrl);
      }
      // 初始化 PdfController，确保只初始化一次
      //print('-------------------------------开始初始化 PdfController,$curPage');
      _pdfController?.dispose();
      _pdfController = PdfController(
        document: Future.value(_document!),
        initialPage: curPage,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载 PDF 时出错: $e';
      });
    }
  }

  Future<void> _copyPage() async {
    if (!mounted) return Future.value();
    _pageCaches = [];
    List<int> pagesToGenerate = []; //缩略图只需要生成10张就可以，为了节省资源
    if (widget.jingshu.type == 'shanshu' || widget.jingshu.type == 'jingshu') {
      _document2 = await PdfDocument.openAsset(
        'assets/pdfs/${widget.jingshu.fileUrl}',
      );
    } else {
      _document2 = await PdfDocument.openFile(widget.jingshu.fileUrl);
    }
    final totalPages = _document2!.pagesCount;
    if (totalPages <= 10) {
      // 总页数不超过 10，全部生成
      pagesToGenerate = List.generate(totalPages, (index) => index + 1);
    } else {
      // 大于 10 页时，仅生成首尾 + 中间等距 8 页
      pagesToGenerate.add(1); // 首页
      int samplesNeeded = 8;
      double interval = (totalPages - 2) / (samplesNeeded + 1);
      for (int i = 1; i <= samplesNeeded; i++) {
        int pageIndex = (i * interval).round().clamp(2, totalPages - 1);
        pagesToGenerate.add(pageIndex);
      }
      pagesToGenerate.add(totalPages); // 尾页
    }
    //print('----------------需要生成缩略图的页码: $pagesToGenerate');
    //先生成缓存list，缩略图先为null，text填写好
    _pages = _document2!.pagesCount;
    for (int i = 1; i <= _pages; i++) {
      _pageCaches.add(
        PageCache(pageIndex: i, image: null, thumbnail: null, text: ''),
      );
    }
    //print('-----------------开始生成_pageCaches，页码数量: ${_pageCaches.length}');
    for (final pageIndex in pagesToGenerate) {
      try {
        final page = await _document2!.getPage(pageIndex);
        // 获取每一页的
        //生成缩略图（宽度可根据缩略图组件大小微调）
        final pageWidth = page.width.toDouble();
        final pageHeight = page.height.toDouble();
        final thumbWidth = 100.0;
        final thumbHeight = thumbWidth * pageHeight / pageWidth;
        final pageImage = await page.render(
          width: thumbWidth, // 适中缩略图尺寸
          height: thumbHeight,
          format: PdfPageImageFormat.jpeg,
        );
        _pageCaches[pageIndex - 1].thumbnail = pageImage;

        await page.close(); // 及时释放
      } catch (e) {
        print('_copyPage Failed to generate thumbnail for page $pageIndex: $e');
      }
    }
    //print('---------------------_copyPage 完成');
    setState(() {});
  }

  //得到第pagenum页的text
  Future<String> getText(int pagenum) async {
    if (!mounted) return Future.value();
    String txt = '';
    if (Platform.isWindows) {
      txt = windoc.pages[pagenum - 1].text;
    } else {
      txt = await pdfdoc.pages[pagenum - 1].text;
    }
    txt = processText(txt);
    return txt;
  }

  Future<void> _loadPdfText() async {
    if (!mounted) return Future.value();
    late ByteData data;
    try {
      //print('---------------------');
      // 1. 从 assets 加载 pdf 文件为字节流
      if (widget.jingshu.type == 'shanshu' ||
          widget.jingshu.type == 'jingshu') {
        data = await rootBundle.load('assets/pdfs/${widget.jingshu.fileUrl}');
      } else {
        // 当文件不是从 assets 加载时，使用 File 直接读取本地文件
        data = await File(
          widget.jingshu.fileUrl,
        ).readAsBytes().then((bytes) => ByteData.view(bytes.buffer));
      }
      Uint8List bytes = data.buffer.asUint8List();
      //print('------------------第一步加载成功');
      // 2. 把 PDF 文件写入临时文件（因为 flutter_pdf_text 需要文件路径）
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp.pdf');
      await tempFile.writeAsBytes(bytes, flush: true);
      //print('------------------第二步临时文件生成成功');
      // 3. 加载 PDF 文本
      if (Platform.isWindows) {
        compute(loadPdfAndExtractText, tempFile.path)
            .then((result) {
              // 任务完成后在主线程执行
              windoc = result;
              setState(() {
                ref.read(pdfTextDoneProvider.notifier).state = true;
              });
              //print('------------------第3步成功');
            })
            .catchError((error) {
              print('PDF文本处理错误: $error');
            });
        //windoc = await loadPdfAndExtractText(tempFile.path);
      } else {
        pdfdoc = await PDFDoc.fromPath(tempFile.path);
        setState(() {
          ref.read(pdfTextDoneProvider.notifier).state = true;
        });
      }
    } catch (e) {
      print('加载 PDF text 出错: $e');
    }
  }

  @override
  void dispose() {
    if (!mounted) {
      super.dispose();
      return;
    }

    print('--------------------------dispose start');

    try {
      // 1. 先移除所有监听器和同步任务
      FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
      focusNode.dispose();
      _taskDataListenable.dispose();
      setPhoneWakeLock(false);

      // 2. 停止 TTS
      if (widget.jingshu.type.contains('shanshu')) {
        print('--------------------------dispose flutterTts start');
        ttstools.flutterTts.setCompletionHandler(() {});
        ttstools.stop();
        print('--------------------------dispose flutterTts end');
      }

      // 3. 停止音频
      print('--------------------------dispose AudioTools start');
      AudioTools.clearAndStop();
      print('--------------------------dispose AudioTools end');

      // 4. 清理文档资源
      _document?.close();
      _document = null;
      _document2?.close();
      _document2 = null;

      // 5. 清理控制器和缓存
      _pdfController?.dispose();
      _pdfController = null;
      _pageController?.dispose();
      _pageController = null;
      _doublePageFutures.clear();
      _pageCaches.clear();

      // 6. 停止服务
      stopService();

      print('--------------------------dispose end');
    } catch (e) {
      print('Error in dispose: $e');
    }

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDoublePage = _getIsDoubleFlag();
    //print('--------------------------didChangeDependencies 完成');
  }

  //从单页码转为双页码
  int _singePageToDoublePage(int page) => (page - 1) ~/ 2;
  int _doublePageToSinglePage(int index) => index * 2 + 1;

  Future<int> _getCurPage() async {
    if (!mounted) return 1;
    int curPage = 1; //默认第一页
    late JingShuData shanshu;
    final results = await globalDB.managers.jingShu
        .filter((f) => f.name(widget.jingshu.name))
        .filter((f) => f.type(widget.jingshu.type))
        .get();
    if (results.isEmpty) {
      return 1;
    } else if (results.length > 1) {
      // 多条结果处理（例如取第一条或提示用户）
      shanshu = results.first;
    } else {
      // 单条结果处理
      shanshu = results.single;
    }
    //('get shanshu.curPageNum : ${shanshu.curPageNum}');
    curPage = shanshu.curPageNum ?? 1;
    _curPage = curPage;
    return curPage;
  }

  Widget _buildDoublePageView() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: (_pages / 2).ceil(),
      controller: _pageController,
      onPageChanged: (index) {
        _page = _doublePageToSinglePage(index);
        setState(() {
          _currentIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final leftPage = index * 2 + 1;
        final rightPage = leftPage + 1;
        //print('0---------当前双页: 左页 $leftPage, 右页 $rightPage');

        Future<List<Uint8List>> _loadDoublePage(int index) {
          if (_doublePageFutures[index] != null)
            return _doublePageFutures[index]!;
          //print('1---------加载双页索引$index: 左页 $leftPage, 右页 $rightPage');
          _doublePageFutures[index] = () async {
            if (_pdfController == null || _document == null) {
              return [Uint8List(0), Uint8List(0)];
            }
            final leftPage = index * 2 + 1;
            final rightPage = leftPage + 1;
            PdfPageImage? leftImage;
            PdfPageImage? rightImage;

            if (_pageCaches[leftPage - 1].image == null) {
              leftImage = await _renderPage(context, _pdfController!, leftPage);
              _pageCaches[leftPage - 1].image = leftImage;
            } else {
              leftImage = _pageCaches[leftPage - 1].image;
            }
            //print('2---------------------: 左页 $leftPage 加载完成！');
            if (rightPage <= _pages) {
              if (_pageCaches[rightPage - 1].image == null) {
                rightImage = await _renderPage(
                  context,
                  _pdfController!,
                  rightPage,
                );
                _pageCaches[rightPage - 1].image = rightImage;
              } else {
                rightImage = _pageCaches[rightPage - 1].image;
              }
            } else {
              rightImage = null;
            }
            //print('3---------------------: 右页 $rightPage 加载完成！');
            return [
              leftImage?.bytes ?? Uint8List(0),
              rightImage?.bytes ?? Uint8List(0),
            ];
          }();
          return _doublePageFutures[index]!;
        }

        return FutureBuilder<List<Uint8List>>(
          future: _loadDoublePage(index),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final images = snapshot.data!;

            return Row(
              children: [
                const Expanded(flex: 4, child: SizedBox()),
                Expanded(
                  flex: 10,
                  child: images[0].isNotEmpty
                      ? Image.memory(images[0], fit: BoxFit.contain)
                      : const Center(child: Text('左页加载失败')),
                ),
                const Expanded(flex: 1, child: SizedBox()),
                Expanded(
                  flex: 10,
                  child: (rightPage <= _pages)
                      ? (images[1].isNotEmpty
                            ? Image.memory(images[1], fit: BoxFit.contain)
                            : const Center(child: Text('右页加载失败')))
                      : const SizedBox(),
                ),
                const Expanded(flex: 4, child: SizedBox()),
              ],
            );
          },
        );
      },
    );
  }

  Future<PdfPageImage?> _renderPage(
    BuildContext context,
    PdfController controller,
    int pageNumber,
  ) async {
    if (!mounted) return Future.value();
    final doc = await controller.document;
    if (pageNumber < 1 || pageNumber > doc.pagesCount) {
      print('无效的 pageNumber: $pageNumber, 页数范围: 1 - ${doc.pagesCount}');
      return null;
    }
    //print('有效的 doc:${doc.pagesCount}, 尝试获取第 $pageNumber 页');
    final page = await doc.getPage(pageNumber);
    try {
      try {
        final width = page.width;
        final height = page.height;
        if (width == null || height == null || width <= 0 || height <= 0) {
          print('PDF page 宽高无效 width=$width height=$height');
          await page.close();
          return null;
        }
        //print('---------------有效的page.width:$width, height:$height.');

        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        if (devicePixelRatio <= 0) {
          print('设备像素密度无效: $devicePixelRatio');
          await page.close();
          return null;
        }

        double clarityFactor = Platform.isWindows ? 1.5 : 0.5;
        final renderWidth = (width * devicePixelRatio * clarityFactor);
        final renderHeight = (height * devicePixelRatio * clarityFactor);

        //print('渲染尺寸: width=$renderWidth, height=$renderHeight');

        //print('---------------开始渲染pdf page $pageNumber.');
        final image = await page.render(
          width: renderWidth.toDouble(),
          height: renderHeight.toDouble(),
          format: PdfPageImageFormat.png,
        );
        if (image == null || image.bytes.isEmpty) {
          print('page.render 返回了 null 或空字节数组');
          await page.close();
          return null;
        }
        //print("page $pageNumber 渲染完成，图像长度: ${image.bytes.length}");
        return image;
      } catch (e, stackTrace) {
        print('渲染页面 $pageNumber 出错: $e $stackTrace');
        return null;
      }
    } finally {
      await page.close();
    }
  }

  Widget _buildSinglePageView() {
    //print('--------------------------_buildSinglePageView start');
    if (_pdfController == null) {
      //print('--------------------------_pdfController is null');
      return const Center(child: CircularProgressIndicator());
    }
    //print('------------显示单页-------------------');
    PdfView pdf = PdfView(
      controller: _pdfController!,
      onPageChanged: (page) {
        setState(() {
          _page = page;
          _currentIndex = _singePageToDoublePage(page);
        });
      },
      scrollDirection: Axis.vertical,
    );
    //print('--------------------------_buildSinglePageView end');
    return pdf;
  }

  void _handleClickAndJump(int pageNumber) {
    //print('点击缩略图跳转到第 $pageNumber 页');
    try {
      if (_isDoublePage) {
        //print('----------------_handleClickAndJump--------双页模式');
        final doublePageIndex = _singePageToDoublePage(pageNumber);
        _pages = _document!.pagesCount;
        if (_pageController!.hasClients) {
          _pageController?.jumpToPage(doublePageIndex);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pageController?.jumpToPage(doublePageIndex);
            // 强制刷新，不管 onPageChanged 是否触发
            setState(() {
              _page = pageNumber;
              _currentIndex = _singePageToDoublePage(pageNumber);
            });
          });
        }
        _currentIndex = doublePageIndex;
        _page = pageNumber;
        // print(
        //   '----------------应该跳到$pageNumber页--------跳转到双页索引: $doublePageIndex',
        // );
      } else {
        //print('----------------_handleClickAndJump--------单页模式');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          //print('-----------------当前单页页码: ${_pdfController!.page}');
          if (_pdfController != null && _pdfController!.page != pageNumber) {
            _pdfController?.jumpToPage(pageNumber);
            // 强制刷新
            setState(() {
              _page = pageNumber;
              _currentIndex = _singePageToDoublePage(pageNumber);
            });
          }
        });
      }
    } catch (e) {
      print('-----------------跳转到第 $pageNumber 页出错: $e');
    }
  }

  // 封装上一页逻辑的函数
  void _handlePreviousPage() {
    if (_isDoublePage) {
      setState(() {
        if (_currentIndex > 0) {
          _currentIndex--;
          _pageController?.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ); // 手动更新 PageView
        }
      });
    } else {
      _pdfController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // 使用 FocusScope 确保焦点正确设置
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _handleNextPage() {
    if (_isDoublePage) {
      setState(() {
        if (_currentIndex < (_pages / 2).ceil() - 1) {
          _currentIndex++;
          _page = _doublePageToSinglePage(_currentIndex);
          // print(
          //   '当前页码索引: $_currentIndex，总组数: ${(_pages / 2).ceil().toInt()}，翻到下一页',
          // );
          _pageController?.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ); // 手动更新 PageView
        }
      });
    } else {
      _pdfController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _currentIndex = _singePageToDoublePage(_pdfController!.page);
    }
    // 使用 FocusScope 确保焦点正确设置
    FocusScope.of(context).requestFocus(focusNode);
  }

  String processText(String input) {
    List<String> lines = input.split('\n');

    List<String> processedLines = [];

    for (var line in lines) {
      String trimmedLine = line.trim();

      // 跳过空行
      if (trimmedLine.isEmpty || trimmedLine == '') continue;

      // 跳过页码行：包含 "of"，前后都是数字（可带 "page"）
      final pageNumRegex = RegExp(
        r'^(page\s*)?(\d+\s*(of|\/)\s*\d+)$',
        caseSensitive: false,
      );

      if (pageNumRegex.hasMatch(trimmedLine)) continue;

      processedLines.add(trimmedLine);
    }

    return processedLines.join();
  }

  void _listenText(int pagenum) async {
    //pagenum 页码从1开始
    int pageCnt = _pageCaches.length;
    if (!_isDoublePage && pagenum >= 1 && pagenum <= pageCnt) {
      String text = await getText(pagenum);
      print('${pagenum}');
      print(text);
      if (Platform.isAndroid || Platform.isIOS) {
        startService('正在朗读 ${_bookName}');
      }
      print('---page:${_pdfController!.page}-----pagenum:$pagenum');
      if (_pdfController != null && _pdfController!.page != pagenum) {
        _pdfController?.jumpToPage(pagenum);
        _page = pagenum; // 更新当前页码
      }
      isOnGonging = true;

      await setPhoneWakeLock(true); //避免息屏
      await ttstools.speak(text, null);
      await setPhoneWakeLock(true);
    }
  }

  void ttsCallBackOnCompletion(int pagenum) {
    print('-------------------------------------------回调函数被调用了');
    isOnGonging = false;
    _listenText(pagenum + 1);
  }

  bool _getShowVoiceButtonFlag() {
    final _isTextDone = ref.read(pdfTextDoneProvider);
    print('-----------------_isTextDone: ${_isTextDone}');

    final flag =
        widget.jingshu.type.contains('shanshu') &&
        (Platform.isIOS || Platform.isAndroid || Platform.isWindows) &&
        !_isDoublePage &&
        _isTextDone;
    print('--------_getShowVoiceButtonFlag: ${flag}');
    return flag;
  }

  Widget _buildNavigatorButton() {
    return Column(
      children: [
        _getShowVoiceButtonFlag()
            ? IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: !isOnGonging
                    ? const Icon(Icons.record_voice_over, color: Colors.blue)
                    : const Icon(Icons.stop_circle, color: Colors.red),
                tooltip: '听书',
                onPressed: () {
                  setState(() {
                    if (!isOnGonging) {
                      _listenText(_page);
                    } else {
                      // 如果正在朗读，停止朗读
                      ttstools.pause();
                    }
                    isOnGonging = !isOnGonging;
                    if (!isOnGonging) {
                      setPhoneWakeLock(false); //没有播放的时候，就允许息屏了
                    }
                  });
                  focusNode.requestFocus(); // 处理完事件后重新获取焦点
                },
              )
            : SizedBox(),
        Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: const Icon(Icons.arrow_upward, color: Colors.blue),
          tooltip: '上一页',
          onPressed: () {
            _handlePreviousPage();
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
        // _isPad
        //     ? IconButton(
        //         padding: EdgeInsets.zero,
        //         constraints: BoxConstraints(),
        //         icon: Icon(
        //           _isDoublePage ? Icons.filter_1 : Icons.filter_2,
        //           color: Colors.blue,
        //         ),
        //         tooltip: _isDoublePage ? '切换为单页显示' : '切换为双页显示',
        //         onPressed: _togglePageMode,
        //       )
        //     : SizedBox(),
        Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: const Icon(Icons.arrow_downward, color: Colors.blue),
          tooltip: '下一页',
          onPressed: () {
            _handleNextPage();
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
        _showMuyuFlag ? _buildMuyuButtonGroup() : SizedBox(),
        SizedBox(height: 10),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Image.asset(
            // 替换为你的图片路径，例如"assets/images/music_note.png"
            _showMuyuFlag
                ? "assets/images/muyu-gray-24.png"
                : "assets/images/muyu-yellow-24.png",
            // 根据需要设置图片大小
            width: 24,
            height: 24,
            // 图片加载错误时显示的占位图
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
          ),
          tooltip: '木鱼背景音乐',
          onPressed: () {
            _showMuyuFlag = !_showMuyuFlag;
            setState(() {});
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(
            Icons.calendar_view_month,
            color: _showThumbnailFlag ? Colors.grey : Colors.blue,
          ),
          tooltip: '隐藏缩略图',
          onPressed: () {
            _showThumbnailFlag = !_showThumbnailFlag;
            setState(() {});
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildMuyuButtonGroup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        _buildMuyuButton(mp3Filename: 'mp3/muyu_normal_0_7.mp3', text: '||  '),
        SizedBox(height: 10),
        _buildMuyuButton(mp3Filename: 'mp3/muyu_normal.mp3', text: '||| '),
        SizedBox(height: 10),
        _buildMuyuButton(mp3Filename: 'mp3/muyu_normal_2.mp3', text: '||||'),
      ],
    );
  }

  Widget _buildMuyuButton({
    required String mp3Filename, // 只读的音频文件名
    required String text,
    double rate = 1.0,
  }) {
    return SizedBox(
      width: 100, // 设置固定宽度
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          // 移除边框
          side: BorderSide.none,
        ),
        child: Row(
          children: [
            Text(text),
            _muyuIsPlaying
                ? Icon(Icons.pause_circle, color: Colors.red)
                : Icon(Icons.play_circle, color: Colors.blue),
          ],
        ),
        onPressed: () {
          if (_muyuIsPlaying) {
            AudioTools.stop();
          } else {
            AudioTools.playLocalAsset(
              mp3Filename,
              onComplete: _handlePlayComplete,
              playbackRate: rate,
            );
          }
          setState(() {
            _muyuIsPlaying = !_muyuIsPlaying;
          });
        },
      ),
    );
  }

  void _handlePlayComplete() {
    setState(() {
      _muyuIsPlaying = false;
    });
  }

  Future<void> _backToParentPage() async {
    // 检查组件是否还挂载
    print('--------开始返回 _page:$_page');
    if (mounted) {
      Navigator.pop(context, _page); // 点击返回按钮时返回上一个页面
    }
    print('--------开始返回 _page:$_page 结束');
  }

  @override
  Widget build(BuildContext context) {
    //print('-----------_document:${_document.toString()}');
    final isLoading = ref.watch(pdfLoadingDoneProvider);
    final pdfController = ref.watch(pdfControllerProvider);
    final _isThumbnailDone = ref.watch(pdfThumbnailDoneProvider);
    if (!isLoading || pdfController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('错误: $_errorMessage'),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        //print('-----------didpop:$didPop,result:$result');
        if (!didPop) {
          _backToParentPage();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 30,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _backToParentPage,
          ),
        ),
        body: KeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.pageDown ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown ||
                  event.logicalKey == LogicalKeyboardKey.arrowRight) {
                _handleNextPage();
              } else if (event.logicalKey == LogicalKeyboardKey.pageUp ||
                  event.logicalKey == LogicalKeyboardKey.arrowUp ||
                  event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                _handlePreviousPage();
              } else if (event.logicalKey == LogicalKeyboardKey.space ||
                  event.logicalKey == LogicalKeyboardKey.enter) {
                _handleNextPage();
              }
              focusNode.requestFocus();
            }
          },
          child: _isDoublePage
              ? Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildDoublePageView(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Spacer(), _buildNavigatorButton()],
                          ),
                        ],
                      ),
                    ),
                    _showThumbnailFlag && _isThumbnailDone
                        ? PdfThumbnailList(
                            key: ValueKey(
                              'thumbnailList_${_isDoublePage ? 'vertical' : 'horizontal'}',
                            ),
                            pageCaches: _pageCaches,
                            currentPage: _page,
                            onPageSelected: (pageIndex) {
                              _handleClickAndJump(pageIndex);
                            },
                            thumbnailWidth: 50,
                          )
                        : SizedBox(),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildSinglePageView(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Spacer(), _buildNavigatorButton()],
                          ),
                        ],
                      ),
                    ),
                    _showThumbnailFlag && _isThumbnailDone
                        ? PdfThumbnailList(
                            key: ValueKey(
                              'thumbnailList_${_isDoublePage ? 'vertical' : 'horizontal'}',
                            ),
                            pageCaches: _pageCaches,
                            currentPage: _page - 1,
                            onPageSelected: (pageIndex) {
                              _handleClickAndJump(pageIndex);
                            },
                            thumbnailWidth: 30,
                            direction: Axis.horizontal,
                          )
                        : SizedBox(),
                  ],
                ),
        ),
      ),
    );
    ;
  }
}

// class PdfPageView extends StatelessWidget {
//   final int pageNumber;
//   final PdfController controller;

//   const PdfPageView({
//     super.key,
//     required this.pageNumber,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<PdfPageImage?>(
//       future: _renderPage(context, controller, pageNumber),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return Image.memory(snapshot.data!.bytes, fit: BoxFit.contain);
//         } else if (snapshot.hasError) {
//           print('Error loading page $pageNumber: ${snapshot.error}');
//           return Center(
//             child: Text('Error loading page $pageNumber: ${snapshot.error}'),
//           );
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('onDestroy(isTimeout: $isTimeout)');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
    FlutterForegroundTask.sendDataToMain({'buttonPressed': id});
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}

//前台服务请求权限
Future<void> requestPermissions() async {
  // Android 13+, you need to allow notification permission to display foreground service notification.
  //
  // iOS: If you need notification, ask for permission.
  if (Platform.isAndroid || Platform.isIOS) {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    } else {
      print('--------------NotificationPermission ok');
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      } else {
        print('--------------isIgnoringBatteryOptimizations ok');
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      // if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      //   // When you call this function, will be gone to the settings page.
      //   // So you need to explain to the user why set it.
      //   await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      // } else {
      //   print('--------------openAlarmsAndRemindersSettings ok');
      // }
    }
  }
}

void initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

Future<ServiceRequestResult> startService(String msg) async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      // You can manually specify the foregroundServiceType for the service
      // to be started, as shown in the comment below.
      // serviceTypes: [
      //   ForegroundServiceTypes.dataSync,
      //   ForegroundServiceTypes.remoteMessaging,
      // ],
      serviceId: 256,
      notificationTitle: '诵经助手',
      notificationText: '${msg}',
      notificationIcon: null,
      notificationButtons: [
        const NotificationButton(id: 'btn_stop', text: '停止播放'),
        const NotificationButton(id: 'btn_start', text: '开始播放'),
      ],
      notificationInitialRoute: '/second',
      callback: startCallback,
    );
  }
}

Future<ServiceRequestResult> stopService() {
  return FlutterForegroundTask.stopService();
}

// Future<bool> isPad() async {
//   if (Platform.isIOS) {
//     final iosInfo = await DeviceInfoPlugin().iosInfo;
//     return iosInfo.model.toLowerCase().contains('ipad');
//   } else if (Platform.isAndroid) {
//     //final androidInfo = await DeviceInfoPlugin().androidInfo;
//     // 安卓平板通常屏幕密度和尺寸较大
//     final view = WidgetsBinding.instance.platformDispatcher.views.first;
//     final size = view.physicalSize / view.devicePixelRatio;
//     final diagonal = sqrt(size.width * size.width + size.height * size.height);
//     return diagonal > 10 * 160; // 10 英寸约为 1600 点
//   } else if (Platform.isWindows) {
//     return true;
//   }
//   return false;
// }

//使用状态，在pdf加载完毕再显示pdf页面
class PdfLoadProvider with ChangeNotifier {
  bool _isPdfLoaded = false;

  bool get isLoaded => _isPdfLoaded;

  void markLoaded() {
    _isPdfLoaded = true;
    notifyListeners();
  }

  void reset() {
    _isPdfLoaded = false;
    notifyListeners();
  }
}
