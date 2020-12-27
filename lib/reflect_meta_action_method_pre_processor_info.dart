import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ActionMethodPreProcessorInfo {
  static const pathAttribute='path';
  static const functionNameAttribute='functionName';
  static const orderAttribute='order';
  static const requiredAnnotationAttribute='requiredAnnotation';
  static const parameterTypeAttribute='parameterType';
  static const parameterHasDomainClassAnnotationAttribute='parameterHasDomainClassAnnotation';

  final String path;
  final String functionName;
  final double order;
  final String requiredAnnotation;
  final String parameterType;
  final bool parameterHasDomainClassAnnotation;

  ActionMethodPreProcessorInfo.fromElement(Element element)
      : path = element.source.fullName,
        functionName = element.name,
        order = _order(element),
        requiredAnnotation = _requiredAnnotation(element),
        parameterType = _parameterType(element),
        parameterHasDomainClassAnnotation =
        _parameterHasDomainClassAnnotation(element) {
    validate(element);
  }

  void validate(Element element) { //TODO make static bool isNeeded() and move from constructor to factory
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

  bool _hasActionMethodPreProcessorAnnotation(Element element) =>
      element.metadata.toString().contains(
          '@ActionMethodPreProcessor');

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


  static double _order(Element element) {
    for (ElementAnnotation e in element.metadata) {
      if (e.toString().startsWith('@ActionMethodPreProcessor')) {
        var dartObject = e.computeConstantValue();
        ConstantReader reader = ConstantReader(dartObject);
        return reader.peek('order').doubleValue;
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
List<ActionMethodPreProcessorInfo> createActionMethodPreProcessors(
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
