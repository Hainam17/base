import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
class FormGroup extends StatefulWidget{
  final String title;
  final String requireText;
  final Widget? child;
  final String? errorText;
  final bool required;
  final String? note;
  final bool notBold;
  final bool isCenter;
  final double paddingBottom;

  const FormGroup(this.title,{
    this.requireText:'',
    this.required: false,
    this.errorText,
    this.child, this.note, this.notBold: false, this.isCenter = false,
    this.paddingBottom = 10,
  });

  @override
  _FormGroupState createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  final UniqueKey __key = UniqueKey();
  String _key = '';
  @override
  void initState() {
    _key = '${(new DateTime.now()).microsecondsSinceEpoch}-${__key.toString()}';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('$_key-${widget.title}-${widget.child?.toStringShort()}-${widget.required}'),
      padding: EdgeInsets.only(bottom: widget.paddingBottom),
      child: Column(
        crossAxisAlignment: widget.isCenter?CrossAxisAlignment.center:CrossAxisAlignment.start,
        children: <Widget>[
          _label(context),
          _errorText(),
          widget.child!,
        ],
      ),
    );
  }

  Widget _errorText(){
    if(widget.errorText != null && widget.errorText != ''){
      return Column(
        children: <Widget>[
          SizedBox(height: 5),
          Semantics(
            container: true,
            liveRegion: true,
            child: Text(
              widget.errorText!.lang(),
              style: TextStyle(fontSize: 12, color: ThemeData.light().errorColor),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(height: 5),
        ],
      );
    }else{
      return SizedBox(height: 5);
    }
  }

  Widget _label(BuildContext context){
    if(widget.required == true){
      return RichText(
        textAlign: widget.isCenter?TextAlign.center:TextAlign.start,
        text: TextSpan(
            text: this.widget.title.lang(),
            style: Theme.of(context).textTheme.bodyText1,
            children: <TextSpan>[
              TextSpan(
                text: !empty(widget.requireText)?widget.requireText: ' (*)',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.red
                ),
              )
            ]
        ),
      );
    }else{
      return Text(
        this.widget.title.toString(),
        textAlign: widget.isCenter?TextAlign.center:TextAlign.start,
        style: TextStyle(
            fontWeight: (widget.notBold == false)?FontWeight.w500:FontWeight.normal,
            color: Theme.of(context).textTheme.bodyText1!.color
        ),
      );
    }
  }
}
