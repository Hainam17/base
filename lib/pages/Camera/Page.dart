import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/widgets/Loading.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver{
  bool hasLoad = false;
  CameraController? controller;
  static List<CameraDescription> cameras = [];
  FlashMode? _flashMode;
  static Future getCamera()async{
    cameras = await availableCameras();
  }

  @override
  void initState() {
    _flashMode = FlashMode.off;
    _init();
    return super.initState();
  }
  void _init()async{
    // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Future.delayed(const Duration(seconds: 1));
    await getCamera();
    cameras.forEach((element) {
      if(element.lensDirection == CameraLensDirection.back){
        onNewCameraSelected(element);
      }
    });
    setState(() {
      hasLoad = true;
    });

  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    final cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {

      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      log(e.toString());
    }

    if (mounted) {
      setState(() {});
    }
  }


  @override
  void didChangeDependencies() {
    return super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: (hasLoad && controller != null)?Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: CameraPreview(
              controller!,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: IconButton(onPressed: (){
                        appNavigator.pop();
                      }, icon:const Icon(Icons.close)),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: IconButton(
                        icon:const Icon(Icons.flash_on),
                        color: (_flashMode == FlashMode.off)?null:Colors.blue,
                        onPressed: controller != null ? (){
                          setState(() {
                            _flashMode = (_flashMode == FlashMode.off)?FlashMode.always:FlashMode.off;
                          });
                          setFlashMode(_flashMode!);
                        } : null,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 5),
                    borderRadius: BorderRadius.circular(50)
                ),
                child: IconButton(onPressed: ()async{
                  final _res = await takePicture();
                  appNavigator.pop(_res);
                }, icon: const Icon(Icons.camera_alt)),
              ),
            ),
          )
        ],
      ):const Loading(),
    );
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (_) {
      rethrow;
    }
  }

  Future<String?> takePicture() async {
    final cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return null;
    }
    if (cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      var file = await cameraController.takePicture();
      return file.path;
    } on CameraException catch (_) {
      return null;
    }
  }
}
