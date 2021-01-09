import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:reflect_framework/reflect_info_json.dart';

import 'reflect_info_application.dart';

/// using main because that way we can simply debug:
/// - Read reflect_info.json
/// - create dart files

main() async {
  String jsonString = await File('C:/Users/nilsth/AndroidStudioProjects/flutter-reflect-framework/.dart_tool/build/generated/reflect_framework/lib/reflect_info.combined.json').readAsString();
  var json = jsonDecode(jsonString);
  _createDartCode(json);
}

_createDartCode(json) async {
  ReflectJson reflectInfo = await _readReflectInfoJsonFile(json);
  ApplicationInfoCode(reflectInfo);
  //TODO add dart codes in a Library and store it in source
}

Future<ReflectJson> _readReflectInfoJsonFile(json) async {
  return ReflectJson.fromJson(json);
}

///Uses the reflect_info.json file to generate a reflect_generated library with info classes
class ReflectInfoBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.combined.json': [ReflectJson.libraryExtension]
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    String jsonString = await buildStep.readAsString(buildStep.inputId);
    var json=jsonDecode(jsonString);
    _createDartCode(json);
    // ApplicationInfoCode applicationInfoCode=ApplicationInfoCode(reflectInfo);

    // List<ExecutableInfo> preProcessors=reflectInfo.findActionMethodPreProcessorFunctions();
    //
    // List<ExecutableInfo> processors=reflectInfo.findActionMethodProcessorFunctions();
    //
    // List<ClassInfo> serviceClasses= reflectInfo.findPotentialServiceClasses( preProcessors,processors);
    //
    // ServiceClassesInfoCode serviceClassesInfoCode=ServiceClassesInfoCode(reflectInfo);
    //
    // List<ServiceClassInfoCode> serviceClassInfoCodes=serviceClasses.map((s) => ServiceClassInfoCode(s));
    //
    // List<ClassInfo> domainClasses= reflectInfo.findPotentialDomainClasses(serviceClasses);
    //
    // List<DomainClassInfoCode> domainClassCodes=serviceClasses.map((s) => DomainClassInfoCode(s));
    //
    //

    //TODO write dart code files;
  }
}
