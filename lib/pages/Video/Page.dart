import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/widgets/VideoPlayerAll.dart';

class VideoPage extends StatelessWidget {
  final String? videoUrl;
  final PreferredSizeWidget? appBar;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? footer;

  const VideoPage({Key? key, this.videoUrl, this.appBar, this.padding, this.header, this.footer}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double _topStart = 0;
    final ValueNotifier<bool> _showBack = ValueNotifier(true);
    bool _reset = false;
    int _second = 3;
    Future _future = Future.delayed(Duration(seconds: _second),(){
      _showBack.value = false;
    }).whenComplete((){
      _reset = true;
    });
    return Material(
      child: VideoPlayerAll(this.videoUrl, builder: (context, player){
        return GestureDetector(
          onTap: (){
            _showBack.value = true;
            _future.timeout(Duration(seconds: _second));
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(child: player),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ValueListenableBuilder<bool>(valueListenable: _showBack, builder: (_, value, child){
                      if(value){
                        if(_reset){
                          _reset = false;
                          _future = Future.delayed(Duration(seconds: _second),(){
                            _showBack.value = false;
                          }).whenComplete((){
                            _reset = true;
                          });
                        }else{
                          _future.timeout(Duration(seconds: _second));
                        }
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              color: Colors.black.withOpacity(0.2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 5),
                                  Text('Vuốt xuống để đóng video'.lang(), style: const TextStyle(fontSize: 18, color: Colors.white)),
                                  const SizedBox(height: 5),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        );
                      }else{
                        _future.timeout(const Duration(seconds: 0));
                      }
                      return const SizedBox.shrink();
                    }),
                  ),
                ),
                GestureDetector(
                  onVerticalDragStart: (DragStartDetails details){
                    _topStart = details.globalPosition.dy;
                  },
                  onVerticalDragUpdate: (DragUpdateDetails details){
                    if(details.globalPosition.dy - _topStart > 100){
                      appNavigator.pop();
                    }
                  },
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
