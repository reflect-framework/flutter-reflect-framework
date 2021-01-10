import 'package:code_builder/code_builder.dart';
import 'reflect_info_behavioural.dart';
import 'reflect_info_json.dart';


/// The [ReflectFramework] creates an [ApplicationInfo] class (with [ApplicationInfoCodeFactory]).

class ApplicationInfoCodeFactory {

  final ClassJson applicationClassJson;

  ApplicationInfoCodeFactory(ReflectJson reflectJson) : applicationClassJson=findApplicationClassJson(reflectJson);

  Class create() {
    return Class((b) => b
      ..name = 'ApplicationInfo'
    //..extend = refer('ClassInfo','package:reflect_framework/reflect_info_service.dart')
      ..methods.add(DisplayName.createMethod(applicationClassJson.type))
      ..methods.add(ApplicationImagePath.createFor(applicationClassJson))
    );
  }

  static ClassJson findApplicationClassJson(ReflectJson reflectJson) {
    //TODO find classes that implement or extend Reflect(Gui)Application, throw error when more or less than 1, otherwise return found
    return reflectJson.classes.firstWhere((c) => c.type.name=='MyFirstApp');
  }
}

/// TODO create Generic ImagePath class with DartDoc and implement it here (See [DisplayName.createMethod(typeJson)])
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