import 'package:code_builder/code_builder.dart';
import 'package:reflect_framework/reflect_info_json.dart';


/// The [ReflectFramework] creates an [ApplicationInfo] class (with [ApplicationInfoCodeFactory]).

class ApplicationInfoCodeFactory {

  final ClassJson applicationClassJson;

  ApplicationInfoCodeFactory(ReflectJson reflectJson) : applicationClassJson=findApplicationClassJson(reflectJson);

  Class create() {
    return Class((b) => b
      ..name = 'ApplicationInfo'
    //..extend = refer('ClassInfo','package:reflect_framework/reflect_info_service.dart')
      ..methods.add(ApplicationDisplayName.createFor(applicationClassJson))
      ..methods.add(ApplicationImagePath.createFor(applicationClassJson))
    );
  }

  static findApplicationClassJson(ReflectJson reflectJson) {
    //TODO
  }
}


/// TODO create Generic DisplayName class with DartDoc and implement it here
class ApplicationDisplayName {
  static Method createFor(ClassJson applicationClassJson) {
    // TODO get from a RefelctApplication class
    // TODO make it translatable with @Translation notation and Translations

    return Method((b) => b
      ..name = 'displayName'
      ..type = MethodType.getter
      ..returns = refer('String')
      ..body = const Code("return 'My first app';"));
  }
}


/// TODO create Generic ImagePath class with DartDoc and implement it here
class ApplicationImagePath {

  static Method createFor(ClassJson applicationClassJson) {
    // TODO get from a RefelctApplication class annotation or  method

    return Method((b) => b //TODO separate class with documentation
      ..name = 'imagePath'
      ..type = MethodType.getter
      ..returns = refer('String')
      ..body = const Code("return 'assets/my_first_app.png';"));
  }
}