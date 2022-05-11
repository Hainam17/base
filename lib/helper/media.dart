import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
export 'package:multi_image_picker/multi_image_picker.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/libs/DioLib.dart';
import 'package:vhv_basic/libs/PermissionLib.dart';
import 'package:vhv_basic/widgets/BetterVideoPlayer.dart';
import 'package:vhv_basic/widgets/ImageCache.dart';
import 'package:vhv_basic/widgets/VimeoVideoPlayer.dart';
import 'package:vhv_basic/widgets/YoutubePlay.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:get/get.dart';



class FileUpload{
  final File? file;
  final ValueNotifier<double>? process;
  const FileUpload({
    this.file, this.process
  });
}
Future<String?> selectImage({double? ratio, int? width, bool hasUpload = true,
  int? sizeLimit, bool hideCrop = false, bool requestPermission = false}) async {
  Function? _image;
  await showBottomMenu(
      child: DefaultTextStyle(
        style: Theme.of(currentContext).textTheme.subtitle1!,
        child: Column(
          children: [
            InkWell(
              onTap: ()async{
                if(requestPermission ==false) {
                  final _res = await PermissionLib().requests([Permission.camera]);
                  if(!empty(_res)){
                    _image = ()async{
                      return await _selectImage(ratio: ratio,
                          width: width, source: ImageSource.camera,
                          hasUpload: hasUpload, sizeLimit: sizeLimit, hideCrop:  hideCrop);
                    };
                  }
                } else {
                  _image = ()async{
                    return await _selectImage(ratio: ratio,
                        width: width, source: ImageSource.camera,
                        hasUpload: hasUpload, sizeLimit: sizeLimit, hideCrop:  hideCrop);
                  };
                }

                appNavigator.pop();

              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_outlined),
                    const SizedBox(width: 20),
                    Text('Máy ảnh'.lang())
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: ()async{

                final _res = await PermissionLib().requests([Permission.storage]);
                if(!empty(_res)) {
                  _image = ()async {
                    return _selectImage(
                        ratio: ratio,
                        width: width,
                        source: ImageSource.gallery,
                        hasUpload: hasUpload, sizeLimit: sizeLimit);
                  };
                }
                appNavigator.pop();
              },
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined),
                      const SizedBox(width: 20),
                      Text('Thư viện'.lang())
                    ],
                  )
              ),
            ),
          ],
        ),
      )
  );
  if(_image != null) {
    final String? _img = await _image!();
    return _img;
  }
  return '';
}

_selectImage({double? ratio, int? width, ImageSource? source, bool hasUpload = true, int? sizeLimit
  , bool hideCrop = false})async{
  String? _filePath;
  FocusScope.of(currentContext).requestFocus(new FocusNode());
  final picker = ImagePicker();
  final XFile? _image = await picker.pickImage(source: source??ImageSource.gallery);
  if(!hideCrop) {
    if(_image != null) {
      File rotatedImage =
      await FlutterExifRotation.rotateImage(path: _image.path);
      if (!empty(ratio)) {
        _filePath = await _cropImage(rotatedImage.path, ratio!);
        final length = await File(_filePath!).length();
        if(sizeLimit != null && length >= sizeLimit){
          showMessage('Ảnh vượt quá dung lượng tối đa.');
          return null;
        }
        if (hasUpload) {
          final _res = await upload(_filePath);
          if (_res != null && !empty(_res['path'])) {
            return _res['path'];
          }
        }
        return _filePath;
      }
      final length = await rotatedImage.length();
      if(sizeLimit != null && length >= sizeLimit){
        showMessage('Ảnh vượt quá dung lượng tối đa.');
        return null;
      }
      if (_filePath == null) _filePath = rotatedImage.path;
      if (hasUpload) {
        final _res = await upload(_filePath);
        if (_res != null && !empty(_res['path'])) {
          return _res['path'];
        }
      }
      return _filePath;
    }
    return null;
  }
  return _image!.path;
}

_cropImage(String path, double ratio) async {
  File? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: CropAspectRatio(
          ratioX: ratio,
          ratioY: 1
      ),
      compressQuality: 100,
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cắt ảnh',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true),
      iosUiSettings: IOSUiSettings(
        title: 'Cắt ảnh',
      ));
  if (croppedFile != null) {
    return croppedFile.path;
  }
}

Widget playVideo(String data,
    {isFullscreen: false,
      bool? autoPlay,
      ValueNotifier? listener,
      StreamSink? valueListener,
      Stream<bool>? fullScreenControl,
      dynamic controller,
      YoutubePlayerController? youtubePlayerController,
      bool isFullPage = false
    }) {
  RegExp _reExpId = new RegExp(
      r'(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/\s]{11})',
      caseSensitive: false,
      multiLine: false);
  RegExp _reExpVimeo = new RegExp(
      r'(http|https)?://(www\.)?vimeo.com/(([^/]*)/videos/|)(\d+)(?:|/\?)',
      caseSensitive: false,
      multiLine: false);
  if (_reExpId.hasMatch(data)) {
    return YoutubePlay(data,
        autoPlay: autoPlay ?? true,
        listener: listener,
        valueListener: valueListener,
        controller: youtubePlayerController);
  } else if (_reExpVimeo.hasMatch(data)) {
    final Iterable<Match>? _matches = _reExpVimeo.allMatches(data);
    for (Match? m in _matches!) {
      if (m?.group(5) != null) {
        return VimeoVideoPlayer(
          id: (m!.group(5))!.toString(),
          valueListener: valueListener,
          controller: controller,
          autoPlay: autoPlay,
        );
      }
    }
  }
  return BetterVideoPlayer(
      videoLink: data,
      //valueListener: valueListener,
      //controller: controller,
      autoPlay: autoPlay
  );
}

