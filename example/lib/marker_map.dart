import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_vnptmap_gl/flutter_vnptmap_gl.dart';

import 'app_config.dart';
import 'page.dart';

class MarkerMapPage extends VNPTMapExamplePage {
  const MarkerMapPage()
      : super(const Icon(Icons.place), 'Điểm & tương tác điểm');

  @override
  Widget build(BuildContext context) {
    return const CustomMarkerMap();
  }
}

class CustomMarkerMap extends StatefulWidget {
  const CustomMarkerMap();

  @override
  State createState() => CustomMarkerMapState();
}

class CustomMarkerMapState extends State<CustomMarkerMap> {
  late VNPTMapController _mapController;

  Bitmap? _markerIcon;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  int _markerIdCounter = 1;
  int _indexPosition = 0;
  MarkerId? selectedMarker;

  @override
  void dispose() {
    super.dispose();
  }

  void _onInfoWindowTapped(MarkerId markerId) {
    debugPrint("Did tap info window of " + markerId.toString());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("User tap on InfoWindow: $markerId"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 1),
    ));
  }

  void _onMarkerTapped(MarkerId markerId) {
    debugPrint("Did tap marker of " + markerId.toString());
    setState(() {
      selectedMarker = markerId;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Marker ${markerId.value} selected"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 1),
    ));
  }

  void _remove(MarkerId markerId) {
    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
      if (markerId == selectedMarker) {
        selectedMarker = null;
      }
    });
  }

  void _removeAll() {
    setState(() {
      markers = markers = <MarkerId, Marker>{};
      selectedMarker = null;
    });
  }

  void _add() {
    final int markerCount = markers.length;

    if (markerCount > 11) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      consumeTapEvents: true,
      markerId: markerId,
      position: _createCenter(),
      icon: Bitmap.defaultIcon,
      infoWindow: InfoWindow(
          snippet: "Marker id: $markerIdVal",
          title: "Test Marker",
          onTap: (MarkerId markerId) {
            _onInfoWindowTapped(markerId);
          }),
      onTap: (MarkerId markerId) {
        _onMarkerTapped(markerId);
      },
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  void _changePostion(MarkerId markerId) {
    if (_indexPosition >= 8) {
      _indexPosition = 0;
    }

    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        positionParam: LatLng(
          10.800302 + sin(_indexPosition * pi / 4.0) / 6.0 * 0.8,
          106.667398 + cos(_indexPosition * pi / 4.0) / 6.0,
        ),
      );
      _indexPosition += 1;
    });
  }

  Future<void> _changeInfo(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final String newSnippet = '${marker.infoWindow.snippet ?? ''} Updated';
    final String newTitle = '${marker.infoWindow.title ?? ''} Updated';
    setState(() {
      markers[markerId] = marker.copyWith(
        infoWindowParam: marker.infoWindow.copyWith(
          snippetParam: newSnippet,
          titleParam: newTitle,
        ),
        iconParam: _markerIcon,
      );
    });
  }

  void _onMapCreated(VNPTMapController controller) {
    _mapController = controller;
    // controller.addListener(() {
    // if (controller.isCameraMoving) {
    //   _updateMarkerPosition();
    // }
    // });
  }

  void _onStyleLoadedCallback() {
    debugPrint('onStyleLoadedCallback');
  }

  void _onMapLongClickCallback(Point<double> point, LatLng coordinates) {
    debugPrint('longClick at point: $point - location: $coordinates');
  }

  void _onCameraIdleCallback() {
    debugPrint('cameraIdle: ${_mapController.cameraPosition}');
  }

  @override
  Widget build(BuildContext context) {
    _createMarkerImageFromAsset(context);
    // _createMarkerImageFromBytes(context);
    final MarkerId? selectedId = selectedMarker;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 350,
            height: 500,
            child: VNPTMap(
              styleString:
                  AppConfig.BASE_MAPS_URL,
              accessToken: "",
              trackCameraPosition: true,
              onMapCreated: _onMapCreated,
              onMapLongClick: _onMapLongClickCallback,
              onCameraIdle: _onCameraIdleCallback,
              onStyleLoadedCallback: _onStyleLoadedCallback,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(10.800302, 106.667398), zoom: 9.0),
              markers: Set<Marker>.of(markers.values),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          TextButton(
                            child: const Text('add'),
                            onPressed: _add,
                          ),
                          TextButton(
                            child: const Text('remove all'),
                            onPressed:
                                markers.isEmpty ? null : () => _removeAll(),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          TextButton(
                              child: const Text('change info'),
                              onPressed: (selectedId == null)
                                  ? null
                                  : () => _changeInfo(selectedId)),
                          TextButton(
                            child: const Text('change position'),
                            onPressed: (selectedId == null)
                                ? null
                                : () => _changePostion(selectedId),
                          ),
                          TextButton(
                            child: const Text('remove'),
                            onPressed: (selectedId == null)
                                ? null
                                : () => _remove(selectedId),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _createCenter() {
    return _createLatLng(
      10.800302 + sin(_markerIdCounter * pi / 6.0) / 10.0 * 0.8,
      106.667398 + cos(_markerIdCounter * pi / 6.0) / 10.0,
    );
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);
      _markerIcon = await Bitmap.fromAssetImage(
          imageConfiguration, 'assets/images/ic_marker_tracking.png');
    }
  }

}
