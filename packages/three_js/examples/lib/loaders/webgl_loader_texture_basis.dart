import 'dart:async';

import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

class WebglLoaderTextureBasis extends StatefulWidget {
  final String fileName;
  const WebglLoaderTextureBasis({super.key, required this.fileName});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<WebglLoaderTextureBasis> {
  late three.ThreeJS threeJs;

  @override
  void initState() {
    threeJs = three.ThreeJS(
      
      onSetupComplete: (){setState(() {});},
      setup: setup
    );
    super.initState();
  }
  @override
  void dispose() {
    threeJs.dispose();
    three.loading.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: threeJs.build()
    );
  }

  Future<void> setup() async {
    
    threeJs.camera = three.PerspectiveCamera(60, threeJs.width / threeJs.height, 0.25, 20);
    threeJs.camera.position.setValues(-0.0, 0.0, 20.0);

    // scene

    threeJs.scene = three.Scene();

    final ambientLight = three.AmbientLight(0xcccccc, 0.4);
    threeJs.scene.add(ambientLight);
    threeJs.camera.lookAt(threeJs.scene.position);

    final geometry = three.PlaneGeometry(10, 10);
    final material = three.MeshBasicMaterial.fromMap({"side": three.DoubleSide});

    final mesh = three.Mesh(geometry, material);

    threeJs.scene.add(mesh);

    final loader = three.TextureLoader();
    loader.flipY = true;
    final texture = await loader.fromAsset("assets/textures/758px-Canestra_di_frutta_(Caravaggio).jpg");

    material.map = texture;
    material.needsUpdate = true;
  }
}
