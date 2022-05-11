import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class Maintenance extends StatefulWidget {
  const Maintenance({Key? key, this.message}) : super(key: key);
  final String? message;

  @override
  State<Maintenance> createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if(!empty(factories['logoApp']))...[
                  SvgViewer(
                    factories['logoApp'],
                    height: 35,
                  ),
                  const SizedBox(height: 50,),
                ],
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Center(
                      child: Image.asset('assets/images/maintenance.png', package: 'vhv_basic',),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Text(widget.message??'Hệ thống đang nâng cấp')
              ],
            ),
          ),
        ),
      ),
    );
    // return Scaffold(
    //   body: Center(
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         Image.asset('assets/images/maintenance.png', package: 'vhv_basic',),
    //       ],
    //     ),
    //   ),
    // );
  }
}
