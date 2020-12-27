import 'package:flutter/widgets.dart' ;
import 'package:reflect_framework/reflect_meta_action_method.dart';

/// A [ActionMethodPreProcessor] does something with [ActionMethod] parameters, for a given method parameter signature, before the [ActionMethodProcessor] is called to process the method result.
///
/// [ActionMethodPreProcessor]s are functions that:
///  - are preceded with a [ActionMethodPreProcessor] annotation
///  - are public (function name does not start with underscore)
///  - with return type void
///  - with parameters: [ActionMethodPreProcessorContext] followed by zero or more parameters with the same type of the  [ServiceObjectActionMethod] that it supports.
///
///  The [ReflectCodeGenerator] will look for all the [ActionMethodPreProcessor]s. These will be used to generate [ActionMethodInfo]s.
///
/// See the annotated functions in this file for the default implementations and inspiration.

class ActionMethodPreProcessor {
  /// A number to set the order compared to other [ActionParameterAction]s.
  /// This becomes important if multiple [ActionParameterAction]s handle the same [Type]s and annotations
  /// A double is used so that there are endless numbers to put between to existing numbers.
  final double order;

  const ActionMethodPreProcessor(this.order);
}

class ActionMethodPreProcessorContext {
  final BuildContext buildContext;
  final ActionMethodInfo actionMethodInfo;

  ActionMethodPreProcessorContext(this.buildContext, this.actionMethodInfo);
}

/// Annotation if an [ActionMethod] needs to be annotated for a specific [ActionMethodPreProcessor] implementation.
class RequiredActionMethodAnnotation {
  final String annotationName;

  const RequiredActionMethodAnnotation(this.annotationName);
}

/// Annotation to indicate that [ActionMethodInfo.preProcess] needs to call [ActionMethodInfo.process] directly.
class ProcessDirectly {
  const ProcessDirectly();
}


