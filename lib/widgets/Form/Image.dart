import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/libs/DioLib.dart';
import 'package:vhv_basic/widgets/Avatar.dart';
import 'package:vhv_basic/widgets/Button/Raised.dart';
import 'package:vhv_basic/widgets/ImageViewer.dart';
import 'package:vhv_basic/widgets/Loading.dart';
import 'package:vhv_basic/widgets/SvgViewer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class FormImage extends StatefulWidget {
  final String? fullName;
  final ValueChanged? onChanged;
  final String? value;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final double radius;
  final double width;
  final double? height;
  final double? ratio;
  final int? sizeLimit;
  final bool hideCrop;
  final bool hasUpload;
  final bool hideDeleteBtn;
  final bool hasBase64;
  final Function(Function upload)? uploadCallback;

  const FormImage({Key? key, this.hasUpload = true, this.fullName,
    this.onChanged, this.value, this.labelText,
    this.errorText, this.enabled = true,
    this.sizeLimit, this.radius = 4, this.width = 100, this.height, this.ratio,
    this.hideCrop = false, this.hasBase64 = false, this.hideDeleteBtn = false,
    this.uploadCallback}) : super(key: key);
  @override
  _FormImageState createState() => _FormImageState();
}

class _FormImageState extends State<FormImage> {
  String _value = '';
  List<AssetEntity> assets = [];
  ValueNotifier<bool>? _loadingNotify;

  didUpdateWidget(FormImage oldWidget){
    if(widget.value != oldWidget.value){
      _value = widget.value??'';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _loadingNotify = new ValueNotifier(false);
    assets = [];
    _value = widget.value??'';
    if(widget.uploadCallback != null){
      widget.uploadCallback!(_selectImage);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: widget.width,
          height: widget.height??(widget.width),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              border: (widget.errorText != null)?Border.all(
              color: Theme.of(context).errorColor,
              width: 1
            ):null
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(widget.radius),
                child: InkWell(
                  radius: widget.radius,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await _selectImage();
                  },
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        (widget.fullName != null)?Avatar(
                          widget.fullName??'',
                          width: widget.width,
                          radius: widget.radius,
                          image: _value,
                        ):Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: (!empty(_value))?ImageViewer(_value, fit: BoxFit.cover,width: widget.width,
                            height: widget.height??(widget.width)):Center(
                            child: SvgViewer('assets/icons/ic_camera.svg', package: 'vhv_basic'),
                          ),
                        ),
                        if(!empty(widget.fullName) && empty(_value))Container(
                            height: 21,
                            width: 25,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: ButtonRaised(
                                color: Colors.white.withOpacity(0.8),
                                padding: EdgeInsets.zero,
                                child:const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                onPressed: () async {
                                  _selectImage();
                                }
                            )
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: _loadingNotify!,
                          builder: (_, value, child){
                            if(value){
                              return const Loading();
                            }
                            return const SizedBox.shrink();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if(!empty(_value) && !widget.hideDeleteBtn)Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)
                  ),
                  child: IconButton(
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                      ),
                      onPressed: () async {
                        if(mounted){
                          setState(() {
                            _value = '';
                            assets = [];
                          });
                          if(widget.onChanged != null)widget.onChanged!('');
                        }
                      }
                  ),
                ),
              ),
            ],
          ),
        ),
        if(widget.errorText != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(widget.errorText!,style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).errorColor)),
          ),
      ],
    );
  }
  Future<List<AssetEntity>> selectAssets([int? max]) async {
    final List<AssetEntity>? result = await PickMethod.camera(
      maxAssetsCount: 1,
      handleResult: (BuildContext context, AssetEntity result) =>
        Navigator.of(context).pop(<AssetEntity>[result])).method(context, assets);
    if (result != null) {
      assets = List<AssetEntity>.from(result);
      return assets;
    }
    return [];
  }
  _selectImage()async{
    final _res = await selectAssets();
    if(!empty(_res)) {
      final _path = await getAssetFilePath(_res[0]);
      if (widget.hasBase64) {
        List<int> imageBytes = File(_path).readAsBytesSync();
        String img64 = base64Encode(imageBytes);
        if (widget.onChanged != null) widget.onChanged!(img64);
        if (mounted) {
          setState(() {
            _value = img64;
          });
        }
      }else{
        if (widget.hasUpload) {
          _loadingNotify!.value = true;
          final _res2 = await upload(_path);
          _loadingNotify!.value = false;
          if (_res2 is Map && !empty(_res2['path'])) {
            if (widget.onChanged != null) widget.onChanged!(_res2['path']);
            if (mounted) {
              setState(() {
                _value = _res2['path'];
              });
            }
          }
        } else {
          if (widget.onChanged != null) widget.onChanged!(_path);
          if (mounted) {
            setState(() {
              _value = _path;
            });
          }
        }
      }
    }
  }
}