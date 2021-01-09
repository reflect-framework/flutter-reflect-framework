import 'dart:io';

// import 'package:reflect_framework/reflect_info_service.dart';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:reflect_framework/reflect_info_json.dart';

/// The [ReflectFramework] creates an ApplicationInfo class (with [ApplicationClassInfoCode]) that implement [ApplicationInfo] for all classes that are recognized as [ServiceObject]s.
class ApplicationInfoCode {
  ApplicationInfoCode(ReflectJson reflectInfo) {
    final lib = Library((b) => b.body.addAll([
          Class((b) => b
            ..name = 'ApplicationInfo'
            //..extend = refer('ClassInfo','package:reflect_framework/reflect_info_service.dart')
            ..methods.add(Method((b) =>
                b //TODO separate class with documentation
                  ..name = 'title'
                  ..type = MethodType.getter
                  ..returns = refer('String')
                  ..body = const Code(
                      "return 'My first app';"))) // TODO get from a RefelctApplication class annotation or  method as @translation or get TranslatebaleString (Something like [Intl.message]) from a method
            ..methods
                .add(Method((b) => b //TODO separate class with documentation
                  ..name = 'imagePath'
                  ..type = MethodType.getter
                  ..returns = refer('String')
                  ..body = const Code("return 'assets/my_first_app.png';"))))
          // TODO get from a RefelctApplication class annotation or  method

          ,
        ]));

    //TODO create class DartCode (with toString method?) and let this class extend it
    final emitter = DartEmitter(Allocator.simplePrefixing());
    String dartCode = DartFormatter().format('${lib.accept(emitter)}');

    File file = File('lib/reflect_generated.dart');
    file.writeAsString(dartCode);
  }
}
