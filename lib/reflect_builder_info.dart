import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:reflect_framework/reflect_info_json.dart';
import 'reflect_info_application.dart';

/// using main because that way we can simply debug:
/// - Read reflect_info.json
/// - create dart files

main() async {
  String jsonString = await File(
          'C:/Users/nilsth/AndroidStudioProjects/flutter-reflect-framework/.dart_tool/build/generated/reflect_framework/lib/reflect_info.combined.json')
      .readAsString();
  var json = jsonDecode(jsonString);
  _createReflectGeneratedLibFile(json);
}

const reflectGeneratedFile = 'reflect_generated.dart';
const reflectGeneratedPath = 'lib/' + reflectGeneratedFile;

void _createReflectGeneratedLibFile(json) {
  File file = File(reflectGeneratedPath);
  String dartCode = _createReflectGeneratedLibCode(json);
  file.writeAsString(dartCode);
}

String _createReflectGeneratedLibCode(json) {
  Library reflectGeneratedLib = _createReflectGeneratedLib(json);
  final emitter = DartEmitter(Allocator.simplePrefixing());
  String dartCode =
      DartFormatter().format('${reflectGeneratedLib.accept(emitter)}');
  return dartCode;
}

Library _createReflectGeneratedLib(json) {
  ReflectJson reflectJson = _readReflectInfoJsonFile(json);
  final generatedLib = Library(
      (b) => b.body.addAll([ApplicationInfoCodeFactory(reflectJson).create()]));
  return generatedLib;
  // ApplicationInfoCode applicationInfoCode=ApplicationInfoCode(reflectInfo);
  // List<ExecutableInfo> preProcessors=reflectInfo.findActionMethodPreProcessorFunctions();
  // List<ExecutableInfo> processors=reflectInfo.findActionMethodProcessorFunctions();
  // List<ClassInfo> serviceClasses= reflectInfo.findPotentialServiceClasses( preProcessors,processors);
  // ServiceClassesInfoCode serviceClassesInfoCode=ServiceClassesInfoCode(reflectInfo);
  // List<ServiceClassInfoCode> serviceClassInfoCodes=serviceClasses.map((s) => ServiceClassInfoCode(s));
  // List<ClassInfo> domainClasses= reflectInfo.findPotentialDomainClasses(serviceClasses);
  // List<DomainClassInfoCode> domainClassCodes=serviceClasses.map((s) => DomainClassInfoCode(s));
}

ReflectJson _readReflectInfoJsonFile(json) {
  return ReflectJson.fromJson(json);
}

///Uses the reflect_info.json file to generate a reflect_generated library with info classes
class ReflectInfoBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.combined.json': ['/../' + reflectGeneratedFile]
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      String jsonString = await buildStep.readAsString(buildStep.inputId);
      var json = jsonDecode(jsonString);

      String dartCode = _createReflectGeneratedLibCode(json);
      AssetId destination =
          AssetId(buildStep.inputId.package, reflectGeneratedPath);
      buildStep.writeAsString(destination, dartCode);
    } catch (exception, stacktrace) {
      print('$exception\n$stacktrace');
    }
  }


}
