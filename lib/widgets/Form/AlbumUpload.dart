import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class FormAlbumUpload extends StatefulWidget {
  final bool enabled;
  final bool chooseNow;
  final dynamic value;
  final bool hasUpload;
  final bool hasChangeAvatar;
  final String? errorText;
  final int maxImage;
  final Function(dynamic value)? onChanged;
  final Function(Function upload)? uploadBuilder;
  final ValueChanged<bool>? onUploading;
  final Function(VoidCallback add, bool hasImage)? buttonBuilder;
  final String fixNameFile;
  final String? buttonText;
  final bool isAssay;
  final bool onlyCamera;
  final Widget Function(String image)? imageBuilder;
  final Future<List> Function()? cameraBuilder;
  final bool isUploading;
  final Function(Map images,bool isList, String fixNameFile)? cameraUploadBuilder;

  const FormAlbumUpload({Key? key, this.enabled:true, this.chooseNow = false, this.value,
    @required this.onChanged, this.hasUpload = true, this.uploadBuilder, this.errorText,
    this.maxImage = 30, this.hasChangeAvatar = false, this.buttonBuilder,
    this.fixNameFile = 'image', this.buttonText, this.isAssay = false, this.onlyCamera = false,
    this.cameraBuilder, this.imageBuilder, this.onUploading, this.cameraUploadBuilder,
    this.isUploading = false}) : super(key: key);
  @override
  _FormAlbumUploadState createState() => _FormAlbumUploadState();
}

class _FormAlbumUploadState extends State<FormAlbumUpload> {
  List<Widget>? _listWidget;
  Map? _images;
  bool isList = false;
  late ValueNotifier<bool> uploading;
  @override
  void initState() {
    uploading = new ValueNotifier(widget.isUploading);
    if(widget.uploadBuilder != null)widget.uploadBuilder!(_upload);
    if(widget.value is List)isList = true;
    _images = {};
    if(!empty(widget.value)){
      int _index = 1;
      _images = (widget.value is List)?Map.fromIterable(widget.value, key: (e) => '${_index++}', value: (e) => (e is Map)?e:<String, dynamic>{
        'image': e,
        'title': e.toString().substring(e.toString().lastIndexOf('/') + 1)
      }):widget.value;
    }
    _images!.forEach((key, value) {
      value.addAll(<String, dynamic>{
        'isOld': 1
      });
    });
    _init();
    if(widget.chooseNow && empty(_images)){
      _addMultiFiles();
    }
    super.initState();
  }


  setUpdateValue(){
    Map _imagesTemp = {};
    Map _links = {};
    if(!empty(widget.value)){
      int _index = 1;
      _imagesTemp = (widget.value is List)?Map.fromIterable(widget.value, key: (e) => '${_index++}', value: (e) => (e is Map)?e:<String, dynamic>{
        'image': e,
        'title': e.toString().substring(e.toString().lastIndexOf('/') + 1)
      }):widget.value;
    }
    _images!.forEach((key, value) {
      if(!empty(value['${widget.fixNameFile}'])){
        _links.addAll({
          value['${widget.fixNameFile}']: value
        });
      }
    });
    _imagesTemp.forEach((key, value) {
      if(!empty(value['${widget.fixNameFile}']) && _links.keys.contains(value['${widget.fixNameFile}'])){
        value.addAll(_links[value['${widget.fixNameFile}']]);
      }
    });
    _images = {}..addAll(_imagesTemp);
  }

  @override
  didUpdateWidget(FormAlbumUpload oldWidget){
    if(widget.value.toString() != oldWidget.value.toString()){
      setUpdateValue();
      if(widget.uploadBuilder != null)widget.uploadBuilder!(_upload);
      if(widget.cameraUploadBuilder != null){
        uploading.value = widget.isUploading;
      }
      if(widget.value is List)isList = true;
      _init();
    }
    super.didUpdateWidget(oldWidget);
  }

  _setKey(){
    int _index = 1;
    _images!.forEach((key,value) {
      value..addAll({
        'sortOrder': _index,
      });
      _index++;
    });
    if(mounted)setState(() {

    });
  }

