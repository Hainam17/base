import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/libs/DioLib.dart';
import 'package:vhv_basic/widgets/ImageViewer.dart';
import 'package:vhv_basic/widgets/PDFCacheViewer.dart';
import 'package:vhv_basic/widgets/Webviewer.dart';

class ViewFilePage extends StatefulWidget {
  final dynamic params;
  const ViewFilePage(this.params, {Key? key}) : super(key: key);
  @override
  _ViewFilePageState createState() => _ViewFilePageState();
}

class _ViewFilePageState extends State<ViewFilePage> {
  String file = '';
  String? title;
  TextStyle? styleTitle;
  @override
  Widget build(BuildContext context) {
    file = widget.params!['file']??'';
    title = !empty(widget.params!['title']) ? widget.params!['title']:'';
    styleTitle = widget.params!['styleTitle'];
    if(file.isImageFileName){
      return _ImageViewer(image: file);
    }else{
      if(file.endsWith('.doc') || file.endsWith('.docx')
          || file.endsWith('.ppt') || file.endsWith('.pptx')
          || file.endsWith('.xls') || file.endsWith('.xlsx')
      ){
        String _file = urlConvert(file);
        file = 'https://docs.google.com/gview?url=${urlConvert(file)}&embedded=true';
        // file = 'https://view.officeapps.live.com/op/view.aspx?src=${urlConvert(file)}&embedded=true';
        return Scaffold(
          resizeToAvoidBottomInset: false,
          key: UniqueKey(),
          appBar: factories['header'](
              currentContext,
              title: Text(lang(!empty(title) ? title! :'File đính kèm'),style:styleTitle),
              actions: <Widget>[
                const SizedBox.shrink(),
                if(!empty(widget.params!['hasDownloadFile']))_DownloadButton(
                  file: _file,
                ),
              ]
          ),
          body: WebViewer(file),
        );
        // urlLaunch(file);
      }else if(file.endsWith('.pdf')){
        return Scaffold(
            key: ValueKey('${time()}'),
            appBar: Get.context!.orientation == Orientation.portrait?factories['header'](
                currentContext,
                title: Text(lang(!empty(title)?title!:'File đính kèm'),style:styleTitle),
                actions: <Widget>[
                  const SizedBox.shrink(),
                  if(!empty(widget.params!['hasDownloadFile']))_DownloadButton(
                    file: file,
                  ),
                ]
            ):null,
            body: SafeArea(child: PDFCacheViewer(urlConvert(file), key: UniqueKey()))
        );
      }else if(file.endsWith('.html')){
        return Scaffold(
            key: UniqueKey(),
            appBar: factories['header'](
                currentContext,
                title: Text(lang(!empty(title) ? title! :'File đính kèm'),style:styleTitle),
                actions: <Widget>[
                  const SizedBox.shrink(),
                  if(!empty(widget.params!['hasDownloadFile']))_DownloadButton(
                    file: file,
                  ),
                ]
            ),body: WebViewer(urlConvert(file)));
      }else{
        return Scaffold(
            key: UniqueKey(),
            appBar: factories['header'](
                currentContext,
                title: Text(lang(!empty(title) ? title! :'File đính kèm'),style:styleTitle),
                actions: <Widget>[
                  const SizedBox.shrink(),
                  if(!empty(widget.params!['hasDownloadFile']))_DownloadButton(
                    file: file,
                  ),
                ]
            ),body: WebViewer(urlConvert(file)));
      }
    }
  }
}
class _DownloadButton extends StatefulWidget {
  final String? file;
  const _DownloadButton({Key? key, this.file}) : super(key: key);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool hasDownload = false;
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_){
      if(!hasDownload) {
        return IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () async{
              setState(() {
                hasDownload = true;
              });
              showMessage('File đang được tải về');
              final _res = await download(urlConvert(widget.file!),
                  toDownloadFolder: true
              );
              if(_res != null){
                showMessage('Tải về thành công (${_res.substring(
                    _res.lastIndexOf('/') + 1)})', type: 'SUCCESS');
              }
            }
        );
      }
      return const SizedBox.shrink();
    });
  }
}
class _ImageViewer extends StatelessWidget {
  final String? image;
  const _ImageViewer({Key? key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: ImageViewer(
                  image!,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 15, top: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withOpacity(0.7)
                ),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: (){
                    appNavigator.pop();
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

