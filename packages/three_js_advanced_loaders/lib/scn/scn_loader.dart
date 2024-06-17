import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:three_js_advanced_loaders/scn/bplist_parser.dart';
import 'package:three_js_advanced_loaders/scn/ns_unarchiver.dart';
import 'package:three_js_advanced_loaders/scn/platform_saveFile.dart';
import 'package:three_js_animations/three_js_animations.dart';
import 'package:three_js_core_loaders/three_js_core_loaders.dart';

class SCNLoader extends Loader {
  late final FileLoader _loader;

  /// [manager] — The [loadingManager] for the loader to use. Default is [DefaultLoadingManager].
  /// 
  /// Creates a new [FontLoader].
  SCNLoader({LoadingManager? manager}):super(manager){
    _loader = FileLoader(manager);
  }

  @override
  void dispose(){
    super.dispose();
    _loader.dispose();
  }

  void _init(){
    _loader.setPath(path);
    _loader.setResponseType('arraybuffer');
    _loader.setRequestHeader(requestHeader);
    _loader.setWithCredentials(withCredentials);
  }

  @override
  Future<AnimationObject?> fromNetwork(Uri uri) async{
    _init();
    ThreeFile? tf = await _loader.fromNetwork(uri);
    return tf == null?null:_parse(tf.data);
  }
  @override
  Future<AnimationObject?> fromFile(File file) async{
    _init();
    ThreeFile tf = await _loader.fromFile(file);
    return _parse(tf.data);
  }
  @override
  Future<AnimationObject?> fromPath(String filePath) async{
    _init();
    ThreeFile? tf = await _loader.fromPath(filePath);
    return tf == null?null:_parse(tf.data);
  }
  @override
  Future<AnimationObject?> fromBlob(Blob blob) async{
    _init();
    ThreeFile tf = await _loader.fromBlob(blob);
    return _parse(tf.data);
  }
  @override
  Future<AnimationObject?> fromAsset(String asset, {String? package}) async{
    _init();
    ThreeFile? tf = await _loader.fromAsset(asset,package: package);
    return tf == null?null:_parse(tf.data);
  }
  @override
  Future<AnimationObject?> fromBytes(Uint8List bytes) async{
    _init();
    ThreeFile tf = await _loader.fromBytes(bytes);
    return _parse(tf.data);
  }

  Future<AnimationObject?> _parse(Uint8List bufferBytes) async{
    // SaveFile.saveString(
    //   printName: 'scene2', 
    //   fileType: 'json', 
    //   data: NsUnarchiver.unarchiveObjectWithData(bufferBytes).toString()
    // );
    Map temp = BPlist.parseBuffer(bufferBytes);
    final keys = temp.keys.toList();
    print(temp[keys[1]].length);
    return null;
  }

  @override
  SCNLoader setPath(String path) {
    super.setPath(path);
    return this;
  }
}