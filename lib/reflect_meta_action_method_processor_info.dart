import 'package:analyzer/dart/element/element.dart';
import 'package:reflect_framework/reflect_meta_json_info.dart';
import 'package:source_gen/source_gen.dart';

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ActionMethodProcessorInfo {
  static const typeAttribute = 'type';
  static const functionNameAttribute = 'functionName';
  static const orderAttribute = 'order';
  static const requiredAnnotationAttribute = 'requiredAnnotation';
  static const parameterTypeAttribute = 'parameterType';
  static const parameterHasDomainClassAnnotationAttribute =
      'parameterHasDomainClassAnnotation';

  final TypeInfo type;
  final double order;
  final String requiredAnnotation;
  final TypeInfo parameterType;
  final bool parameterHasDomainClassAnnotation;

  static bool isNeeded(Element element) {
    if (element.kind != ElementKind.FUNCTION) return false;
    if (!element.isPublic) return false;
    if (!_returnTypeVoid(element)) return false;
    if (!_hasActionMethodProcessorAnnotation(element)) return false;
    if (!_firstParameterIsActionMethodPreProcessorContext(element))
      return false;
    if (!_has1Or2Parameters(element)) return false;
    return true;
  }

  ActionMethodProcessorInfo.fromElement(Element element)
      : type = TypeInfo.fromElement(element),
        order = _order(element),
        requiredAnnotation = _requiredAnnotation(element),
        parameterType = _parameterType(element),
        parameterHasDomainClassAnnotation =
            _parameterHasDomainClassAnnotation(element) {
    isNeeded(element);
  }

  ActionMethodProcessorInfo.fromJson(Map<String, dynamic> json)
      : type = json[typeAttribute],
        order = json[orderAttribute],
        requiredAnnotation = json[requiredAnnotationAttribute],
        parameterType = json[parameterTypeAttribute],
        parameterHasDomainClassAnnotation =
            json[parameterHasDomainClassAnnotationAttribute];

  Map<String, dynamic> toJson() => {
        typeAttribute: type,
        orderAttribute: order,
        if (requiredAnnotation != null)
          requiredAnnotationAttribute: requiredAnnotation,
        if (parameterType != null) parameterTypeAttribute: parameterType,
        if (parameterHasDomainClassAnnotation)
          parameterHasDomainClassAnnotationAttribute: true
      };

  static bool _returnTypeVoid(Element element) =>
      element.toString().startsWith('void ');

  static bool _hasActionMethodProcessorAnnotation(Element element) =>
      element.metadata.toString().contains('@ActionMethodProcessor');

  static bool _firstParameterIsActionMethodPreProcessorContext(
      Element element) {
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

  static bool _has1Or2Parameters(Element element) {
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

  static TypeInfo _parameterType(Element element) {
    if (element is FunctionElement) {
      List<ParameterElement> parameters = element.parameters;
      if (parameters.length <= 1) {
        return null;
      }
      var parameterTypeElement = parameters[1].type.element;
      return TypeInfo.fromElement(parameterTypeElement);
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
  List<ActionMethodProcessorInfo> actionMethodProcessors = [];
  for (Element element in library.allElements) {
    if (ActionMethodProcessorInfo.isNeeded(element)) {
      ActionMethodProcessorInfo info =
          ActionMethodProcessorInfo.fromElement(element);
      actionMethodProcessors.add(info);
    }
  }
  return actionMethodProcessors;
}
