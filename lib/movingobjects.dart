import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:ar_flutter_plugin/models/ar_anchor.dart';

class MovingObject {
  ARNode? webObjectNode;
  ARPlaneAnchor? webAnchor;
  vector_math.Vector3? position;
  vector_math.Vector3? rotation;
  List<bool>? isrotate;
  MovingObject(
      {required webObjectNode,
      required webAnchor,
      required position,
      required rotation,
      required isrotate})
      : position = position ?? vector_math.Vector3.zero(),
        rotation = rotation ?? vector_math.Vector3.zero(),
        isrotate = isrotate ?? [false, false, false];
}
