import 'dart:async';
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_geometry/three_js_geometry.dart';
import 'package:three_js_postprocessing/three_js_postprocessing.dart';

class WebglPostprocessingSobel extends StatefulWidget {
  final String fileName;
  const WebglPostprocessingSobel({super.key, required this.fileName});

  @override
  createState() => _State();
}

class _State extends State<WebglPostprocessingSobel> {
  late three.ThreeJS threeJs;

  @override
  void initState() {
    threeJs = three.ThreeJS(
      onSetupComplete: (){setState(() {});},
      setup: setup,
      settings: three.Settings(
        useSourceTexture: true
      )
    );
    super.initState();
  }
  @override
  void dispose() {
    controls.dispose();
    threeJs.dispose();
    three.loading.clear();
    composer.reset(threeJs.renderTarget);
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

  late three.OrbitControls controls;
  late EffectComposer composer;

  Future<void> setup() async {
    threeJs.scene = three.Scene();

    threeJs.camera = three.PerspectiveCamera( 70, threeJs.width / threeJs.height, 0.1, 100 );
    threeJs.camera.position.setValues( 0, 1, 3 );
    threeJs.camera.lookAt( threeJs.scene.position );

    //

    final geometry = TorusKnotGeometry( 1, 0.3, 256, 32 );
    final material = three.MeshPhongMaterial.fromMap( { 'color': 0xffff00 } );

    final mesh = three.Mesh( geometry, material );
    threeJs.scene.add( mesh );

    final ambientLight = three.AmbientLight( 0xe7e7e7 );
    threeJs.scene.add( ambientLight );

    final pointLight = three.PointLight( 0xffffff, 2 );
    threeJs.camera.add( pointLight );
    threeJs.scene.add( threeJs.camera );

    // postprocessing

    composer = EffectComposer( threeJs.renderer!, threeJs.renderTarget );
    final renderPass = RenderPass( threeJs.scene, threeJs.camera );
    composer.addPass( renderPass );

    // color to grayscale conversion

    final effectGrayScale = ShaderPass.fromJson( luminosityShader );
    composer.addPass( effectGrayScale );

    // you might want to use a gaussian blur filter before
    // the next pass to improve the result of the Sobel operator

    // Sobel operator

    final effectSobel = ShaderPass.fromJson( sobelOperatorShader );
    effectSobel.uniforms[ 'resolution' ]['value'].x = threeJs.width * threeJs.dpr;
    effectSobel.uniforms[ 'resolution' ]['value'].y = threeJs.height * threeJs.dpr;
    composer.addPass( effectSobel );

    controls = three.OrbitControls( threeJs.camera, threeJs.globalKey );
    controls.enableZoom = false;

    threeJs.postProcessor = composer.render;

    threeJs.addAnimationEvent((dt){
      controls.update();
    });
  }
}
