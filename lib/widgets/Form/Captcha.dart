import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class FormCaptcha extends StatefulWidget {
  final Function(String)? onChanged;
  final InputDecoration? decoration;
  final Function()? onTap;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final VoidCallback? onEditingComplete;
  final bool reloadInInit;
  final Function(VoidCallback)? buildReloadCaptcha;
  const FormCaptcha(
      {Key? key,
      this.onChanged,
      this.decoration,
      this.labelText,
      this.hintText,
      this.errorText,
      this.onTap,
      this.onEditingComplete,
      this.focusNode,
      this.reloadInInit = false,
      this.prefixIcon, this.buildReloadCaptcha})
      : super(key: key);

  @override
  _FormCaptchaState createState() => _FormCaptchaState();
}

class _FormCaptchaState extends State<FormCaptcha> {
  bool _loaded = false;
  bool _loading = false;
  late Widget _image;
  initState() {
    super.initState();
    _image = SizedBox();
    _loadCaptcha(true);
    if(widget.buildReloadCaptcha != null)widget.buildReloadCaptcha!(_loadCaptcha);
  }


  _loadCaptcha([bool init = false]) async{
    _loading = true;
    if(init && widget.reloadInInit){
      await post('${app['domain']}/api/Common/Captcha/getCaptcha', params: {
        'width': '150',
        'height': '50',
        'securityToken': csrfToken,
        'time': '${time()}',
        if(!empty(app['id']))'site': '${app['id']}'
      });
    }
    final _res = await post('${app['domain']}/api/Common/Captcha/getCaptcha', params: {
      'width': '150',
      'height': '50',
      'securityToken': csrfToken,
      'time': '${time()}',
      if(!empty(app['id']))'site': '${app['id']}'
    });
    if(_res != null) {
      RegExp _reExp = new RegExp(r"data:image/[^;]+;base64,",
          caseSensitive: false, multiLine: false);
      final _base64 = _res.replaceAll(_reExp, '');
      if(mounted){
        setState(() {
          _image = Image.memory(
            base64Decode(_base64),
            width: 150,
          );
          _loaded = true;
        });
      }
    }
    _loading = false;
  }
  @override
  void didChangeDependencies() {
    if(!_loaded && connectionStatus != ConnectivityStatus.offline){
      _loaded = true;
    }
    super.didChangeDependencies();
  }
  @override
  void didUpdateWidget(FormCaptcha oldWidget) {
    if(widget.errorText != null && oldWidget.errorText == null){
      _loadCaptcha();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if(!_loaded && !_loading && connectionStatus != ConnectivityStatus.offline){
      _loadCaptcha();
    }
    return Wrap(
      children: <Widget>[
          Stack(
            alignment: Alignment.centerRight,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: _image,
              ),
              IconButton(
                  icon: Icon(Icons.autorenew),
                  onPressed: () {
                    _loadCaptcha();
                  })
            ],
          ),
          SizedBox(
            height: 15,
            width: double.infinity,
          ),
          TextFormField(
          focusNode: widget.focusNode,
          decoration: widget.decoration??
              _inputDecoration(
                  errorText: widget.errorText,
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                  prefixIcon: widget.prefixIcon),
          onFieldSubmitted: (val) {
            widget.onChanged!(val);
          },
            onTap: widget.onTap,
          onChanged: (val) {
            widget.onChanged!(val);
          },
          enabled: (!_loaded || connectionStatus == ConnectivityStatus.offline)
              ? false
              : true,
          onSaved: (val) {
            widget.onChanged!(val!);
          },
          onEditingComplete: widget.onEditingComplete,
        ),
        // ( !empty(widget.errorText)) ? Text('${widget.errorText}',style: TextStyle(color: Colors.red)) : SizedBox()
      ],
    );
  }

  InputDecoration _inputDecoration(
      {String? errorText,
      String? labelText,
      String? hintText,
      String? helperText,
      Widget? prefixIcon}) {
    return InputDecoration(
        errorMaxLines: 2,
        errorText: !empty(errorText) ? errorText.toString().lang() : null,
        errorStyle: TextStyle(color: Theme.of(currentContext).errorColor),
        labelText: labelText ?? 'Mã xác thực'.lang(),
        helperText: helperText,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        hintText: hintText ?? 'Mã xác thực'.lang(),
        prefixIcon: (!_loaded || connectionStatus == ConnectivityStatus.offline)
            ? Container(
                width: 40,
                child: Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ))))
            : prefixIcon);
  }
}
