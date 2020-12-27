import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ClassInfo {
  static const pathAttribute = 'path';
  static const nameAttribute = 'name';
  static const annotationsAttribute = 'annotations';
  static const methodsAttribute = 'methods';
  static const propertyAccessorAttribute = 'propertyAccessors';

  final String path;
  final String name;
  final List<AnnotationInfo> annotations;
  final List<MethodInfo> methods;
  final List<PropertyAccessorInfo> propertyAccessors;

  ClassInfo.fromElement(Element element)
      : path = element.source.fullName,
        name = element.name,
        annotations = _createAnnotations(element),
        methods = _createMethods(element),
        propertyAccessors = _createPropertyAccessor(element);

  static bool isNeeded(ClassElement element) {
    if (!element.isPublic) return false;
    if (element.source.fullName.contains('lib/reflect_'))
      //domain classes and service classes are the only classes of interest
      return false;
    return true;
  }

  ClassInfo.fromJson(Map<String, dynamic> json)
      : path = json[pathAttribute],
        name = json[nameAttribute],
        annotations = json[annotationsAttribute],
        methods = json[methodsAttribute],
        propertyAccessors = json[propertyAccessorAttribute];

  Map<String, dynamic> toJson() => {
        pathAttribute: path,
        nameAttribute: name,
        if (annotations.isNotEmpty) annotationsAttribute: annotations,
        if (methods.isNotEmpty) methodsAttribute: methods,
        if (propertyAccessors.isNotEmpty)
          propertyAccessorAttribute: propertyAccessors
      };
}

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
List<ClassInfo> createClasses(LibraryReader library) {
  List<ClassInfo> classes = [];
  for (Element element in library.allElements) {
    if (element is ClassElement && ClassInfo.isNeeded(element)) {
      ClassInfo classInfo = ClassInfo.fromElement(element);
      classes.add(classInfo);
    }
  }
  return classes;
}

class AnnotationInfo {
  static const nameAttribute = 'name';
  static const valuesAttribute = 'values';

  final String name;
  final Map<String, Object> values;

  AnnotationInfo.fromElement(ElementAnnotation annotationElement)
      : name = _name(annotationElement),
        values = _values(annotationElement);

  AnnotationInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        values = json[valuesAttribute];

  Map<String, dynamic> toJson() =>
      {nameAttribute: name, if (values.isNotEmpty) valuesAttribute: values};

  static _name(ElementAnnotation annotationElement) {
    return annotationElement.computeConstantValue().type.element.name;
  }

  static Map<String, Object> _values(ElementAnnotation annotationElement) {
    List<ParameterElement> parameters =
        (annotationElement.element as ConstructorElement).parameters;
    var dartObject = annotationElement.computeConstantValue();
    ConstantReader reader = ConstantReader(dartObject);

    return {
      for (ParameterElement parameter in parameters)
        parameter.name: reader.peek(parameter.name).literalValue,
    };
  }
}

List<AnnotationInfo> _createAnnotations(Element element) {
  List<AnnotationInfo> annotations = [];
  if (element is ClassElement) {
    List<ElementAnnotation> annotationElements = element.metadata;
    for (ElementAnnotation annotationElement in annotationElements) {
      AnnotationInfo annotation = AnnotationInfo.fromElement(annotationElement);
      annotations.add(annotation);
    }
  }
  return annotations;
}

class MethodInfo {
  static const nameAttribute = 'name';

  final String name;

  MethodInfo.fromElement(MethodElement methodElement)
      : name = methodElement.name;

  MethodInfo.fromJson(Map<String, dynamic> json) : name = json[nameAttribute];

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
      };

  static bool isNeeded(MethodElement methodElement) {
    if (methodElement.isPrivate) {
      return false;
    }
    return true;
  }
}

List<MethodInfo> _createMethods(Element element) {
  List<MethodInfo> methods = [];
  if (element is ClassElement) {
    List<MethodElement> methodsElements = element.methods;
    for (MethodElement methodElement in methodsElements) {
      if (MethodInfo.isNeeded(methodElement)) {
        MethodInfo method = MethodInfo.fromElement(methodElement);
        methods.add(method);
      }
    }
  }
  return methods;
}

class PropertyAccessorInfo {
  static const nameAttribute = 'name';

  final String name;

  PropertyAccessorInfo.fromElement(
      PropertyAccessorElement propertyAccessorElement)
      : name = propertyAccessorElement.name;

  PropertyAccessorInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute];

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
      };

  static bool isNeeded(PropertyAccessorElement propertyAccessorElement) {
    if (propertyAccessorElement.isPrivate) {
      return false;
    }
    return true;
  }
}

List<PropertyAccessorInfo> _createPropertyAccessor(Element element) {
  List<PropertyAccessorInfo> propertyAccessors = [];
  if (element is ClassElement) {
    List<PropertyAccessorElement> propertyAccessorElements = element.accessors;
    for (PropertyAccessorElement propertyAccessorElement
        in propertyAccessorElements) {
      if (PropertyAccessorInfo.isNeeded(propertyAccessorElement)) {
        PropertyAccessorInfo propertyAccessor =
            PropertyAccessorInfo.fromElement(propertyAccessorElement);
        propertyAccessors.add(propertyAccessor);
      }
    }
  }
  return propertyAccessors;
}
