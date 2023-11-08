import 'package:flutter/material.dart';
import 'package:flutter_vnptmap_gl/flutter_vnptmap_gl.dart';
import 'package:flutter_vnptmap_gl_example/app_config.dart';

import 'page.dart';

class CameraMapPage extends VNPTMapExamplePage {
  const CameraMapPage()
      : super(const Icon(Icons.aspect_ratio), 'Tương tác bản đồ nền');

  @override
  Widget build(BuildContext context) {
    return const CameraMap();
  }
}

class CameraMap extends StatefulWidget {
  const CameraMap({Key? key}) : super(key: key);

  @override
  State<CameraMap> createState() => _CameraMapState();
}

class _CameraMapState extends State<CameraMap> {
  VNPTMapController? mapController;

  final ValueNotifier<CameraPosition?> _currentCameraPosition =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
  }

  void _onCameraIdleCallback() {
    _currentCameraPosition.value = mapController?.cameraPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          VNPTMap(
            styleString:
                AppConfig.BASE_MAPS_URL,
            accessToken: "",
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
                target: LatLng(10.800302, 106.667398), zoom: 15.0),
            onStyleLoadedCallback: _onStyleLoadedCallback,
            minMaxZoomPreference: const MinMaxZoomPreference(0.0, 19.0),
            trackCameraPosition: true,
            onCameraIdle: _onCameraIdleCallback,
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
            myLocationRenderMode: MyLocationRenderMode.COMPASS,
            onMapClick: (point, latLng) async {
              debugPrint(
                  "Map click: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");

              // Show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  duration: const Duration(seconds: 1),
                  content: Text(
                      "Map click: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}"),
                ),
              );
            },
            onMapLongClick: (point, latLng) async {
              debugPrint(
                  "Map long press: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}");

              // show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  duration: const Duration(seconds: 1),
                  content: Text(
                      "Map long press: ${point.x},${point.y}   ${latLng.latitude}/${latLng.longitude}"),
                ),

              );
            },
          ),
          // Container(
          //   color: Colors.teal[400],
          //   child: ValueListenableBuilder(
          //     builder: (context, value, _) {
          //       return Text('Current camera position is: ${value.toString()}');
          //     },
          //     valueListenable: _currentCameraPosition,
          //   ),
          // )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: "btn#3",
              child: const Icon(Icons.add),
              onPressed: () {
                mapController?.moveCamera(CameraUpdate.zoomIn()).then(
                    (result) => debugPrint(
                        "mapController.moveCamera() returned $result"));
              },
            ),
          ),
          FloatingActionButton(
            heroTag: "btn#4",
            child: const Icon(Icons.remove),
            onPressed: () {
              mapController?.moveCamera(CameraUpdate.zoomOut()).then((result) =>
                  debugPrint("mapController.moveCamera() returned $result"));
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: "btn#1",
              child: const Icon(Icons.animation),
              onPressed: () async {
                final LatLng? myLocation =
                    await mapController?.getMyLocationLatLng();
                if (myLocation != null) {
                  mapController
                      ?.animateCamera(
                        CameraUpdate.newLatLngZoom(myLocation, 15),
                        duration: const Duration(seconds: 3),
                      )
                      .then((result) => debugPrint(
                          "mapController.animateCamera() returned $result"));
                }
              },
            ),
          ),
          FloatingActionButton(
            heroTag: "btn#2",
            child: const Icon(Icons.my_location),
            onPressed: () async {
              final LatLng? myLocation =
                  await mapController?.getMyLocationLatLng();
              mapController
                  ?.moveCamera(CameraUpdate.newLatLngZoom(
                      myLocation ?? const LatLng(10.800302, 106.667398), 14.0))
                  .then((result) => debugPrint(
                      "mapController.moveCamera() returned $result"));
            },
          ),
        ],
      ),
    );
  }

  _onMapCreated(VNPTMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("VNPT Map Style loaded"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 1),
    ));
  }
}
