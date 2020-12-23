import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
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
    StringBuffer json = StringBuffer();

    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final lib = LibraryReader(await buildStep.inputLibrary);

    List<ActionMethodPreProcessorInfo> infos =
        findActionMethodPreProcessorInfo(lib);
    for (ActionMethodPreProcessorInfo info in infos) {
      json.writeln(jsonEncode(info));
    }

    if (json.isNotEmpty)
      buildStep.writeAsString(destination, json.toString());
  }
}

List<ActionMethodPreProcessorInfo> findActionMethodPreProcessorInfo(
    LibraryReader library) {
  List<ActionMethodPreProcessorInfo> infos = [];
  for (Element element in library.allElements) {
    try {
      ActionMethodPreProcessorInfo info =
          ActionMethodPreProcessorInfo.fromElement(element);
      infos.add(info);
    } on Exception {
      // not a problem: not all elements are an ActionMethodPreProcessor function.
    }
  }
  return infos;
}

class ActionMethodPreProcessorInfo {
  final String path;
  final String functionName;
  final double priority;
  final String requiredAnnotation;
  final String parameterType;
  final bool parameterHasDomainClassAnnotation;

  ActionMethodPreProcessorInfo.fromElement(Element element)
      : path = element.source.fullName,
        functionName = element.name,
        priority = _priority(element),
        requiredAnnotation = _requiredAnnotation(element),
        parameterType = _parameterType(element),
        parameterHasDomainClassAnnotation =
            _parameterHasDomainClassAnnotation(element) {
    validate(element);
  }

  void validate(Element element) {
    if (element.kind != ElementKind.FUNCTION)
      throw Exception("Element is not a function.");
    if (!element.isPublic) throw Exception("Element is not public.");
    if (!_returnTypeVoid(element))
      throw Exception("Element function return type is not of type void.");
    if (!_hasActionMethodPreProcessorAnnotation(element))
      throw Exception(
          "Element function has not an ActionMethodPreProcessor annotation.");
    if (!_firstParameterIsActionMethodPreProcessorContext(element))
      throw Exception(
          "Element function first parameter is not of type ActionMethodPreProcessorContext.");
    if (!_has1Or2Parameters(element))
      throw Exception(
          "Element function has no, or more then 2 parameters.");
  }

  ActionMethodPreProcessorInfo.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        functionName = json['functionName'],
        priority = json['priority'],
        requiredAnnotation = json['requiredAnnotation'],
        parameterType = json['parameterType'],
        parameterHasDomainClassAnnotation =
            json['parameterHasDomainClassAnnotation'];

  Map<String, dynamic> toJson() => {
        'path': path,
        'functionName': functionName,
        'priority': priority,
        if (requiredAnnotation != null)
          'requiredAnnotation': requiredAnnotation,
        if (parameterType != null) 'parameterType': parameterType,
        if (parameterHasDomainClassAnnotation)
          'parameterHasDomainClassAnnotation': true
      };

  bool _returnTypeVoid(Element element) =>
      element.toString().startsWith('void ');

  bool _hasActionMethodPreProcessorAnnotation(Element element) =>
      element.metadata.toString().contains(
          '@ActionMethodPreProcessor* ActionMethodPreProcessor(double* priority)');

  bool _firstParameterIsActionMethodPreProcessorContext(Element element) {
    if (element is FunctionElement) {
      List<ParameterElement> parameters = element.parameters;
      if (parameters.isEmpty) {
        return false;
      }
      var parameterType = parameters[0].type.toString();
      return parameterType.startsWith('ActionMethodPreProcessorContext');
    }
    return false;
  }

  bool _has1Or2Parameters(Element element) {
    if (element is FunctionElement) {
      List<ParameterElement> parameters = element.parameters;
      return parameters.length>=1 && parameters.length<=2;
    }
    return false;
  }


  static double _priority(Element element) {
    for (ElementAnnotation e in element.metadata) {
      if (e.toString().startsWith('@ActionMethodPreProcessor')) {
        var dartObject = e.computeConstantValue();
        ConstantReader reader = ConstantReader(dartObject);
        return reader.peek('priority').doubleValue;
      }
    }
    final defaultWhenNotFound = 200.0;
    return defaultWhenNotFound;
  }

  static _requiredAnnotation(Element element) {
    for (ElementAnnotation e in element.metadata) {
      if (e.toString().startsWith('@RequiredActionMethodAnnotation')) {
        var dartObject = e.computeConstantValue();
        ConstantReader reader = ConstantReader(dartObject);
        return reader.peek('annotationName').stringValue;
      }
    }
    final defaultWhenNotFound = null;
    return defaultWhenNotFound;
  }

  static String _parameterType(Element element) {
    if (element is FunctionElement) {
      List<ParameterElement> parameters = element.parameters;
      if (parameters.length <= 1) {
        return null;
      }
      var parameterType = parameters[1].type;
      return parameterType.toString().replaceAll('*', '');
    }
    return null;
  }

  static bool _parameterHasDomainClassAnnotation(Element element) {
    if (element is FunctionElement) {
      List<ParameterElement> parameters = element.parameters;
      if (parameters.length <= 1) {
        return false;
      }
      var parameter = parameters[1];
      for (var annotation in parameter.metadata) {
        if (annotation.toString() == '@DomainClass* DomainClass()') return true;
      }
      return false;
    }
    return false;
  }

}
