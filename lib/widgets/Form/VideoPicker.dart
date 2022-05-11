import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/libs/DioLib.dart';
import 'package:vhv_basic/widgets/BetterVideoPlayer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class FormVideoPicker extends StatefulWidget {
  final bool hasUpload;
  final ValueChanged? onChanged;
  final String? value;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final bool chooseNow;
  final double ratio;

  const FormVideoPicker({Key? key, this.hasUpload = true, @required this.onChanged, this.value,
    this.labelText, this.errorText, this.enabled = true, this.chooseNow = false, this.ratio = 16/9}) : super(key: key);
  @override
  _FormVideoPickerState createState() => _FormVideoPickerState();
}

class _FormVideoPickerState extends State<FormVideoPicker> {
  ImagePicker? picker;
  bool hasPicked = false;
  String? value;
  String? _value;
  ValueNotifier<double>? _process;
  String? _textError;
  List<AssetEntity>? assets;

  @override
  void initState() {
    value = widget.value??'';
    _value = widget.value??'';
    assets = [];
    if(widget.hasUpload)_process = ValueNotifier(0.0);
    picker = ImagePicker();
    super.initState();
  }

  @override
  void didChangeDependencies(){
    if(widget.chooseNow && empty(widget.value))_pick();
    super.didChangeDependencies();
  }
  @override
  void didUpdateWidget(covariant FormVideoPicker oldWidget) {
    if (widget.value != null && oldWidget.value != widget.value) {
      value = widget.value;
      _value = widget.value??'';
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<List<AssetEntity>?> selectAssets([int? max]) async {
    final List<AssetEntity>? result = await PickMethod.camera(
      maxAssetsCount: 1,
      requestType: RequestType.video,
      handleResult: (BuildContext context, AssetEntity result) =>
          Navigator.of(context).pop(<AssetEntity>[result])).method(context, assets!);
    if (result != null) {
      assets = List<AssetEntity>.from(result);
      return assets;
    }
    return [];
  }
  _pick()async {
    final _res = await selectAssets();
    if (!empty(_res)) {
      final _path = await getAssetFilePath(_res![0]);
      if (widget.hasUpload) {
        setState(() {
          _value = _path;
        });
        _upload(_value!);
      } else{
        _value = _path;
        value = _path;
        if(mounted) {
          if (widget.onChanged != null) widget.onChanged!(value);
        }
      }
      hasPicked = false;
      if(mounted)setState(() {});
    }
  }

  _upload(String file)async{
    final _res = await upload(file, process: _process);
    if(_res is Map){
      if(!empty(_res['path'])){
        value = _res['path'];
        if(mounted) {
          setState(() {});
          if (widget.onChanged != null) widget.onChanged!(value);
        }
      }else{
        showMessage(_res['error'], type: 'ERROR');
        _textError = _res['error'];
        if(mounted)setState(() {

        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    if(!empty(_value)){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              BetterVideoPlayer(
                videoLink: _value,
                autoPlay: false,
                ratio: widget.ratio,
              ),
              if(_process != null && empty(value))ValueListenableBuilder<double>(
                valueListenable: _process!,
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
                                color: __value<1?Colors.blue:((empty(_textError))?Colors.green:Colors.red),
                              ),
                              height: 3,
                            ),
                          ),
                        ),
                      ),
                      if(__value<1)Text('Đang tải lên ...', style: TextStyle(color: Colors.blue)),
                      if(__value == 1 && !empty(_textError))Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_textError', style: TextStyle(color: Colors.red)),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: (){
                              _upload(_value!);
                            },
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
              if(!empty(value))Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: Container(
                    width: 30,
                    height: 30,
                    color: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      onPressed: (){
                        if(mounted) {
                          setState(() {
                            value = '';
                            assets = [];
                            _value = '';
                          });
                          if (widget.onChanged != null) widget.onChanged!(value);
                        }
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          if(!empty(widget.errorText))Text(widget.errorText!, style: TextStyle(color: Colors.red))
        ],
      );
    }
    return AspectRatio(aspectRatio: widget.ratio,
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
          if(hasPicked)Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
          if(!empty(widget.errorText))Text(widget.errorText!, style: TextStyle(color: Colors.red))
        ],
      ),
    ));
  }
}