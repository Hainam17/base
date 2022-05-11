import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class FormFilePicker extends StatefulWidget {
  final dynamic value;
  final List<String>? fileExt;
  final bool multipleUpload;
  final String? labelText;
  final String? errorText;
  final Widget? training;
  final bool enabled;
  final bool hasChangeTitle;
  final InputDecoration? decoration;
  final ValueChanged? onChanged;
  final FileType? fileType;
  final Widget? uploadFileView;
  final Widget? buttonBuilder;
  final bool hasCamera;

  FormFilePicker(
      {Key? key,
      this.multipleUpload: false,
      this.fileExt,
      this.decoration,
      this.labelText,
      this.errorText,
      this.training,
      this.uploadFileView,
      this.hasChangeTitle: false,
      this.onChanged,
      this.buttonBuilder,
      this.enabled: true, this.fileType, this.value, this.hasCamera : false})
      : super(key: key);
  @override
  _FormFilePickerState createState() => _FormFilePickerState();
}

class _FormFilePickerState extends State<FormFilePicker> {
  dynamic _value;
  FilePickerResult? _files;
  bool _isSuccess = false;
  bool isSuccess = false;
  String? _errorText;
  ValueNotifier<double>? _process;
  Map<String, Map>? _otherFiles;
  InputDecoration? _inputDecoration;
  String? _labelText;
  @override
  void initState() {
    _errorText = widget.errorText;
    _process = ValueNotifier<double>(0.0);
    _value = widget.value;
    if(!empty(widget.value)){
      _process!.value = 1;
      _isSuccess = true;
    }
    _otherFiles = new Map<String, Map>();
    _labelText = ((_value != null && _value is String)?_value:null)??((widget.labelText??'Chọn file tải lên').lang());
    _inputDecoration = (widget.decoration ??
        InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          errorText: widget.errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          errorStyle: TextStyle(color: Colors.red),
        ));
    if(!empty(_value)){
      _process!.value = 1;
    }
    super.initState();
  }
  @override
  void didUpdateWidget(FormFilePicker oldWidget) {
    _errorText = widget.errorText;
    _value = widget.value;
    _labelText = ((_value != null && _value is String)?_value:null)??(widget.labelText??'Chọn file tải lên').lang();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.multipleUpload) {
      return _uploadFile();
    } else {
      return _uploadMultiFiles();
    }
  }

  _choseFile() async {
    if (widget.enabled) {
      if (mounted) setState(() {
        _errorText = null;
      });
      if (widget.hasCamera) {
        final _res = await showBottomMenu(
          title: 'Chọn'.lang(),
          child: DefaultTextStyle(
            style: Theme.of(currentContext).textTheme.subtitle1!,
            child: Column(
              children: [
                InkWell(
                  onTap: ()async{
                    appNavigator.pop('camera');

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
                    appNavigator.pop('library');
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
        if(_res == 'camera'){
          final AssetEntity? result = await CameraPicker.pickFromCamera(
          context,
          enableRecording: true,
          textDelegate: currentLanguage == 'vi'?null:EnglishCameraPickerTextDelegate(),
          );
          if (result != null) {
            final File? _f = await result.file;
            Uint8List? _byte = await result.originBytes;
            int _length = await _f!.length();
            PlatformFile _file = PlatformFile.fromMap({
              'path': _f.path,
              'name': result.title,
              'bytes': _byte,
              'size': _length
            });
            _choseFileContent(_file);
          }
        }else{
          _choseFileContent();
        }
      }else{
        await _choseFileContent();
      }
    }
  }
  _choseFileContent([PlatformFile? file])async{
    _isSuccess = false;
    List<PlatformFile>? files = [];
    if(file == null) {
      _files = await filePicker(
          fileType: widget.fileType ??
              ((!empty(widget.fileExt)) ? FileType.custom : FileType.any),
          ext: widget.fileExt,
          allowMultiple: widget.multipleUpload
      );
      if(_files != null) {
        files = _files?.files;
      }
    }else{
      files = [file];
    }
    if(files!.length > 0) {
      if (widget.multipleUpload) {
        int _index = _otherFiles!.length + 1;
        files.forEach((element) {
          String? _path = element.path;
          _otherFiles!.addAll({
            '$_index': {
              'filePath': _path,
              'process': ValueNotifier<double>(0),
              'title': _path!.substring(_path.lastIndexOf('/') + 10),
            }
          });
          _index++;
        });
        if (mounted) setState(() {});
        Future.forEach(_otherFiles!.entries, (MapEntry entry) {
          if (!empty(entry.value['filePath'])) {
            _upload(entry.value['filePath'], entry.key, entry.value['process']);
          }
        }).then((response) {
          if (widget.onChanged != null) widget.onChanged!(_otherFiles);
          if (mounted) setState(() {
            _isSuccess = true;
          });
        });
      } else {
        if (mounted && _files != null) setState(() {
          _labelText = files![0].path!.substring(
              files[0].path!.lastIndexOf('/') + 1);
        });
        await _upload(files[0]);
        if (mounted) setState(() {
          _isSuccess = true;
        });
      }
    }
  }

  Widget _fileInfo(String key, Map value) {
    final String _name = value['title']??'';
    return Container(
      // height: 35,
      margin: (widget.multipleUpload) ? const EdgeInsets.only(bottom: 10) : null,
      child: Row(
        children: <Widget>[
          _convertIcon(value['file']??value['image']),
          SizedBox(
            width: 5,
          ),
          Expanded(
              child: widget.hasChangeTitle
                  ? TextFormField(
                      controller: TextEditingController()..text = '${!empty(value['title'])?value['title']:_name}',
                      decoration: InputDecoration(
                        errorText: !empty(widget.errorText)?widget.errorText!.lang():null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        ),
                      ),
                      onChanged: (val) {
                        _changeTitle(key, val);
                      },
                    )
                  : Text(
                  _name)),
          if (value['process'] == null)
            InkWell(
                child: Icon(Icons.close),
                onTap: () {
                  _removeFile(key);
                }),
          if (value['process'] != null)
            ValueListenableBuilder<double>(
                valueListenable: value['process'],
                builder: (_, process, child) {
                  if(process > 0 && process < 1) {
                    return Text((process * 100).ceil().toString() + '%');
                  }else if(process == 1){
                    return InkWell(
                        child: Icon(Icons.close),
                        onTap: () {
                          _removeFile(key);
                        });
                  }else{
                    return SizedBox();
                  }
                })
        ],
      ),
    );
  }

  _upload(dynamic file, [String? key, ValueNotifier<double>? process]) async {
    String _path = (file is PlatformFile)?file.path:file;
    final Map? _res = await upload(_path,
        fileName: _path.substring(_path.lastIndexOf('/') + 1),
        process: process??_process);
    if (_res != null) {
      if (widget.multipleUpload) {
        if(!empty(_res['path'])) {
          if (_otherFiles!.containsKey(key)) {
            _otherFiles![key]!['file'] = _res['path'];
            _otherFiles![key]!['image'] = _res['path'];
            _otherFiles![key]!['sortOrder'] = key;
            _otherFiles![key]!['title'] = _res['title'];
            _otherFiles![key]!.remove('filePath');
            _otherFiles![key]!.remove('process');
            setState(() {

            });
          }
        }else if(!empty(_res['error'])){
          if (_otherFiles!.containsKey(key)) {
            showMessage('${_otherFiles![key]!['title']} ${_res['error']}', type: 'ERROR');
            _otherFiles!.remove(key);
            setState(() {

            });
          }
        }
      } else {
        setState(() {
          _isSuccess = true;
        });
        if(!empty(_res['path'])) {
          widget.onChanged!(_res['path']);
        }else{
          showMessage('${_res['error']??'Thao tác thất bại!'.lang()}', type: 'ERROR');
        }
      }
    }
    return true;
  }

  _changeTitle(String key, String val) {
    _otherFiles![key]!['title'] = val;
    widget.onChanged!(_otherFiles);
  }

  Widget _convertIcon([String? fileName]) {
    if (fileName != null) {
      final String _ext = fileName.substring(fileName.lastIndexOf('.') + 1);
      IconData _iconData;
      switch (_ext) {
        case 'doc':
        case 'docx':
          _iconData = FontAwesomeIcons.fileWord;
          break;
        case 'xls':
        case 'xlsx':
          _iconData = FontAwesomeIcons.fileExcel;
          break;
        case 'ppt':
        case 'pptx':
          _iconData = FontAwesomeIcons.filePowerpoint;
          break;
        case 'pdf':
          _iconData = FontAwesomeIcons.filePdf;
          break;
        case 'rar':
        case 'zip':
        case '7z':
          _iconData = FontAwesomeIcons.fileArchive;
          break;
        case 'bmp':
        case 'png':
        case 'jpeg':
        case 'jpg':
          _iconData = FontAwesomeIcons.fileImage;
          break;
        case 'mov':
        case 'mp4':
        case 'flv':
        case 'mpeg':
        case 'avi':
          _iconData = FontAwesomeIcons.fileVideo;
          break;
        case 'mp3':
          _iconData = FontAwesomeIcons.fileAudio;
          break;
        default:
          _iconData = FontAwesomeIcons.file;
      }
      return Icon(
        _iconData,
        size: 18,
      );
    }
    return SizedBox();
  }

  _removeFile(String key) {
    if (widget.enabled) {
      if (widget.multipleUpload) {
        _otherFiles!.remove(key);
        int _index = 1;
        Map <String, Map> _fileTemps = {};
        _otherFiles!.forEach((k, v) {
          _fileTemps.addAll({
            '$_index': v
          });
          _index++;
        });
        _otherFiles = _fileTemps;
        if(widget.onChanged != null)widget.onChanged!(_otherFiles);
        setState(() {
          if (!empty(_files) && _files!.files.length == 0) {
            _isSuccess = false;
          }
        });
      } else {
        _process!.value = 0.0;
        setState(() {
          _isSuccess = false;
          _value = null;
        });
        if(widget.onChanged != null)widget.onChanged!(_value);
      }
      if (_files == null) {
        _process!.value = 0.0;
      }

    }
  }

  Widget _uploadFile() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        InkWell(
          onTap: () async {
            final _res = await PermissionLib().request(Permission.storage);
            if(_res) {
              await _choseFile();
            }
          },
          child: TextFormField(
            controller: TextEditingController()..text = _labelText!,
            enabled: false,
            maxLines: 1,
            decoration: _inputDecoration!.copyWith(
                errorText: (_errorText != null)?_errorText!.lang():null,
                errorStyle: TextStyle(color: Theme
                    .of(currentContext)
                    .errorColor),
                suffixIcon: ValueListenableBuilder<double>(
                    valueListenable: _process!,
                    builder: (_, process, child) {
                      if (process > 0) {
                        if (process < 1) {
                          return SizedBox(
                              width: 50,
                              child: Center(
                                  child: Text('${(process * 100).ceil()}%')));
                        } else {
                          return const SizedBox.shrink();
                        }
                      }
                      return !empty(widget.uploadFileView)?
                      widget.uploadFileView!:
                        IconButton(
                        onPressed: null,
                        icon:
                        const Icon(Icons.file_upload),
                      );
                    })),
          ),
        ),
        ValueListenableBuilder<double>(
            valueListenable: _process!,
            builder: (_, process, child) {
              if(process == 1) {
                if(_isSuccess) {
                  return IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _labelText = widget.labelText ?? 'Chọn file tải lên'.lang();
                      _removeFile('1');
                      widget.onChanged!('');
                    },
                  );
                }else{
                  return const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            })
      ],
    );
  }

  Widget _uploadMultiFiles() {
    List<Widget> _widgets = [];
    if(empty(_otherFiles)){
      if(!empty(_value) && _value is List){
        var _temp = {};
        _value.forEach((element){
          var index = _value.indexOf(element);
          if(empty(element['file'])){
            element['file'] = !empty(element['image']) ? element['image'] :'';
          }
          _temp.addAll({'$index':element});
          _otherFiles?.addAll({'$index':element});
        });
        _value = _temp;
      }
      else if(_value is Map){
        _value.forEach((k,v){
          if(empty(v['file'])){
            _value[k]['file'] = !empty(v['image']) ? v['image'] :'';
          }
          _otherFiles?.addAll({'$k':v});
        });
      }
      }
    if(!empty(_otherFiles)){
      _otherFiles!.forEach((k, v) {
        _widgets.add(_fileInfo(k, v));
      });
    }
    else if (!empty(_value) && _value is Map) {
      (_value as Map).forEach((k, v) {
        _widgets.add(_fileInfo(k, v));
      });
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_otherFiles != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _widgets
          ),
        if (widget.enabled)
          ButtonFlat(
              onPressed: () async{
                final _res = await PermissionLib().requests([Permission.storage]);
                if(_res) {
                  _choseFile();
                }
              },
              child: (widget.buttonBuilder != null)?widget.buttonBuilder!:Row(
                children: <Widget>[
                  const Icon(Icons.add),
                  Text('Thêm file'.lang()),
                ],
              )),
        if(widget.errorText != null)
          const SizedBox(height: 5),
        if(widget.errorText != null)
          Text('${widget.errorText}'.lang(),style: TextStyle(
            color: Theme.of(context).errorColor,
            fontSize: 12,
          ))
      ],
    );
  }
}
