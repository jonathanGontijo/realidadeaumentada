import 'package:augmented_reality_plugin/augmented_reality_plugin.dart';
import 'package:flutter/material.dart';

class VirtualArViewScreen extends StatefulWidget {
  VirtualArViewScreen({super.key, this.clickedItemImageLink});

  String? clickedItemImageLink;

  @override
  State<VirtualArViewScreen> createState() => _VirtualArViewScreenState();
}

class _VirtualArViewScreenState extends State<VirtualArViewScreen> {
  @override
  Widget build(BuildContext context) {
    return AugmentedRealityPlugin(widget.clickedItemImageLink.toString());
  }
}
