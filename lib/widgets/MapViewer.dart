// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vhv_basic/import.dart';
import 'package:flutter/material.dart';

class MapViewer extends StatefulWidget {
  final List? latlng;
  final List? currentLocation;
  final double zoom;
  final List? items;
  final String? address;
  final bool hasPicker;
  final Widget? centerIcon;
  final bool nestedList;

  const MapViewer(
      {Key? key,
      this.latlng,
      this.zoom = 7.0,
      this.items,
      this.currentLocation,
      this.address,
      this.hasPicker = false,
      this.centerIcon,
      this.nestedList = false})
      : super(key: key);

  @override
  _MapViewerState createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  LatLng? centerLocation;
  MapController? mapController;
  ValueNotifier<LatLng?>? valueNotifier;
  LatLng? _latlng;
  List<LatLng>? listLatLng;
  double _a = 20;

  @override
  initState() {
    valueNotifier = ValueNotifier(null);
    mapController = MapController();
    centerLocation = LatLng(0, 0);
    if (!widget.nestedList) {
      _latlng = (widget.latlng != null)
          ? LatLng(widget.latlng![0] ?? 0, widget.latlng![1] ?? 0)
          : LatLng(0, 0);
    } else {
      listLatLng = [];
      if (widget.latlng != null && widget.latlng is List) {
        for (var l in widget.latlng!) {
          listLatLng!.add(LatLng(double.tryParse(l[0].toString()) ?? 0,
              double.tryParse(l[1].toString()) ?? 0));
        }
      }
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant MapViewer oldWidget) {
    _latlng = (widget.latlng != null)
        ? LatLng(double.tryParse(widget.latlng![0].toString()) ?? 0,
            double.tryParse(widget.latlng![1].toString()) ?? 0)
        : LatLng(0, 0);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    late LatLng _current;
    num? distance;
    if (!empty(widget.currentLocation)) {
      _current = LatLng(parseDouble(widget.currentLocation![0]),
          parseDouble(widget.currentLocation![1]));
      centerLocation = _current;
    }
    if (!widget.nestedList) {
      if (widget.latlng != null && widget.currentLocation == null) {
        centerLocation = _latlng;
      }
    } else {
      centerLocation = listLatLng![0];
    }

    List addMaps = [
      {
        'image': 'assets/maps/VinhBacBo.png',
        'title': 'Vịnh Bắc Bộ',
        'width': 130.0,
        'height': 40.0,
        'location': LatLng(19.6648808, 107.4783274)
      },
      {
        'image': 'assets/maps/HoangSa.png',
        'title': 'Quần đảo\n Hoàng Sa(Việt Nam)',
        'width': 142.0,
        'height': 40.0,
        'location': LatLng(16.4871075, 111.6165039)
      },
      {
        'image': 'assets/maps/TruongSa.png',
        'title': 'Quần đảo\n Trường Sa(Việt Nam)',
        'width': 142.0,
        'height': 40.0,
        'location': LatLng(10.7233028, 115.8177107)
      },
      {
        'image': 'assets/maps/BienDong.png',
        'title': 'Biển Đông',
        'width': 80.0,
        'height': 30.0,
        'location': LatLng(14.2983143, 113.0197114)
      }
    ];
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        new FlutterMap(
          options: new MapOptions(
            center: centerLocation,
            zoom: widget.zoom,
            maxZoom: (widget.zoom + 1),
            minZoom: (widget.zoom - 1),
            onTap: (tapPosition, point) {
              if (widget.hasPicker) {
                setState(() {
                  _latlng = LatLng(point.latitude, point.longitude);
                });
//                mapController.move(LatLng(point.latitude, point.longitude), widget.zoom??7.0);
                valueNotifier!.value = LatLng(point.latitude, point.longitude);
              }
            },
          ),
          layers: [
            new TileLayerOptions(
                urlTemplate:
                    "https://server.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}",
                subdomains: ['a', 'b', 'c']),
            new TileLayerOptions(
                urlTemplate:
                    "https://tiles.arcgis.com/tiles/hkW6eGvd2CYWvCNM/arcgis/rest/services/Labels/MapServer/tile/{z}/{y}/{x}",
                subdomains: ['a', 'b', 'c'],
                backgroundColor: Colors.transparent),
            if (!widget.nestedList)
              new MarkerLayerOptions(
                markers: [
                  if(!empty(widget.latlng))Marker(
                    point: LatLng(widget.latlng![0], widget.latlng![1]),
                    builder: (ctx) => new Container(
                      child: const Icon(
                        Icons.control_point_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  if (!empty(widget.currentLocation))
                    Marker(
                      point: (!empty(widget.currentLocation) ? _current : null)!,
                      builder: (ctx) => new Center(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white)),
                          child:const Icon(FontAwesomeIcons.streetView,
                              color: Color(0xff41459B), size: 30),
                        ),
                      ),
                    )
                ]..addAll(((!empty(widget.items))
                    ? (widget.items!
                          ..removeWhere(
                              (element) => empty(element['location'])))
                        .map((e) {
                        List latlng = (e['location'] is List)
                            ? e['location']
                            : e['location'].toString().split(';');
                        if (!empty(latlng)) {
                          //latlng = [latlng[1], latlng[0]];
                        }

                        return new Marker(
                          width: 100.0,
                          // height: 25.0,
                          height: 55.0,
                          point: new LatLng(latlng[0] ?? 0, latlng[1] ?? 0),
                          builder: (ctx) => new Container(
                            child: InkWell(
                              onTap: () {
                                showBottomMenu(
                                    child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!empty(e['images']))
                                        Container(
                                          height: 150,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: e['images'].length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                const EdgeInsets.only(left: 5),
                                                child: ImageViewer(e['images']
                                                    [index]['image']),
                                              );
                                            },
                                          ),
                                        ),
                                      if (!empty(e['title'])) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          e['title'] ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                      ],
                                      if (!empty(e['standard'])) ...[
                                        const SizedBox(height: 5),
                                        RatingBarViewer(
                                          itemCount: 5,
                                          initialRating:
                                              parseDouble(e['standard']),
                                        )
                                      ],
                                    ],
                                  ),
                                ));
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding:const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.blue,
                                    ),
                                    child: Text(
                                      currency(
                                          parseDouble(e['afterTaxPrice'])
                                              .toStringAsFixed(0),
                                          useShort: true),
                                      style: TextStyle(
                                          color: Theme.of(context).cardColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              // child: Icon(Icons.location_on, size: 40, color: Colors.blue),
                            ),
                          ),
                        );
                      }).toList()
                    : [
                        if (widget.latlng != null)
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _latlng!,
                            builder: (ctx) =>
                                widget.centerIcon ??
                                    const Icon(
                                  Icons.my_location_rounded,
                                  size: 30,
                                  color: Colors.blue,
                                ),
                          ),
                      ]
                  ..addAll(addMaps.map<Marker>((e) {
                    return Marker(
                        width: e['width'],
                        // height: 25.0,
                        height: e['height'],
                        point: e['location'],
                        builder: (ctx) => Container(
                              // child: Text(e['title']),
                              child: Image.asset(
                                e['image'],
                                width: e['width'],
                                // height: 25.0,
                                package: 'vhv_basic',
                                height: e['height'],
                              ),
                            ));
                  }).toList()))),
              ),
            if (widget.nestedList) ...[
              MarkerLayerOptions(
                  markers: listLatLng!.map(
                (e) {
                  return new Marker(
                    width: 20.0,
                    height: 20.0,
                    point: e,
                    builder: (ctx) =>
                        widget.centerIcon ??
                            const Icon(
                          Icons.my_location_rounded,
                          size: 30,
                          color: Colors.blue,
                        ),
                  );
                },
              ).toList()),
            ],
            if (widget.latlng != null && distance != null)
              CircleLayerOptions(circles: [
                CircleMarker(
                    //radius marker
                    point: _latlng!,
                    color: distance < _a
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                    borderStrokeWidth: 3.0,
                    borderColor: distance < _a ? Colors.blue : Colors.red,
                    useRadiusInMeter: true,
                    radius: _a //radius
                    )
              ])
          ],
          mapController: mapController,
        ),
        if (widget.hasPicker)
          Align(
            alignment: Alignment.topRight,
            child: SafeArea(
              child: Container(
                margin:const EdgeInsets.only(top: 10, right: 15),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(50)),
                child: IconButton(
                  icon:const Icon(Icons.close),
                  onPressed: () {
                    appNavigator.pop();
                  },
                ),
              ),
            ),
          ),
        if (widget.hasPicker)
          SafeArea(
            child: ValueListenableBuilder(
                valueListenable: valueNotifier!,
                builder: (_, value, child) {
                  if (!empty(value)) {
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ButtonRaised(
                            child: Text('Xác nhận'.lang()),
                            onPressed: () {
                              appNavigator.pop(value);
                            },
                          )),
                    );
                  }
                  return const SizedBox.shrink();
                }),
          )
      ],
    );
  }
}
