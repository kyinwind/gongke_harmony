import 'package:flutter/material.dart';
import '../providers/pdf_provider.dart';

class PdfThumbnailList extends StatefulWidget {
  final List<PageCache> pageCaches;
  final int currentPage;
  final void Function(int pageIndex) onPageSelected;
  final double thumbnailWidth;
  final Axis direction;

  const PdfThumbnailList({
    super.key,
    required this.pageCaches,
    required this.currentPage,
    required this.onPageSelected,
    this.thumbnailWidth = 50,
    this.direction = Axis.vertical,
  });

  @override
  State<PdfThumbnailList> createState() => _PdfThumbnailListState();
}

class _PdfThumbnailListState extends State<PdfThumbnailList> {
  int? _previewPage;

  void _handleTouch(Offset localPos, Size size) {
    final percent = widget.direction == Axis.vertical
        ? (localPos.dy / size.height).clamp(0.0, 1.0)
        : (localPos.dx / size.width).clamp(0.0, 1.0);

    final actualPage = (percent * widget.pageCaches.length).floor().clamp(
      0,
      widget.pageCaches.length - 1,
    );

    setState(() {
      _previewPage = actualPage + 1;
    });
  }

  List<PageCache> _buildDisplayCaches() {
    return widget.pageCaches.where((cache) => cache.thumbnail != null).toList();
  }

  List<Widget> _buildThumbnails() {
    final displayCaches = _buildDisplayCaches();

    return displayCaches.map((cache) {
      final isSelected = widget.currentPage == cache.pageIndex;

      return GestureDetector(
        onTap: () {
          print('---------------点击缩略图: ${cache.pageIndex}');
          widget.onPageSelected(cache.pageIndex);
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Image.memory(
            cache.thumbnail!.bytes,
            width: widget.thumbnailWidth,
            fit: widget.direction == Axis.horizontal
                ? BoxFit.fitWidth
                : BoxFit.fitHeight,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final thumbnails = _buildThumbnails();
    return Stack(
      alignment: Alignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) =>
                  _handleTouch(details.localPosition, size),
              onPanEnd: (details) {
                if (_previewPage != null) {
                  widget.onPageSelected(_previewPage!);
                  setState(() => _previewPage = null);
                }
              },
              child: widget.direction == Axis.vertical
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: thumbnails,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: thumbnails,
                    ),
            );
          },
        ),
        if (_previewPage != null)
          Positioned(
            top: widget.direction == Axis.vertical ? 16 : null,
            bottom: widget.direction == Axis.horizontal ? 16 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_previewPage/${widget.pageCaches.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }
}
