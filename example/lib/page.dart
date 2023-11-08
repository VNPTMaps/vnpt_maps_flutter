import 'package:flutter/material.dart';

abstract class VNPTMapExamplePage extends StatelessWidget {
  const VNPTMapExamplePage(
    this.leading,
    this.title, {
    this.needsLocationPermission = true,
    super.key,
  });

  final Widget leading;
  final String title;
  final bool needsLocationPermission;
}
