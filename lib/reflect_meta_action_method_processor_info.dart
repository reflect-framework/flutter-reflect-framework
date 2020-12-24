import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ActionMethodProcessorInfo {
  static const pathAttribute = 'path';
  static const functionNameAttribute = 'functionName';
  static const orderAttribute = 'order';
  static const requiredAnnotationAttribute = 'requiredAnnotation';
  static const parameterTypeAttribute = 'parameterType';
  static const parameterHasDomainClassAnnotationAttribute =
      'parameterHasDomainClassAnnotation';

  final String path;
  final String functionName;
  final double order;
  final String requiredAnnotation;
  final String parameterType;
  final bool parameterHasDomainClassAnnotation;

  ActionMethodProcessorInfo.fromElement(Element element)
      : path = element.source.fullName,
        functionName = element.name,
        order = _order(element),
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
    if (!_hasActionMethodProcessorAnnotation(element))
      throw Exception(
          "Element function has not an ActionMethodProcessor annotation.");
    if (!_firstParameterIsActionMethodPreProcessorContext(element))
      throw Exception(
          "Element function first parameter is not of type ActionMethodProcessorContext.");
    if (!_has1Or2Parameters(element))
      throw Exception("Element function has no, or more then 2 parameters.");
  }

  ActionMethodProcessorInfo.fromJson(Map<String, dynamic> json)
      : path = json[pathAttribute],
        functionName = json[functionNameAttribute],
        order = json[orderAttribute],
        requiredAnnotation = json[requiredAnnotationAttribute],
        parameterType = json[parameterTypeAttribute],
        parameterHasDomainClassAnnotation =
            json[parameterHasDomainClassAnnotationAttribute];

  Map<String, dynamic> toJson() => {
        pathAttribute: path,
        functionNameAttribute: functionName,
        orderAttribute: order,
        if (requiredAnnotation != null)
          requiredAnnotationAttribute: requiredAnnotation,
        if (parameterType != null) parameterTypeAttribute: parameterType,
        if (parameterHasDomainClassAnnotation)
          parameterHasDomainClassAnnotationAttribute: true
      };

  bool _returnTypeVoid(Element element) =>
      element.toString().startsWith('void ');

  bool _hasActionMethodProcessorAnnotation(Element element) =>
      element.metadata.toString().contains(
          '@ActionMethodProcessor* ActionMethodProcessor(double* priority)');

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
      return parameters.length >= 1 && parameters.length <= 2;
    }
    return false;
  }

  static double _order(Element element) {
    for (ElementAnnotation e in element.metadata) {
      if (e.toString().startsWith('@ActionMethodProcessor')) {
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

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
List<ActionMethodProcessorInfo> createActionMethodProcessors(
    LibraryReader library) {
  List<ActionMethodProcessorInfo> infos = [];
  for (Element element in library.allElements) {
    try {
      ActionMethodProcessorInfo info =
          ActionMethodProcessorInfo.fromElement(element);
      infos.add(info);
    } on Exception {
      // not a problem: not all elements are an ActionMethodProcessor function.
    }
  }
  return infos;
}
