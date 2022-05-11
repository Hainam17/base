import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/libs/DioLib.dart';
import 'package:vhv_basic/widgets/BetterVideoPlayer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';


class FormVideoPickers extends StatefulWidget {
  final bool autoPlay;
  final bool hasUpload;
  final ValueChanged? onChanged;
  final List? value;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final bool chooseNow;
  final int maxVideo;
  final Function(Function)? checkSuccess;

  const FormVideoPickers({Key? key, this.autoPlay = false, this.hasUpload = true,
    this.onChanged, this.value, this.labelText, this.errorText,
    this.enabled = true, this.chooseNow = false, this.maxVideo = 3, this.checkSuccess}) : super(key: key);
  @override
  _FormVideoPickersState createState() => _FormVideoPickersState();
}

class _FormVideoPickersState extends State<FormVideoPickers> {
  double ratio = 16/9;
  int _currentIndex = 0;
  ImagePicker? picker;
  bool hasPicked = false;
  late List value;
  late Map _value;
  List<AssetEntity> assets = [];


  _remove(String key)async{
    if(_value.containsKey(key)){
      String path = _value[key]['assetPath'];
      _value.remove(key);
      final _val = await _convertToVal();
      if (widget.onChanged != null) widget.onChanged!(_val);
      if(_currentIndex > (_value.length - 1)){
        _currentIndex = _value.length - 1;
      }
      if(_currentIndex < 0)_currentIndex = 0;
      await Future.forEach(assets, (element)async{
        final _path = await getAssetFilePath(element as AssetEntity);
        if(_path == path){
          assets.remove(element);
        }
      });
      if (mounted) setState(() {

      });
    }
  }
  Future<List<AssetEntity>> selectAssets([int? max]) async {
    final List<AssetEntity>? result = await PickMethod.cameraAndStay(maxAssetsCount: max??widget.maxVideo,
        requestType: RequestType.video).method(context, assets);
    if (result != null) {
      assets = List<AssetEntity>.from(result);
      return assets;
    }
    return [];
  }
  _pick()async{
    if (!hasPicked) {
      hasPicked = true;
      final _res = await selectAssets();
      hasPicked = false;
      if (!empty(_res)) {
        final _path = await getAssetFilePath(_res[0]);
        if (widget.hasUpload) {
          _value.addAll({
            '$_path': {
              'file': _path,
              'assetPath':_path,
              'process': ValueNotifier<double>(0)
            }
          });
          _currentIndex = _value.length - 1;
          if (mounted) setState(() {});
          _upload(_path);
        } else {
          _value.addAll({
            '$_path': {
              'file': _path,
              'assetPath':_path,
              'success': 1,
            }
          });
          value.add(_path);
          final _val = await _convertToVal();
          if (widget.onChanged != null) widget.onChanged!(_val);
        }
      }
    }
//    final _res = await PermissionLib().requests([Permission.storage, Permission.photos]);
//    if(_res) {
//      if (!hasPicked) {
//        hasPicked = true;
//        FilePickerResult _video = await filePicker(
//          fileType: FileType.video,
//        );
//        hasPicked = false;
//        if (_video != null && _video.files != null) {
//          final String _videoPath = _video.files[0].path;
//          if (widget.hasUpload) {
//            _value.addAll({
//              '$_videoPath': {
//                'file': _videoPath,
//                'process': ValueNotifier<double>(0)
//              }
//            });
//            _currentIndex = _value.length - 1;
//            if (mounted) setState(() {});
//            _upload(_videoPath);
//          } else {
//            _value.addAll({
//              '$_videoPath': {
//                'file': _videoPath,
//                'success': 1,
//              }
//            });
//            value.add(_video.files[0].path);
//            final _val = await _convertToVal();
//            if (widget.onChanged != null) widget.onChanged(_val);
//          }
//        }
//      }
//
//    }
  }
  _upload(String filePath)async{
    final _res = await upload(filePath, process: _value['$filePath']['process']);
    if(_res is Map){
      if(!empty(_res['path'])){
        if(mounted) {
          if(_value.containsKey(filePath)){
            _value[filePath]['fileLocal'] = _value[filePath]['file'];
            _value[filePath]['file'] = _res['path'];
            _value[filePath]['success'] = 1;
            _value = _value.map((key, value){
              return MapEntry('${value['file']}', value);
            });
            setState(() {});
            final _val = await _convertToVal();
            if (widget.onChanged != null) widget.onChanged!(_val);
          }

        }
      }else{
        _value['$filePath']['error'] = _res['error'];
        showMessage(_res['error'], type: 'ERROR');
        // _textError = _res['error'];
        if(mounted)setState(() {

        });
      }

    }
  }
  _convertToVal()async{
    List<String> _val = [];
    _value.forEach((key, value) {
      if(!empty(value['success'])){
        _val.add(value['file']);
      }
    });
    return _val;
  }

