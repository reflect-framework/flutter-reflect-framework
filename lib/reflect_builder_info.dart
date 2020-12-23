import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:reflect_framework/reflect_gui_action_method_pre_processor_info.dart';
import 'package:reflect_framework/reflect_gui_action_method_processor_info.dart';
import 'package:source_gen/source_gen.dart';

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

    ReflectInfo reflectInfo=ReflectInfo.fromLibrary(lib);

    if (reflectInfo.toJson().isNotEmpty)
      buildStep.writeAsString(destination, jsonEncode(reflectInfo));
  }
}

class ReflectInfo {

  final List<ActionMethodPreProcessorInfo> actionMethodPreProcessorInfos;
  final List<ActionMethodProcessorInfo> actionMethodProcessorInfos;
  //TODO classInfos

  ReflectInfo.fromLibrary(LibraryReader library) :
      this.actionMethodPreProcessorInfos=createActionMethodPreProcessorInfos(library),
        this.actionMethodProcessorInfos=createActionMethodProcessorInfos(library);

  ReflectInfo.fromJson(Map<String, dynamic> json)
      : actionMethodPreProcessorInfos = json['actionMethodPreProcessorInfos'],
        actionMethodProcessorInfos = json['actionMethodProcessorInfos'];

  Map<String, dynamic> toJson() => {
    if (actionMethodPreProcessorInfos.isNotEmpty)
    'actionMethodPreProcessorInfos': actionMethodPreProcessorInfos,
    if (actionMethodProcessorInfos.isNotEmpty)
    'actionMethodProcessorInfos': actionMethodProcessorInfos,
  };
}


