import 'package:flutter/material.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart';
import 'package:gongke/comm/thumbnail_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gongke/providers/pdf_provider.dart';
import 'package:gongke/comm/audio_tools.dart';
import 'package:gongke/comm/platform_tools.dart';

class PdfViewerPage extends ConsumerStatefulWidget {
  final JingShuData jingshu; //jingshu对象

  const PdfViewerPage({super.key, required this.jingshu});

  @override
  ConsumerState<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends ConsumerState<PdfViewerPage> {
  List<PageCache> _pageCaches = []; // 缓存的页码列表，包含缩略图和文本，已经生成的page的image也缓存在这里
  final Map<int, Future<List<Uint8List>>> _doublePageFutures = {};
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

  // 根据条件得出当前是否显示双页，true需要显示双页
  bool _getIsDoubleFlag() {
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 && orientation == Orientation.landscape;
  }

  @override
  void initState() {
    super.initState();
    //print('----------------------initState 开始');
    _doublePageFutures.clear();
    _pageCaches.clear();

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

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          ref.read(pdfLoadingDoneProvider.notifier).state = false;
          ref.read(pdfControllerProvider.notifier).state = null;
          ref.read(pdfThumbnailDoneProvider.notifier).state = false;

          await _loadPdf(_curPage);
          //print('----------------------加载 PDF 完成1');

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
        }
      });
    }

    // 调用异步初始化函数
    initAsync();

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
      _pageCaches.add(PageCache(pageIndex: i, image: null, thumbnail: null));
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

  @override
  void dispose() {
    if (!mounted) {
      super.dispose();
      return;
    }

    print('--------------------------dispose start');

    try {
      focusNode.dispose();

      // 停止音频
      print('--------------------------dispose AudioTools start');
      AudioTools.clearAndStop();
      print('--------------------------dispose AudioTools end');

      // 清理文档资源
      _document?.close();
      _document = null;
      _document2?.close();
      _document2 = null;

      // 清理控制器和缓存
      _pdfController?.dispose();
      _pdfController = null;
      _pageController?.dispose();
      _pageController = null;
      _doublePageFutures.clear();
      _pageCaches.clear();

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
        if (width <= 0 || height <= 0) {
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

        final clarityFactor = PlatformUtils.pdfRenderClarityFactor;
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

  Widget _buildNavigatorButton() {
    return Column(
      children: [
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
