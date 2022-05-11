import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper/system.dart';
import 'Loading.dart';

class WebViewer extends StatefulWidget {
  final String url;
  final String? backUrl;

  const WebViewer(this.url, {Key? key, this.backUrl}) : super(key: key);

  @override
  _WebViewerState createState() =>
      new _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  InAppWebViewController? webView;
  double progress = 0;
  Uri? statUrl;
  bool hasNavigation = false;
  String _time = '';
  bool onLoaded = false;

  @override
  void initState() {
    statUrl = Uri.parse(widget.url);
    _time = '${time()}';
    _init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  _init(){
    Future.delayed(Duration(seconds: 5),(){
      if(mounted && !onLoaded){
        setState(() {
          _time = '${time()}';
        });
        _init();
      }
    });
  }
  setWebView(InAppWebViewController controller){
    webView = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
          children: [
            InAppWebView(
              key: ValueKey('${widget.url}-$_time'),
              onReceivedServerTrustAuthRequest: (controller, url) async => ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED),
              initialUrlRequest: URLRequest(url: statUrl),
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                  )
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                setWebView(controller);
                log("onWebViewCreated");
              },
              onLoadError: (_, __, ___, ____){
                log("onLoadError");
                Future.delayed(const Duration(seconds: 2),(){
                  if(mounted)setState(() {
                    _time = '${time()}';
                  });
                });
              },
              onLoadHttpError: (_, __, ___, ____){
                log("onLoadHttpError");
                Future.delayed(const Duration(seconds: 2),(){
                  if(mounted)setState(() {
                    _time = '${time()}';
                  });
                });
              },
              onLoadStart: (controller, url) {
                onLoaded = true;
                if(mounted)setState(() {

                });
                log("onLoadStart");
                if (statUrl!.authority != url!.authority) {
                  hasNavigation = true;
                }
                if (hasNavigation && !empty(widget.backUrl) && Uri
                    .parse(widget.backUrl!)
                    .authority == url.authority) {
                  appNavigator.pop(url.toString());
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url;
                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri!.scheme)) {
                  if (await canLaunch(uri.toString())) {
                    await launch(
                      uri.toString(),
                    );
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onProgressChanged: (InAppWebViewController controller, int progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {},
            ),
            if(!onLoaded)const Loading(),
          ],
        )
    );
  }
}