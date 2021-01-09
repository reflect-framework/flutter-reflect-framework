import 'package:reflect_framework/reflect_generated.dart';
import 'package:reflect_framework/reflect_meta_temp.dart';

// class ReflectFramework {
//   //For documentation only
// }

class ReflectFrameworkInfo {

  final ApplicationInfo application= ApplicationInfo();

  final List<ServiceObjectInfo> serviceObjects = [
    ServiceObjectInfo(title:"Login"),
    ServiceObjectInfo(title:"Orders")
  ];

}

///* Provides name of application
///* For graphical user interfaces
///   * Provides a optional title image
///   * Provides colors to be used
///* Allows to override utility classes eg:
///   * command line applications, rest-full web service applications and graphical user interface applications will have different ways to execute ActionMethods
abstract class ReflectApplication {

}



