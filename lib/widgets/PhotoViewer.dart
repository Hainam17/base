import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:vhv_basic/import.dart';

class PhotoViewer extends StatefulWidget {
  PhotoViewer({
    Key? key,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    this.title,
    @required this.images,
    this.scrollDirection = Axis.horizontal, this.pageController,
    this.hasDownload = false
  }):super(key: key);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int? initialIndex;
  final PageController? pageController;
  final List<dynamic>? images;
  final Axis? scrollDirection;
  final String? title;
  final bool hasDownload;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewerState();
  }
}

class _PhotoViewerState extends State<PhotoViewer> {
  late int currentIndex;
  RxBool? hasDownload;
  List<int>? _hasDowns;
  PageController? _pageController;

  @override
  void initState() {
    _hasDowns = [];
    hasDownload = false.obs;
    currentIndex = widget.initialIndex??0;
    if(widget.pageController != null){
      _pageController = widget.pageController;
    }else{
      _pageController = PageController(initialPage: widget.initialIndex??0);
    }

    super.initState();
  }

  void onPageChanged(int index) {
    hasDownload!.value = false;
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: (widget.title != null)?Text(htmlDecode(widget.title!.stripTag()),
          style: const TextStyle(color: Colors.white)):null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if(!empty(factories['hasDownloadImage']) || widget.hasDownload)Obx((){
            if(hasDownload!.isFalse && !_hasDowns!.contains(currentIndex)) {
              return IconButton(icon:const Icon(Icons.download_outlined),
                  color: Colors.white,
                  onPressed: () async {
                    _hasDowns!.add(currentIndex);
                    hasDownload!.value = true;
                    final String _res = await download(
                        urlConvert(widget.images![currentIndex]['image']),
                        toDownloadFolder: true);
                    if (!empty(_res)) {
                      showMessage('Tải về thành công (${_res.substring(
                          _res.lastIndexOf('/') + 1)})', type: 'SUCCESS');
                    } else {
                      showMessage('Tải về thất bại', type: 'ERROR');
                    }
                  }
              );
            }
            return const SizedBox.shrink();
          }),
        ],
        iconTheme: IconThemeData(
            color: Colors.white
        ),
      ),
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.images!.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: _pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection!,
            ),
            if(widget.images!.length > 1)Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Ảnh".lang()+' ${currentIndex + 1}/${widget.images!.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final Map<String, dynamic> item = widget.images![index];
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage('${urlConvert(item['image'])}'),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 1.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item['image']),
    );
  }
}