import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:vhv_basic/import.dart';

class PDFCacheViewer extends StatefulWidget {
  final String url;
  final int currentPage;
  final String? title;
  final Function(int page, int total)? onPageChanged;
  final Function(int pages)? onRender;
  final bool hideRotateButton;

  const PDFCacheViewer( this.url, {Key? key, this.onPageChanged, this.currentPage = 1,
    this.title, this.hideRotateButton:false, this.onRender,}) : super(key: key);

  @override
  _PDFCacheViewerState createState() => _PDFCacheViewerState();
}

class _PDFCacheViewerState extends State<PDFCacheViewer> {
  int? _currentIndex;
  int? currentIndex;
  String? _subKey;
  @override
  void dispose() {
    factories.remove('pdfReloadCallback');
    super.dispose();
  }
  @override
  void initState() {
    factories['pdfReloadCallback'] = (){
      currentIndex = _currentIndex;
      _subKey = '${time()}';
      setState(() {});
    };
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        await SystemChrome.setPreferredOrientations(appOrientations);
        return true;
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          _PDFScreen(
            widget.url,
            onRender: widget.onRender,
            notRenderChanged: !empty(_subKey),
            currentPage: currentIndex??widget.currentPage,
            onPageChanged: (int page, int total) {
              _currentIndex = page;
              if(widget.onPageChanged != null){
                widget.onPageChanged!(page, total);
              }
            },
          ),
          if(!widget.hideRotateButton && widget.url.endsWith('.pdf'))IconButton(
              icon: Icon(Icons.screen_rotation),
              color: Colors.grey,
              onPressed: () async {
                if(MediaQuery.of(context).orientation == Orientation.landscape) {
                  await SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                }else {
                  await SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
                }
              }),
        ],
      ),
    );
  }
}

class _PDFScreen extends StatefulWidget {
  final String filePdf;
  final int currentPage;
  final Function(int pages)? onRender;
  final Function(int page, int total)? onPageChanged;
  final bool? notRenderChanged;

  const _PDFScreen(this.filePdf, {Key? key, this.currentPage = 1, this.onRender, this.onPageChanged, this.notRenderChanged}) : super(key: key);
  @override
  __PDFScreenState createState() => __PDFScreenState();
}

class __PDFScreenState extends State<_PDFScreen> {
  PdfController? _pdfController;
  String? filePath;
  int totalPages = 0;
  ValueNotifier<double> process = new ValueNotifier(0.0);

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    if(_pdfController != null) {
      _pdfController!.dispose();
    }
    process.dispose();
    super.dispose();
  }
  init()async{
    if(widget.filePdf.endsWith('.pdf')) {
      final _file = await createFileOfPdfUrl(widget.filePdf);
      filePath = _file;
      if (mounted && filePath != null) {
        _pdfController = PdfController(
          document: PdfDocument.openFile(filePath!),
          initialPage: widget.currentPage,
        );
        setState(() {

        });
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    if(!widget.filePdf.endsWith('.pdf')){
      return Material(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(lang('File không thể hiển thị lúc này!'), style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('${widget.filePdf.substring(widget.filePdf.lastIndexOf('/') + 1)}', textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.5)
              ))
            ],
          ),
        ),
      );
    }
    if(filePath != null) {
      if (filePath != '') {
        return Material(
          color: Colors.white,
          child: Center(
            child: PdfView(
              controller: _pdfController!,
              scrollDirection: Axis.vertical,
              onDocumentLoaded: (PdfDocument document) {
                totalPages = document.pagesCount;
                if (widget.onRender != null) widget.onRender!(document.pagesCount);
                if (widget.onPageChanged != null &&
                    !widget.notRenderChanged!) widget.onPageChanged!(widget.currentPage, document.pagesCount);
              },
              onPageChanged: (page) {
                if (widget.onPageChanged != null){
                  widget.onPageChanged!( page, totalPages);
                }
              },
            ),
          )
        );
      } else {
        return Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tải dữ liệu thất bại!'.lang(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ButtonFlat(child: Text(
                  'Thử lại'.lang(),
                ), onPressed: () {
                  init();
                })
              ],
            ),
          ),
        );
      }
    }else{
      return ValueListenableBuilder<double>(
          valueListenable: process,
          builder: (_, value, child){
            return Center(
              child: Text('${'Đang tải'.lang()} ${(value * 100).ceil()}%'),
            );
          });
    }
  }

  Future<String?> createFileOfPdfUrl(String url) async {
    try {
      final _res = await download(url, process: process);
      return _res;
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
  }
}