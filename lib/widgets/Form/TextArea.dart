import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'dart:async';
import 'package:vhv_basic/widgets/HtmlViewer.dart';
import 'package:html_editor/html_editor.dart';

typedef CustomWidgetFunction = Widget Function(Widget child, Map attr);
class FormTextArea extends StatefulWidget {
  final String? value;
  final String? errorText;
  final String? labelText;
  final String? description;
  final ValueChanged? onChanged;
  final ValueChanged? onDone;
  final bool enabled;
  final bool? showBottomToolbar;
  final Function(String url)? onLinkTap;
  final Function(String url)? onImageTap;
  final double height;
  final String? customToolbar;
  final Map<String, CustomWidgetFunction>? customWidget;

  const FormTextArea({Key? key, this.value, this.errorText, this.labelText, this.showBottomToolbar,
    this.description, this.onChanged, this.enabled=true, this.height=200,
    this.customToolbar, this.onDone, this.customWidget, this.onLinkTap,
    this.onImageTap}) : super(key: key);
  @override
  _FormTextAreaState createState() => _FormTextAreaState();
}

class _FormTextAreaState extends State<FormTextArea> {
  String result = "";
  Timer? _timer;
  bool _showEdit = false;
  double heightKeyboard = 0;
  bool isReady = false;

  @override
  void didUpdateWidget(covariant FormTextArea oldWidget) {
    if(oldWidget.value != widget.value && widget.value != result){
      result = widget.value!;
    }
    if(widget.enabled == false && _showEdit == true){
      appNavigator.pop();
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void initState() {
    if(!empty(widget.value))result = widget.value!;
    super.initState();
  }
  _checkVal([String? val])async{
    if(val != null){
      if (val != result) {
        _convertVal(val);
        if (widget.onChanged != null)widget.onChanged!(result);
      }
    }
  }
  _convertVal(String? val){
    if (!empty(val)) {
      result = val!.replaceAll('src="${app['staticDomain']}/upload', 'src="/upload');
    } else {
      result = '';
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              constraints: BoxConstraints(
                minHeight: widget.height
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: !empty(widget.errorText)?Theme.of(context).errorColor:Color(0xFFCCCCCC), width: 1),
                  borderRadius: BorderRadius.circular(3)
              ),
              child: HTMLViewer(result,
                onLinkTap: widget.onLinkTap,
                onImageTap: widget.onImageTap,
                customRender: (widget.customWidget != null)?widget.customWidget!.map<String, CustomRenderFix>((k, v){
                  return MapEntry('$k', (RenderContext? context, Widget child, attr, element){
                    return v(child, attr);
                  });
                }):null
              )
            ),
            if(widget.enabled)Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: widget.enabled?_onEdit:null,
                child: SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                ),
              )
            ),
            if(widget.enabled && !empty(result))Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: widget.enabled?_onEdit:null,
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                  ),
                )
            ),
          ],
        ),
        if(widget.errorText != null)
          const SizedBox(height: 5),
        if(widget.errorText != null)
          Text('${widget.errorText}',style: TextStyle(
            color: Theme.of(context).errorColor,
            fontSize: 12,
          ))
      ],
    );
  }

  void _onDone() {
    if(widget.onDone != null) {
      widget.onDone!(result);
    }
  }
  void _onEdit()async{
    FocusScope.of(context).requestFocus(new FocusNode());
    _showEdit = true;
    showLoading();
    if(empty(Get.context!.isTablet)){
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await Future.delayed(Duration(seconds: 1));
    }
    await appNavigator.showFullDialog(
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.labelText??''}'),
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                child: Text(lang('Xong')),
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    color: Theme.of(context).toggleableActiveColor,
                    fontSize: 17
                  ),
                ),
                onPressed: (){
                  FocusScope.of(context).unfocus();
                  appNavigator.pop();
                },
              )
            ],
          ),
          body: Container(
            color: Theme.of(context).cardColor,
            child: HtmlEditor(
              hint: widget.description??"",
              value: result.replaceAll('src="/upload', 'src="${app['staticDomain']}/upload'),
              returnContent:(val){
                _checkVal(val);
              },
              onReady: (){
                disableLoading();
                isReady = true;
              },
            ),
          ),
        )
    );
    disableLoading();
    if(empty(Get.context!.isTablet)) {
      await SystemChrome.setPreferredOrientations(appOrientations);
    }
    _showEdit = false;
    _onDone();
  }
}
