import 'package:reflect_framework/reflect_meta_action_method_pre_processor_context.dart';
import 'package:reflect_framework/reflect_meta_service_object.dart';

/// ## [ActionMethod]
///
/// [ActionMethod]s are methods in a [ServiceObject] or [DomainObject] that comply with a set of rules and are therefore recognized by the [ReflectFramework].
///
/// [ActionMethod]s are displayed as menu items in a [ReflectGuiApplication] or as commands in other types of [ReflectApplication]s.
///
/// A method needs to comply to the following rules to be considered a [ActionMethod] if:
/// - the method is in a [ServiceObject] or [DomainObject]
/// - and the method is public (method name does not start with an underscore)
/// - and there is a [ActionMethodPreProcessor] that can process the method parameter signature.
/// - and there is a [ActionMethodProcessor] that can process the method result.
///

class ActionMethod {
  //For documentation only
}

/// TODO explain what it does
///
/// The implementations of this class are generated by the [ReflectCodeGenerator]
abstract class ActionMethodInfo {
  /// gives the translated name of the [ActionMethod]
  String get name;

  /// returns if the [ActionMethod] is visible
  bool get visible;

  /// This method should only be called by menu items (for [ReflectGuiApplication]s) or external commands (for other types of [ReflectApplication]s
  /// It:
  /// - tries to create the parameter value(s) with [ActionMethodParameterFactory]'s
  /// - and then calls a [ActionMethodPreProcessor]
  /// - and then calls the [process] method (which might be delegated to a form ok or a dialog ok button)
  /// - it will handle any exceptions that could be thrown
  void preProcess(
      ActionMethodPreProcessorContext context, List methodParameterValues);

  /// This method should only be called by a [ActionMethodPreProcessor] (which might be delegated to a form ok or a dialog ok button)
  /// It:
  /// - invokes the method
  /// - and then calls the [ActionMethodProcessor] to process the results
  /// - it will handle any exceptions that could be thrown
  void process(
      ActionMethodPreProcessorContext context, List methodParameterValues);
}

/// [ServiceObjectActionMethod]s are displayed on the main menu of an [ReflectGuiApplication] or are commands that can be accessed from the outside world in other type of [ReflectApplications]
abstract class ServiceObjectActionMethodInfo extends ActionMethodInfo {
  ServiceObjectInfo get serviceObjectInfo;
}

/// TODO explain what it does
class ActionMethodParameterFactory {}
