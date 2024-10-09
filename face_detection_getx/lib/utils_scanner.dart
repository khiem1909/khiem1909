// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
// import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';

class UtilsScanner
{
  UtilsScanner._();

  static Future<CameraDescription> getCamera(CameraLensDirection cameraLensDirection) async
  {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
              (CameraDescription cameraDescription) => cameraDescription.lensDirection == cameraDescription)
    );
  }
  static ImageRotation rotationInToImageRotation(int rotation)
  {
    switch(rotation)
    {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      default:
        assert(rotation == 270);
        return ImageRotation.rotation270;
    }
  }
  static Future<Uint8List> concatenatePlanes(List<Plane> planes)
  async {
    final WriteBuffer allBytes = WriteBuffer();

    for(Plane plane in planes)
      {
        allBytes.putUint8List(plane.bytes);
      }
    return allBytes.done().buffer.asUint8List();
  }
  static FirebaseVisionImageMetadata buildMetaData(CameraImage image, ImageRotation rotation)
  {
    return FirebaseVisionImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        rawFormat: image.format,
        planeData: image.planes.map((Plane plane)
        {
          return  FirebaseVisionImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height:plane.height,
              width: plane.width,
          );
        }).toList(),
    );
  }
  static Future<dynamic> detect({
    required CameraImage image, required Future<dynamic> Function(FirebaseVision image) detectInImage, required int imageRotation,}) async
  {
    return detectInImage(
      FirebaseVisionImage.fromBytes(
        concatenatePlanes(image.planes) as Uint8List,
      buildMetaData(image, rotationInToImageRotation(imageRotation)),
      ) as FirebaseVision,
    );
  }
}