import 'package:flutter/material.dart';
import 'package:flutter_vnptmap_gl/flutter_vnptmap_gl.dart';
import 'package:flutter_vnptmap_gl_example/app_config.dart';

import 'page.dart';

class PolylineMapPage extends VNPTMapExamplePage {
  const PolylineMapPage()
      : super(const Icon(Icons.gesture), 'Đường & tương tác đường');

  @override
  Widget build(BuildContext context) {
    return const PlacePolylineMap();
  }
}

class PlacePolylineMap extends StatefulWidget {
  const PlacePolylineMap();

  @override
  State createState() => PlacePolylineMapState();
}

class PlacePolylineMapState extends State<PlacePolylineMap> {
  VNPTMapController? controller;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};

  int _polylineIdCounter = 1;
  PolylineId? selectedPolyline;

  // Values when toggling polyline color
  int colorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
  ];

  List<double> alphas = <double>[
    0.2,
    0.5,
    0.8,
    1.0,
  ];

  // Values when toggling polyline width
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];

  void _onMapCreated(VNPTMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolylineTapped(PolylineId polylineId) {
    setState(() {
      selectedPolyline = polylineId;
    });
  }

  void _remove(PolylineId polylineId) {
    setState(() {
      if (polylines.containsKey(polylineId)) {
        polylines.remove(polylineId);
      }
      selectedPolyline = null;
    });
  }

  void _add() {
    final int polylineCount = polylines.length;

    if (polylineCount == 12) {
      return;
    }

    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.red,
      width: 5,
      points: _createPoints(),
      onTap: (PolylineId polylineId) {
        _onPolylineTapped(polylineId);
      },
    );

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  void _changeColor(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        colorParam: colors[++colorsIndex % colors.length],
      );
    });
  }

  void _changeAlpha(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        alphaParam: alphas[++colorsIndex % alphas.length],
      );
    });
  }

  void _changeWidth(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        widthParam: widths[++widthsIndex % widths.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: double.infinity,
            height: 450.0,
            child: VNPTMap(
              styleString:
                  AppConfig.BASE_MAPS_URL,
              initialCameraPosition: const CameraPosition(
                target: LatLng(14.63, 111.13),
                zoom: 5.0,
              ),
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: _onMapCreated,
            ),
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
                          child: const Text('remove'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : () => _remove(selectedPolyline!),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('change width'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : () => _changeWidth(selectedPolyline!),
                        ),
                        TextButton(
                          child: const Text('change color'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : () => _changeColor(selectedPolyline!),
                        ),
                        TextButton(
                          child: const Text('change alpha'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : () => _changeAlpha(selectedPolyline!),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    final double offset = _polylineIdCounter.ceilToDouble();
    points.add(_createLatLng(10.6616 + offset, 106.4309 + offset));
    points.add(_createLatLng(11.1067 + offset, 106.306 + offset));
    points.add(_createLatLng(10.629 + offset, 107.1342 + offset));
    points.add(_createLatLng(10.1529 + offset, 106.852 + offset));
    points.add(_createLatLng(10.2305 + offset, 106.1329 + offset));
    return points;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
