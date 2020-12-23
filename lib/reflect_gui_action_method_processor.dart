import 'package:reflect_framework/reflect_gui_action_method_pre_processor.dart';
import 'package:reflect_framework/reflect_meta_domain_object.dart';

/// A [ActionMethodProcessor] processed the [ActionMethod] results (e.g. displays the results to the user or sends back an reply)
///
///  [ActionMethodProcessor]s are functions that:
///  - are preceded with a [ActionMethodProcessor] annotation
///  - are public (function name does not start with underscore)
///  - with return type void
///  - with parameters: [ActionMethodPreProcessorContext] followed by zero or more parameters with the same type of the  [ActionMethod] that it supports.
///
///  The [ReflectCodeGenerator] will look for all the [ActionMethodProcessor]s. These will be used to generate [ActionMethodInfo]s.
///
/// See the annotated functions in this file for the default implementations and inspiration.

class ActionMethodProcessor {
  /// A number to set the priority compared to other [ActionMethodProcessor]s.
  /// This becomes important if multiple [ActionParameterAction]s handle the same [Type]s and annotations
  /// A double is used so that there are endless numbers to put between to existing numbers.
  final double priority;

  const ActionMethodProcessor(this.priority);
}

@ActionMethodProcessor(100)
void showPopupTextForMethodsReturningVoid(
    ActionMethodPreProcessorContext context) {
  context.actionMethodInfo.process(context, []);
}

//TODO other dart types e.g. int, double, num, date/time
@ActionMethodProcessor(102)
void showStringInDialog(ActionMethodPreProcessorContext context, String value) {
  // tabs = Provider.of<Tabs>(context);
  // TODO
}

@ActionMethodProcessor(110)
void showDomainObjectInReadonlyFormTab(ActionMethodPreProcessorContext context,
    @DomainClass() Object domainObject) {
  // tabs = Provider.of<Tabs>(context.buildContext);
  // FormTab formTab = FormTab.readOnly(context, domainObject);
  // tabs.add(formTab);
}

//TODO other dart types e.g. stream, iterator, etc and for generic dart types e.g. int, double, date/time
@ActionMethodProcessor(111)
void showListInTableTab(ActionMethodPreProcessorContext context,
    @DomainClass() List<Object> domainObjects) {
  // tabs = Provider.of<Tabs>(context.buildContext);
  // FormTab formTab = FormTab.readOnly(context, domainObject);
  // tabs.add(formTab);
}
