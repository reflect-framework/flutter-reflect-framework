import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:reflect_framework/reflect_meta_action_method_pre_processor_info.dart';
import 'package:reflect_framework/reflect_meta_action_method_processor_info.dart';
import 'package:reflect_framework/reflect_meta_class_info.dart';
import 'package:source_gen/source_gen.dart';

///Uses [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ReflectInfoJsonBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.json']
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    AssetId source = buildStep.inputId;
    AssetId destination = source.changeExtension('.json');

    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final lib = LibraryReader(await buildStep.inputLibrary);

    ReflectInfo reflectInfo = ReflectInfo.fromLibrary(lib);

    if (reflectInfo.toJson().isNotEmpty) {
      var encoder = new JsonEncoder.withIndent("     ");
      String formattedJson = encoder.convert(reflectInfo);
      //TODO normally we use jsonEncode(reflectInfo)
      buildStep.writeAsString(destination, formattedJson);
    }
  }
}

///Used by the [ReflectInfoJsonBuilder] to create json files with meta data from source files using the source_gen package
class ReflectInfo {
  static const actionMethodPreProcessorsAttribute = 'actionMethodPreProcessors';
  static const actionMethodProcessorsAttribute = 'actionMethodProcessors';
  static const classesAttribute = 'classes';

  final List<ActionMethodPreProcessorInfo> actionMethodPreProcessors;
  final List<ActionMethodProcessorInfo> actionMethodProcessors;
  final List<ClassInfo> classes;
  //TODO functions (ending with factory in name, when needed for serviceobjects)
  //TODO add enums (with texts)
  //TODO add reflect texts

  ReflectInfo.fromLibrary(LibraryReader library)
      : this.actionMethodPreProcessors =
            createActionMethodPreProcessors(library),
        this.actionMethodProcessors = createActionMethodProcessors(library),
        this.classes = createClasses(library);

  ReflectInfo.fromJson(Map<String, dynamic> json)
      : actionMethodPreProcessors = json[actionMethodPreProcessorsAttribute],
        actionMethodProcessors = json[actionMethodProcessorsAttribute],
        classes = json[classesAttribute];

  Map<String, dynamic> toJson() => {
        if (actionMethodPreProcessors.isNotEmpty)
          actionMethodPreProcessorsAttribute: actionMethodPreProcessors,
        if (actionMethodProcessors.isNotEmpty)
          actionMethodProcessorsAttribute: actionMethodProcessors,
        if (classes.isNotEmpty) classesAttribute: classes,
      };
}
