import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:gongke/comm/audio_tools.dart';
import 'package:gongke/comm/pdf_tools.dart';
import 'package:gongke/database.dart';
import 'package:gongke/main.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key, required this.jingshu});

  final JingShuData jingshu;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final FocusNode _focusNode = FocusNode();
  final AppPdfViewerController _viewerController = AppPdfViewerController();

  int _page = 1;
  int _pageCount = 1;
  int? _initialPageIndex;
  String? _filePath;
  bool _isLoading = true;
  bool _showMuyuFlag = false;
  bool _muyuIsPlaying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    });
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.jingshu.type.contains('shanshu')) {
      _page = await _getCurPage();
    }
    final filePath = await AppPdfTools.resolveFilePath(widget.jingshu);
    if (!mounted) {
      return;
    }
    setState(() {
      _filePath = filePath;
      _initialPageIndex = _page - 1;
      _isLoading = false;
    });
  }

  Future<int> _getCurPage() async {
    final results = await (globalDB.select(globalDB.jingShu)
          ..where((tbl) => tbl.name.equals(widget.jingshu.name))
          ..where((tbl) => tbl.type.equals(widget.jingshu.type)))
        .get();
    if (results.isEmpty) {
      return 1;
    }
    return results.first.curPageNum ?? 1;
  }

  Future<void> _saveCurrentPage() async {
    if (!widget.jingshu.type.contains('shanshu')) {
      return;
    }
    await (globalDB.update(globalDB.jingShu)
          ..where((tbl) => tbl.id.equals(widget.jingshu.id)))
        .write(JingShuCompanion(curPageNum: Value(_page)));
  }

  Future<void> _backToParentPage() async {
    await _saveCurrentPage();
    if (!mounted) {
      return;
    }
    Navigator.pop(context, _page);
  }

  Future<void> _handlePreviousPage() async {
    if (_page <= 1) {
      return;
    }
    setState(() {
      _errorMessage = null;
    });
    await _viewerController.goToPage(_page - 2);
    _focusNode.requestFocus();
  }

  Future<void> _handleNextPage() async {
    if (_pageCount > 0 && _page >= _pageCount) {
      return;
    }
    setState(() {
      _errorMessage = null;
    });
    await _viewerController.goToPage(_page);
    _focusNode.requestFocus();
  }

  Widget _buildMuyuButton({
    required String mp3Filename,
    required String text,
    double rate = 1.0,
  }) {
    return SizedBox(
      width: 100,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(side: BorderSide.none),
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
        child: Row(
          children: [
            Text(text),
            _muyuIsPlaying
                ? const Icon(Icons.pause_circle, color: Colors.red)
                : const Icon(Icons.play_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMuyuButtonGroup() {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildMuyuButton(mp3Filename: 'mp3/muyu_normal_0_7.mp3', text: '||  '),
        const SizedBox(height: 10),
        _buildMuyuButton(mp3Filename: 'mp3/muyu_normal.mp3', text: '||| '),
        const SizedBox(height: 10),
        _buildMuyuButton(mp3Filename: 'mp3/muyu_normal_2.mp3', text: '||||'),
      ],
    );
  }

  void _handlePlayComplete() {
    if (!mounted) {
      return;
    }
    setState(() {
      _muyuIsPlaying = false;
    });
  }

  Widget _buildNavigatorButton() {
    return Column(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_upward, color: Colors.blue),
          tooltip: '上一页',
          onPressed: _handlePreviousPage,
        ),
        const Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.arrow_downward, color: Colors.blue),
          tooltip: '下一页',
          onPressed: _handleNextPage,
        ),
        const Spacer(),
        if (_showMuyuFlag) _buildMuyuButtonGroup(),
        const SizedBox(height: 10),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Image.asset(
            _showMuyuFlag
                ? 'assets/images/muyu-gray-24.png'
                : 'assets/images/muyu-yellow-24.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
          ),
          tooltip: '木鱼背景音乐',
          onPressed: () {
            setState(() {
              _showMuyuFlag = !_showMuyuFlag;
            });
            _focusNode.requestFocus();
          },
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildPdfBody() {
    if (_filePath == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AppPdfTools.buildViewer(
      filePath: _filePath!,
      controller: _viewerController,
      initialPage: _initialPageIndex ?? (_page - 1),
      onViewCreated: (controller) async {
        final pageCount = await controller.getPageCount();
        final currentPage = await controller.getCurrentPage();
        if (!mounted) {
          return;
        }
        setState(() {
          _pageCount = pageCount ?? _pageCount;
          _page = ((currentPage ?? (_page - 1)) + 1).clamp(
            1,
            pageCount ?? 999999,
          );
          _errorMessage = null;
        });
      },
      onRender: (controller, pageCount) {
        if (!mounted) {
          return;
        }
        setState(() {
          _pageCount = pageCount ?? _pageCount;
          _errorMessage = null;
        });
      },
      onPageChanged: (page, pageCount) {
        if (!mounted) {
          return;
        }
        setState(() {
          _page = (page ?? 0) + 1;
          _pageCount = pageCount ?? _pageCount;
          _errorMessage = null;
        });
      },
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _errorMessage = error.toString();
        });
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    AudioTools.clearAndStop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('错误: $_errorMessage'),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
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
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is! KeyDownEvent) {
              return;
            }
            if (event.logicalKey == LogicalKeyboardKey.pageDown ||
                event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              _handleNextPage();
            } else if (event.logicalKey == LogicalKeyboardKey.pageUp ||
                event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _handlePreviousPage();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRect(child: _buildPdfBody()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  _buildNavigatorButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
