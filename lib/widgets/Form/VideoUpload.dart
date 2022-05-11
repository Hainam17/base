import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:vhv_basic/libs/PermissionLib.dart';

class FormVideoUpload extends StatefulWidget {
  final String? labelText;
  final String? errorText;
  final Widget? training;
  final bool enabled;
  final ValueChanged? onDone;
  final InputDecoration? decoration;

  const FormVideoUpload({Key? key, this.labelText, this.errorText, this.training,
    this.enabled = true, this.decoration, this.onDone}) : super(key: key);
  @override
  _FormVideoUploadState createState() => _FormVideoUploadState();
}

class _FormVideoUploadState extends State<FormVideoUpload> {
  final picker = ImagePicker();
  InputDecoration? _inputDecoration;
  String? _labelText;
  String? _errorText;
  ValueNotifier<double>? _process;
  @override
  void initState() {
    _errorText = widget.errorText;
    _labelText = widget.labelText ?? 'Chọn video tải lên2'.lang();
    _process = ValueNotifier<double>(0.0);
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
    super.initState();

  }
  _selectVideo()async{
    final _video = await picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _labelText = _video!.path.substring(_video.path.lastIndexOf('/') + 1);
    });
  }
//  picker.getImage(source: ImageSource.gallery)
  @override
  Widget build(BuildContext context) {
    return _uploadFile();
  }
  Widget _uploadFile() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        InkWell(
          onTap: () async {
            final _res = await PermissionLib().requests([Permission.storage, Permission.photos]);
            if(_res) {
              await _selectVideo();
            }
          },
          child: TextFormField(
            controller: TextEditingController()..text = _labelText??'',
            enabled: false,
            maxLines: 1,
            decoration: _inputDecoration!.copyWith(
                errorText: _errorText,
                suffixIcon: ValueListenableBuilder<double>(
                    valueListenable: _process!,
                    builder: (_, process, child) {
                      if (process > 0) {
                        if (process < 1) {
                          return Container(
                              width: 50,
                              child: Center(
                                  child: Text('${(process * 100).ceil()}%')));
                        } else {
                          return SizedBox();
                        }
                      }
                      return IconButton(
                        onPressed: null,
                        icon: Icon(Icons.file_upload),
                      );
                    })),
          ),
        ),
        ValueListenableBuilder<double>(
            valueListenable: _process!,
            builder: (_, process, child) {
              if(process == 1) {
                return IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _labelText = widget.labelText ?? 'Chọn file tải lên'.lang();
                  },
                );
              }
              return SizedBox();
            })
      ],
    );
  }
}