  _init()async{
    _listWidget = [
      if(widget.buttonBuilder == null && widget.enabled)Container(
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: uploading,
          builder: (_, value, child){
            return InkWell(
              child: Center(
                child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(!value)...[
                      Icon(Icons.add_circle_outline),
                      Text((widget.buttonText??'Thêm ảnh').lang())
                    ],
                    if(value)...[
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                          Icon(Icons.upload_outlined),
                        ],
                      ),
                      Text('Đang tải lên'.lang())
                    ]
                  ],
                ),
              ),
              onTap: !value?()async{
                return _addMultiFiles();
              }:null,
            );
          },
        ),
      )
    ];
    bool hasAvatar = false;
    _images!.forEach((key, value) {
      if(!empty(value['isAvatar'])){
        hasAvatar = true;
      }
    });
    if(!empty(_images)){
      _images!.forEach((key, value) {
        if(!hasAvatar){
          value['isAvatar'] = '1';
          hasAvatar = true;
          Future.delayed(Duration(seconds: 1),(){
            if(mounted)widget.onChanged!(isList?_convertImages(_images!).values.toList():_convertImages(_images!));
          });
        }
        if(!empty(value[widget.fixNameFile])) {
          _listWidget!.add(Stack(
            children: [
              (value['${widget.fixNameFile}'] is AssetEntity)
                  ?Image(image: AssetEntityImageProvider(value['${widget.fixNameFile}'],
                  isOriginal: false, thumbSize: [300,300]),width: 300, height: 300,fit: BoxFit.cover):ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child:(widget.imageBuilder != null)?widget.imageBuilder!(value['${widget.fixNameFile}']):ImageViewer(
                  value['${widget.fixNameFile}'],
                  ratio: 1,
                  widthThumb: 200,
                  fit: BoxFit.cover,
                )),
              if(widget.enabled && widget.hasChangeAvatar)Positioned(
                left: 0,
                top: 0,
                child: InkWell(
                  onTap: () {
                    changeIsAvatar(key);
                    widget.onChanged!(isList?_convertImages(_images!).values.toList():_convertImages(_images!));
                  },
                  child: Container(padding: const EdgeInsets.all(5),
                    child: Icon(
                      !empty(value['isAvatar'])?Icons.check_box_outlined:Icons.check_box_outline_blank,
                      color: !empty(value['isAvatar'])?Colors.blue:Colors.grey,
                      size: 20,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.all(Radius.circular(3))),
                  ),
                ),
              ),
              if(widget.enabled)Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                    onTap: () {
                      _remove(key);
                    },
                    child:
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)
                      ),
                      child: Container(
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                        decoration: BoxDecoration(
                            color: Color(0xff200E32),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 3),
                      ),
                    )
                ),
              ),
            ],
          ));
        }
      });
    }

  }
  _remove(String key)async{
    if(_images!.containsKey(key)){
      setState(() {
        _images!.remove(key);
      });
      _setKey();
      widget.onChanged!(isList?_convertImages(_images!).values.toList():_convertImages(_images!));
    }
  }
  Future<List<dynamic>> selectAssets([int? max]) async {
    if(widget.onlyCamera){
      if(widget.cameraBuilder != null){
        return await widget.cameraBuilder!();
      }else {
        final AssetEntity? result = await CameraPicker.pickFromCamera(
          context,
          enableRecording: true,
          textDelegate: currentLanguage == 'vi'
              ? null
              : EnglishCameraPickerTextDelegate(),
        );
        if (result is AssetEntity) {
          return <AssetEntity>[result];
        }
      }
    }else{
      if(widget.isAssay) {
        final List<AssetEntity>? result = await PickMethod.cameraAndStay(
            maxAssetsCount: max ?? widget.maxImage).method(context, getAsset());
        if (result != null) {
          return List<AssetEntity>.from(result);
        }
      }else{
        final List<AssetEntity>? result = await PickMethod.camera(
          maxAssetsCount: max ?? widget.maxImage,
          handleResult: (BuildContext context, AssetEntity result) =>
              Navigator.of(context).pop(<AssetEntity>[...getAsset(), result]),
        ).method(context, getAsset());
        if (result != null) {
          return List<AssetEntity>.from(result);
        }
      }
    }


    return [];
  }
  @override
  Widget build(BuildContext context) {
    _init();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if(widget.buttonBuilder == null || !empty(_images))GridView.builder(
            itemCount: _listWidget!.length,
            shrinkWrap: true,
            primary: false,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                crossAxisCount: Get.context!.isTablet?5:3
            ),
            itemBuilder: (BuildContext context, int index) {
              return _listWidget![index];
            }
        ),
        if(widget.buttonBuilder != null && widget.enabled)widget.buttonBuilder!(_addMultiFiles, !empty(_images))
      ],
    );
  }

  getLength(){
    int _num = 0;
    _images!.forEach((key, value) {
      if(!empty(value['isOld'])){
        _num++;
      }
    });
    return widget.maxImage - _num;
  }
  setFiles(List<dynamic> assets)async{
    Map _items = {};
    int _index = 1;
    List<AssetEntity> oldAssets = [];
    List<AssetEntity> newAssets = [];
    List<String> newFilesPath = [];
    _images!.forEach((key, value) {
      if(!empty(value['isOld'])
          || (value['assetEntity'] is AssetEntity && assets.contains(value['assetEntity']))
      || !empty(value['isCamera'])
      ){
        _items.addAll({
            '${_index++}': value
        });
      }
      if(value['assetEntity'] is AssetEntity){
        oldAssets.add(value['assetEntity']);
      }
    });
    assets.forEach((element) {
      if(!oldAssets.contains(element)){
        if(element is AssetEntity){
          newAssets.add(element);
        }else if(element is String){
          newFilesPath.add(element);
        }
      }
    });
    if (newAssets.length > 0) {
      await Future.forEach(newAssets, (AssetEntity element) async {
        final _p = await getAssetFilePath(element);
        _items.addAll({
          '$_index': {
            'title': element.title,
            'assetEntity': element,
            'assetPath': _p,
            'sortOrder': _index++
          }
        });
      });
    }
    if(newFilesPath.length > 0){
      newFilesPath.forEach((element) {
        _items.addAll({
          '$_index': {
            'title': element.substring(element.lastIndexOf('/') + 1),
            'isCamera': 1,
            'assetPath': element,
            'sortOrder': _index++
          }
        });
      });
    }
    _images = {}..addAll(_items);
    if(mounted)setState(() {

    });
  }

  _addMultiFiles([List<AssetEntity>? assets]) async{
    FocusScope.of(currentContext).requestFocus(new FocusNode());
    if(widget.enabled) {
      if(assets == null) {
        if(getLength() > 0) {
          final List<dynamic> _assets = await selectAssets(getLength());
          if (_assets.length > 0) {
            await setFiles(_assets);
          }
        }
      }else{
        if (assets.length > 0) {
          await setFiles(assets);
        }
      }
      if(widget.hasUpload){
        uploading.value = true;
        if(widget.onUploading != null)widget.onUploading!(true);
        if(widget.cameraUploadBuilder != null){
          _images = await widget.cameraUploadBuilder!(_images!, isList, 'file');
        }else{
          await _upload();
        }
        if(widget.onUploading != null)widget.onUploading!(false);
        uploading.value = false;
      }

      if(mounted)setState(() {

      });
      if(widget.onChanged != null)widget.onChanged!(isList?_convertImages(_images!).values.toList():_convertImages(_images!));
    }
  }

  _upload()async{
    List _false = [];
    final Map values = {}..addAll(_images!);
    await Future.forEach(values.values, (value)async{
      if(value is Map) {
        var path = value['assetPath'];
        final String _name = value['title'];
        if (empty(value['${widget.fixNameFile}'])) {
          final _res = await upload(path, fileName: _name);
          if (_res is Map) {
            if (!empty(_res['path'])) {
              value.addAll(<String, dynamic>{
                '${widget.fixNameFile}': _res['path']
              });
              if (values.containsKey('${value['sortOrder']}')) {
                values.addAll({
                  '${value['sortOrder']}': value
                });
              }
            } else if (!empty(_res['error']) &&
                values.containsKey('${value['sortOrder']}')) {
              _false.add('${value['sortOrder']}');
              showMessage(_res['error'], type: 'error');
            }
          }
        }
      }
    });

    if(!empty(_false)){
      values.removeWhere((key, value) => _false.contains(key));
    }
    _images = {}..addAll(values);

    if(mounted)setState(() {

    });
    uploading.value = false;
    if(widget.onUploading != null)widget.onUploading!(false);
    _setKey();
    return isList?_convertImages(_images!).values.toList():_convertImages(_images!);
  }

  Map _convertImages(Map images) {
    Map _temp = {};
    int _index = 1;
    images.forEach((key, value) {
      if(value['${widget.fixNameFile}'] is String) {
        _temp.addAll({
          '$_index': Map.from(value..addAll({
            'sortOrder': _index
          }))
        });
        if(_temp['$_index'].containsKey('assetPath')){
          _temp['$_index'].remove('assetPath');
        }
        if(_temp['$_index'].containsKey('assetEntity')){
          _temp['$_index'].remove('assetEntity');
        }
        if(!widget.hasChangeAvatar) {
          if (_temp['$_index'].containsKey('isAvatar')) {
            _temp['$_index'].remove('isAvatar');
          }
        }
        if(_temp['$_index'].containsKey('isCamera')){
          _temp['$_index'].remove('isCamera');
        }
        _index++;
      }
    });
    return _temp;
  }

  changeIsAvatar(String key) {
    _images!.forEach((_key, value) {
      if(!empty(value['isAvatar'])){
        if(key != _key){
          value.remove('isAvatar');
          setState(() {

          });
        }
      }else if(key == _key){
        value.addAll({
          'isAvatar': '1'
        });
        setState(() {

        });
      }
    });
  }

  List<AssetEntity> getAsset() {
    List<AssetEntity> _list = [];
    _images!.forEach((key, value) {
      if(value['assetEntity'] is AssetEntity){
        _list.add(value['assetEntity']);
      }
    });
    return _list;
  }
}