imagesPicker([List<Asset>? selected,int? maxImages])async{
  try {
    return await MultiImagePicker.pickImages(
      maxImages: maxImages??30,
      enableCamera: true,
      selectedAssets: selected ?? [],
      cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
      materialOptions: MaterialOptions(
        actionBarTitle: "Chọn ảnh",
        allViewTitle: "Tất cả",
        useDetailsView: false,
        selectCircleStrokeColor: "#000000",
        autoCloseOnSelectionLimit: true,
      ),
    );
  }catch(e){
    if(!empty(selected))
    {
      return selected;
    }
    else{
      return null;
    }

  }
}

uploadImages(List images, [ValueNotifier<String>? result])async{
  List<Map> _res = [];
  int _total = images.length;
  int _current = 0;
  if(result != null)result.value = '$_current/$_total';
  await Future.forEach(images, (image)async{
    if(image is Asset) {
      final _r = await _uploadImage(image);
      _current++;
      if(result != null)result.value = '$_current/$_total';
      _res.add(_r);
    }

  }).then((response) {

  });
  return _res;

}
_uploadImage(Asset image) async{
  var path = await FlutterAbsolutePath.getAbsolutePath(image.identifier!);
  final String? _name = image.name;
  final Map? _res = await upload(path,
    fileName: _name!,
  );
  if(_res is Map){
    return _res;
  }
}

uploadFiles(List<FileUpload> files)async{
  List<Map> _res = [];
  await Future.forEach(files, (FileUpload file)async{
    final _r = await _upload(file);
    _res.add(_r);
  }).then((response) {

  });
  return _res;

}
_upload(FileUpload file) async{
  final Map? _res = await upload(file.file!.path,
      fileName: file.file!.path.substring(file.file!.path.lastIndexOf('/') + 1),
      process: file.process
  );
  if(_res != null && _res['path'] != null){
    return _res;
  }
}

filePicker({var ext, FileType? fileType, bool allowCompression = false, int? size, bool allowMultiple = false})async {
  if (!empty(ext)){
    assert(ext is String || ext is List<String>, 'Tham số kiểu file lỗi');
  }
  List<String>? _ext;
  if(ext is List<String>)_ext = ext;
  if(ext is String){
    _ext = ext.split(',');
  }
  final FilePickerResult? _file = await FilePicker.platform.pickFiles(
      type: fileType!,
      allowCompression: allowCompression,
      allowedExtensions: _ext,
      allowMultiple: allowMultiple
  );
  return _file;
}
urlConvert(String url, [bool forceDomain = false, bool forceHttps = false]){
  if(url.startsWith('data:image')){
    return url;
  }
  url = url.replaceAll(' ', '%20');
  String domain = app['domain'];
  if((url.isImageFileName || url.isVideoFileName || url.isPDFFileName) && !empty(app['staticDomain'])){
    domain = app['staticDomain'];
  }

  if(url.toLowerCase().startsWith('http')){
    return url.replaceAll(RegExp('https?://', caseSensitive: false), 'https://');
  }else if(url.startsWith('assets')){
    return url;
  }else{
    if(url.startsWith('upload') || url.startsWith('/upload')
        || url.startsWith('publish') || url.startsWith('/publish')
        || url.startsWith('video/') || url.startsWith('/video/')
        || url.startsWith('LMS/') || url.startsWith('/LMS') || url.startsWith('Project/')){
      return '$domain${url.indexOf('/') == 0?'':'/'}$url';
    }
    if(forceDomain) {
      return '$domain${url.indexOf('/') == 0?'':'/'}$url';
    }
    if(forceHttps) {
      return 'https://$url';
    }else{
      return url;
    }
  }
}
videoThumbnail(String url, {double? width, double? ratio}) {
  Widget? _videoImg;
  if (!empty(url)) {
    RegExp _reExpId = new RegExp(
        r'(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/\s]{11})',
        caseSensitive: false,
        multiLine: false);
    RegExp _reExpVimeo = new RegExp(
        r'(http|https)?://(www\.)?vimeo.com/(([^/]*)/videos/|)(\d+)(?:|/\?)',
        caseSensitive: false,
        multiLine: false);
    if (_reExpId.hasMatch(url)) {
      RegExpMatch? _id = _reExpId.firstMatch(url);
      _videoImg =
          ImageCacheNetwork('https://img.youtube.com/vi/${_id!.group(1)}/0.jpg', fit: BoxFit.cover);
    } else if (_reExpVimeo.hasMatch(url)) {
      RegExpMatch? _id = _reExpVimeo.firstMatch(url);
      _videoImg = ImageCacheNetwork(
        'https://i.vimeocdn.com/video/${_id!.group(5)}.webp', fit: BoxFit.cover);
    } else if (url.indexOf('upload/') == 0) {
      int _width = width!.ceil();
      int _height = (((_width) / (ratio ?? 1.5))).ceil();
      _videoImg = ImageCacheNetwork(
        '${app['staticDomain']}/publish/thumbnail/${app['id']}/${_width}x${_height}xdefault/$url.png', fit: BoxFit.cover);
    }
  }
  return Stack(
    alignment: Alignment.center,
    children: [
      AspectRatio(
          aspectRatio: ratio ?? 3 / 2,
          child: Container(
            width: width,
            color: Colors.black,
            child: _videoImg,
          )),
      const Icon(
        Icons.play_circle_outline,
        color: Colors.grey,
        size: 40,
      )
    ],
  );
}