// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // ignore: unnecessary_import
import 'package:flutter_vnptmap_gl/flutter_vnptmap_gl.dart';
import 'package:flutter_vnptmap_gl_example/app_config.dart';

import 'page.dart';

class ScrollingMapPage extends VNPTMapExamplePage {
  const ScrollingMapPage() : super(const Icon(Icons.map), 'Scrolling map');

  @override
  Widget build(BuildContext context) {
    return const ScrollingMapBody();
  }
}

class ScrollingMapBody extends StatefulWidget {
  const ScrollingMapBody({Key? key}) : super(key: key);

  @override
  _ScrollingMapBodyState createState() => _ScrollingMapBodyState();
}

class _ScrollingMapBodyState extends State<ScrollingMapBody> {
  late VNPTMapController controllerOne;
  late VNPTMapController controllerTwo;

  final LatLng center = const LatLng(32.080664, 34.9563837);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text('This map consumes all touch events.'),
                ),
                Center(
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: VNPTMap(
                      styleString:
                          AppConfig.BASE_MAPS_URL,
                      accessToken: "ACCESS_TOKEN",
                      onMapCreated: onMapCreatedOne,
                      onStyleLoadedCallback: () => onStyleLoaded(controllerOne),
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 11.0,
                      ),
                      gestureRecognizers: <
                          Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              children: <Widget>[
                const Text('This map doesn\'t consume the vertical drags.'),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child:
                      Text('It still gets other gestures (e.g scale or tap).'),
                ),
                Center(
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: VNPTMap(
                      styleString:
                          "https://maps-dev.vnptit.vn/tileserver/styles/mapvnpt_v2/style.json",
                      accessToken: "ACCESS_TOKEN",
                      onMapCreated: onMapCreatedTwo,
                      onStyleLoadedCallback: () => onStyleLoaded(controllerTwo),
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 11.0,
                      ),
                      gestureRecognizers: <
                          Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => ScaleGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void onMapCreatedOne(VNPTMapController controller) {
    controllerOne = controller;
  }

  void onMapCreatedTwo(VNPTMapController controller) {
    controllerTwo = controller;
  }

  void onStyleLoaded(VNPTMapController controller) {
    debugPrint('VNPT Map style loaded!');
  }
}