  _checkSuccess(){
    bool _success = true;
    if(!empty(_value)){
      _value.forEach((key, value) {
        if(empty(value['success'])){
          _success = false;
        }
      });
    }
    return _success;
  }

  @override
  void initState() {
    assets = [];
    if(widget.checkSuccess != null)widget.checkSuccess!(_checkSuccess);
    value = widget.value??[];
    _value = {};
    if(!empty(widget.value)){
      widget.value!.forEach((link) {
        _value.addAll({
          '$link':{
            'file': link,
            'success': 1
          }
        });
      });
    }
    picker = ImagePicker();
    if(widget.chooseNow && empty(widget.value))_pick();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!empty(_value)) {
      final _fileInfo = _value.values.elementAt(_currentIndex);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              BetterVideoPlayer(
                videoLink: _fileInfo['fileLocal']??_fileInfo['file'],
                autoPlay: false,
                ratio: 1,
                key: ValueKey('FormVideoPickers---${_fileInfo['file']}'),
              ),
              if(!empty(_fileInfo['process']))ValueListenableBuilder<double>(
                valueListenable: _fileInfo['process'],
                builder: (_, __value, child){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: __value,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: __value<1?Colors.blue:((empty(_fileInfo['error']))?Colors.green:Colors.red),
                              ),
                              height: 3,
                            ),
                          ),
                        ),
                      ),
                      if(__value<1)Text('Đang tải lên ...', style: TextStyle(color: Colors.blue)),
                      if(__value == 1 && !empty(_fileInfo['error']))Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${_fileInfo['error']}', style: TextStyle(color: Colors.red)),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: (){
                              _upload(_fileInfo['file']);
                            },
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4)
                  ),
                  padding: const EdgeInsets.all(3),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () async {

                      _remove(_fileInfo['file']);
                    },
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.black,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: (_value).values.map<Widget>((e) {
                  final int _index = _value.keys.toList().indexOf(e['file']);
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: (_index == _currentIndex)
                            ? Colors.blue
                            : Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: InkWell(
                        onTap: () async {
                          _currentIndex = (_index < 0)?0:_index;
                          if (mounted) setState(() {

                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: videoThumbnail(e['file'], width: 70),
                        ),
                      ),
                    ),
                  );
                }).toList()
                  ..add((_value.length < widget.maxVideo)?Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: InkWell(
                        onTap: () async {
                          _pick();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add),
                                Text('Thêm'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ):SizedBox()
                ),
              ),
            ),
          )
        ],
      );
    }
    return AspectRatio(aspectRatio: 16/9,
      child: InkWell(
        onTap: widget.enabled?(){
          _pick();
        }:null,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              color: !empty(widget.errorText)?Colors.red[100]:Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.video_collection_outlined),
                    Text(widget.labelText??'Chọn video tải lên')
                  ],
                ),
              ),
            ),
            if(!empty(widget.errorText))Text(widget.errorText!, style: TextStyle(color: Colors.red))
          ],
        ),
      ));
  }
}