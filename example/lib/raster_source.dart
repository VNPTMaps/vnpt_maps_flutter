import 'package:flutter/material.dart';
import 'package:flutter_vnptmap_gl/flutter_vnptmap_gl.dart';
import 'package:flutter_vnptmap_gl_example/app_config.dart';

import 'page.dart';

class RasterSourcePage extends VNPTMapExamplePage {
  const RasterSourcePage() : super(const Icon(Icons.map), 'Raster source');

  @override
  Widget build(BuildContext context) {
    return const RasterSource();
  }
}

class RasterSource extends StatefulWidget {
  const RasterSource({Key? key}) : super(key: key);

  @override
  State<RasterSource> createState() => _RasterSourceState();
}

class _RasterSourceState extends State<RasterSource> {
  VNPTMapController? mapController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> addVector(VNPTMapController controller) async {
    await removeAll(controller);

    await controller.addSource(
        "vector-source",
        VectorSourceProperties(
          url: AppConfig.BASE_MAPS_URL,
        ));
  }

  Future<void> addRaster(VNPTMapController controller) async {
    await removeAll(controller);

    await controller.addSource(
      "raster-source",
      RasterSourceProperties(
        tiles: [AppConfig.BASE_MAPS_RASTER_URL],
      ),
    );
    await controller.addLayer(
        "raster-source", "raster-source", const RasterLayerProperties());
  }

  Future<void> removeAll(VNPTMapController controller) async {
    await controller.removeLayer("vector-source");
    await controller.removeSource("vector-source");

    await controller.removeLayer("raster-source");
    await controller.removeSource("raster-source");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(146, 0, 38, 55),
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                child: Image.asset("assets/images/ic_map_type_raster.png",
                    height: 50),
                onTap: () async {
                  await addRaster(mapController!);
                  setState(() {});
                },
              ),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                child: Image.asset("assets/images/ic_map_type_roadmap.png",
                    height: 50),
                onTap: () async {
                  await addVector(mapController!);
                  setState(() {});
                },
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
      body: VNPTMap(
        styleString: AppConfig.BASE_MAPS_URL,
        accessToken: "",
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
            target: LatLng(10.800302, 106.667398), zoom: 15.0),
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
