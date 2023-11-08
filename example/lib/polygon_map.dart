import 'package:flutter/material.dart';
import 'package:flutter_vnptmap_gl/flutter_vnptmap_gl.dart';
import 'package:flutter_vnptmap_gl_example/app_config.dart';

import 'page.dart';

class PolygonMapPage extends VNPTMapExamplePage {
  const PolygonMapPage()
      : super(const Icon(Icons.auto_awesome_mosaic_sharp),
            'Vùng & tương tác vùng');

  @override
  Widget build(BuildContext context) {
    return const PolygonMapPageBody();
  }
}

class PolygonMapPageBody extends StatefulWidget {
  const PolygonMapPageBody();

  @override
  State<StatefulWidget> createState() => PolygonMapPageBodyState();
}

class PolygonMapPageBodyState extends State<PolygonMapPageBody> {
  VNPTMapController? controller;
  Map<PolygonId, Polygon> polygons = <PolygonId, Polygon>{};
  Map<PolygonId, double> polygonOffsets = <PolygonId, double>{};
  int _polygonIdCounter = 1;
  PolygonId? selectedPolygon;

  // Values when toggling polygon color
  int strokeColorsIndex = 0;
  int fillColorsIndex = 0;
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

  // Values when toggling polygon width
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];

  void _onMapCreated(VNPTMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolygonTapped(PolygonId polygonId) {
    setState(() {
      selectedPolygon = polygonId;
      print("selected polygon: " + polygonId.toString());
    });
  }

  void _remove(PolygonId polygonId) {
    setState(() {
      if (polygons.containsKey(polygonId)) {
        polygons.remove(polygonId);
      }
      selectedPolygon = null;
    });
  }

  void _add() {
    final int polygonCount = polygons.length;

    if (polygonCount == 12) {
      return;
    }

    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
    _polygonIdCounter++;
    final PolygonId polygonId = PolygonId(polygonIdVal);

    final Polygon polygon = Polygon(
      polygonId: polygonId,
      consumeTapEvents: true,
      strokeColor: Colors.red,
      fillColor: Colors.green,
      fillAlpha: 1.0,
      points: _createPoints(),
      onTap: (PolygonId polygonId) {
        _onPolygonTapped(polygonId);
      },
    );

    setState(() {
      polygonOffsets[polygonId] = _polygonIdCounter.ceilToDouble();
      polygons[polygonId] = polygon;
    });
  }

  void _addHoles(PolygonId polygonId) {
    final Polygon polygon = polygons[polygonId]!;
    setState(() {
      var holes = _createHoles(polygonId);
      polygons[polygonId] = polygon.copyWith(holesParam: holes);
    });
  }

  void _removeHoles(PolygonId polygonId) {
    final Polygon polygon = polygons[polygonId]!;
    setState(() {
      polygons[polygonId] = polygon.copyWith(
        holesParam: <List<LatLng>>[],
      );
    });
  }

  void _changeStokeColor(PolygonId polygonId) {
    final Polygon polygon = polygons[polygonId]!;
    setState(() {
      polygons[polygonId] = polygon.copyWith(
        strokeColorParam: colors[++strokeColorsIndex % colors.length],
      );
    });
  }

  void _changeFillColor(PolygonId polygonId) {
    final Polygon polygon = polygons[polygonId]!;
    setState(() {
      polygons[polygonId] = polygon.copyWith(
        fillColorParam: colors[++fillColorsIndex % colors.length],
      );
    });
  }

  void _changeAlpha(PolygonId polygonId) {
    final Polygon polygon = polygons[polygonId]!;
    setState(() {
      polygons[polygonId] = polygon.copyWith(
        fillAlphaParam: alphas[++fillColorsIndex % alphas.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final PolygonId? selectedId = selectedPolygon;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: double.infinity,
            height: 400.0,
            child: VNPTMap(
              styleString:
                  AppConfig.BASE_MAPS_URL,
              initialCameraPosition: const CameraPosition(
                target: LatLng(11.09628897915164, 106.09963226318358),
                zoom: 7.0,
              ),
              polygons: Set<Polygon>.of(polygons.values),
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
                          onPressed: (selectedId == null)
                              ? null
                              : () => _remove(selectedId),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('add holes'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _addHoles(selectedId),
                        ),
                        TextButton(
                          child: const Text('remove holes'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _removeHoles(selectedId),
                        ),
                        TextButton(
                          child: const Text('change stroke color'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _changeStokeColor(selectedId),
                        ),
                        TextButton(
                          child: const Text('change fill color'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _changeFillColor(selectedId),
                        ),
                        TextButton(
                          child: const Text('change alpha'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _changeAlpha(selectedId),
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
    );
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    final double offset = (_polygonIdCounter.ceilToDouble() - 1) / 4;
    points.add(_createLatLng(10.09628897915164 + offset, 106.09963226318358));
    points.add(_createLatLng(9.948785390273288 + offset, 106.08521270751953));
    points.add(_createLatLng(9.909828927635155 + offset, 106.22803497314453));
    points.add(_createLatLng(10.003245716502565 + offset, 106.31283569335938));
    points.add(_createLatLng(10.14510277154745 + offset, 106.20228576660156));
    points.add(_createLatLng(10.09628897915164 + offset, 106.09963226318358));
    return points;
  }

  List<List<LatLng>> _createHoles(PolygonId polygonId) {
    final List<List<LatLng>> holes = <List<LatLng>>[];
    final double offset = (polygonOffsets[polygonId]! - 1) / 4;

    final List<LatLng> hole1 = <LatLng>[];
    hole1.add(_createLatLng(10.102556286933407 + offset, 106.19370269775389));
    hole1.add(_createLatLng(10.058021127461473 + offset, 106.16280364990233));
    hole1.add(_createLatLng(10.05274222526572 + offset, 106.24897766113281));
    hole1.add(_createLatLng(10.102556286933407 + offset, 106.19370269775389));
    holes.add(hole1);

    final List<LatLng> hole2 = <LatLng>[];
    hole2.add(_createLatLng(10.055483506239545 + offset, 106.17070007324219));
    hole2.add(_createLatLng(10.00220588906289 + offset, 106.1710433959961));
    hole2.add(_createLatLng(10.008525929134183 + offset, 106.20022583007812));
    hole2.add(_createLatLng(10.043173858350652 + offset, 106.19267272949219));
    hole2.add(_createLatLng(10.055483506239545 + offset, 106.17070007324219));
    holes.add(hole2);

    return holes;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
