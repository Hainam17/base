import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class ImageCacheNetwork extends StatelessWidget {
  final String? image;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final String? imageThumbnail;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final LoadingErrorWidgetBuilder? errorBuilder;
  const ImageCacheNetwork(this.image, {Key? key,this.errorBuilder, this.width, this.height, this.aspectRatio, this.imageThumbnail, this.fit, this.errorWidget, this.placeholder, this.progressIndicatorBuilder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: ValueKey('ImageCacheNetwork$image'),
      imageUrl: image!,
      width: width,
      height: height,
      fit: fit,
      progressIndicatorBuilder: progressIndicatorBuilder??(_, __, process){
        if(placeholder != null)return placeholder!;
        if(imageThumbnail == null) {
          if(empty(width) || empty(height)){
            if(process.progress != null)return SizedBox(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(aspectRatio: aspectRatio??3/2,child: SvgViewer('assets/icons/ic_no_image.svg', width: double.infinity, package: 'vhv_basic',fit: BoxFit.cover)),
                  Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Text('${(process.progress! * 100).ceil()}%'),
                  ),
                ],
              ),
            );
            return AspectRatio(aspectRatio: aspectRatio??3/2,
              child: Container(
                color: Colors.grey.withOpacity(0.2),
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: 50
                    ),
                    child: AspectRatio(aspectRatio: 1,
                      child: const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Container(
            color: Colors.grey.withOpacity(0.2),
            width: width,
            height: height,
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 50
                ),
                child: AspectRatio(aspectRatio: 1,
                    child: CircularProgressIndicator(strokeWidth: 2)
                ),
              ),
            ),
          );
        }
        return Image.network(imageThumbnail!, width: width, height: height, fit: BoxFit.cover);
      },
      errorWidget: errorBuilder??(context, url, error){
        return errorWidget??Container(color: Theme.of(context).scaffoldBackgroundColor, child: Center(child: Icon(Icons.error_outline)));
      },
    );
  }
}
