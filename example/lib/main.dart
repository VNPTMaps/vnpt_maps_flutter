import 'package:flutter/material.dart';
import 'package:flutter_vnptmap_gl_example/camera_map.dart';
import 'package:flutter_vnptmap_gl_example/place_circle.dart';
import 'package:flutter_vnptmap_gl_example/polygon_map.dart';
import 'package:geolocator/geolocator.dart';

import 'animate_camera.dart';
import 'full_map.dart';
import 'map_ui.dart';
import 'page.dart';
import 'marker_map.dart';
import 'polyline_map.dart';
import 'raster_source.dart';

final List<VNPTMapExamplePage> _allPages = <VNPTMapExamplePage>[
  const BaseMapPage(),
  const MapUiPage(),
  const AnimateCameraPage(),
  const CameraMapPage(),
  const MarkerMapPage(),
  const PolylineMapPage(),
  const PolygonMapPage(),
  const PlaceCirclePage(),
  const RasterSourcePage(),
];

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> _pushPage(BuildContext context, VNPTMapExamplePage page) async {
    bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    print('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      print('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
     print(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VNPT Maps SDK examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: _allPages[index].leading,
          title: Text(_allPages[index].title),
          onTap: () => _pushPage(context, _allPages[index]),
        ),
      ),
    );
  }
}
