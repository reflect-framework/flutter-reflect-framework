import 'package:reflect_framework/reflect_meta_action_method.dart';

///TODO explain what a [ServiceClass] is
/// [ServiceObject]s need to be preceded with a @[ServiceClass] annotation so the the [ReflectFramework] can find them.

class ServiceObject {
  ///For documentation only
}

/// Annotation
class ServiceClass {
  const ServiceClass();
}

/// [ServiceObjectActionMethod]s are displayed on the main menu of an [ReflectGuiApplication] or are commands that can be accessed from the outside world in other type of [ReflectApplications]

class ServiceObjectActionMethod extends ActionMethod {}
