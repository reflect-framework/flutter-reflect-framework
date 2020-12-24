import 'package:reflect_framework/reflect_meta_action_method_pre_processor.dart';
import 'package:reflect_framework/reflect_meta_domain_object.dart';

@ActionMethodPreProcessor(100)
void executeDirectlyForMethodsWithoutParameter(
    ActionMethodPreProcessorContext context) {
  context.actionMethodInfo.process(context, []);
}

@ActionMethodPreProcessor(102)
void editDomainObjectParameterInForm(ActionMethodPreProcessorContext context,
    @DomainClass() Object domainObject) {
  // TODO something like:
  // tabs = Provider.of<Tabs>(context.buildContext);
  // FormTab formTab = FormTab(context, domainObject);
  // tabs.add(formTab);

  //TODO put in form OK button:
  context.actionMethodInfo.process(context, [domainObject]);
}
//TODO other Dart types such as int, double,num, bool, DateTime
@ActionMethodPreProcessor(103)
void editStringParameterInDialog(
    ActionMethodPreProcessorContext context, String value) {
  // TODO create and open dialog

  //TODO put in dialog OK button:
  context.actionMethodInfo.process(context, [value]);
}

@ActionMethodPreProcessor(150)
@RequiredActionMethodAnnotation("ProcessDirectly")
void executeDirectlyForMethodsWithProcessDirectlyAnnotation(
    ActionMethodPreProcessorContext context, Object anyObject) {
  context.actionMethodInfo.process(context, [anyObject]);
}

