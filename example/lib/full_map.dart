import 'package:flutter/material.dart';
import 'package:flutter_vnptmap_gl/flutter_vnptmap_gl.dart';
import 'package:flutter_vnptmap_gl_example/app_config.dart';

import 'page.dart';

class BaseMapPage extends VNPTMapExamplePage {
  const BaseMapPage() : super(const Icon(Icons.map), 'Bản đồ nền');

  @override
  Widget build(BuildContext context) {
    return const FullMap();
  }
}

class FullMap extends StatefulWidget {
  const FullMap({Key? key}) : super(key: key);

  @override
  State<FullMap> createState() => _FullMapState();
}

class _FullMapState extends State<FullMap> {
  VNPTMapController? mapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VNPTMap(
        styleString:
            AppConfig.BASE_MAPS_URL,
        accessToken: "",
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
            target: LatLng(10.800302, 106.667398), zoom: 10.0),
        onStyleLoadedCallback: _onStyleLoadedCallback,
        minMaxZoomPreference: const MinMaxZoomPreference(0.0, 20.0),
      ),
    );
  }

  _onMapCreated(VNPTMapController controller) {
    debugPrint('VNPT Map created!');
    mapController = controller;
  }

  _onStyleLoadedCallback() {
    debugPrint('VNPT Map style loaded!');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Style loaded"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 1),
    ));
  }
}
