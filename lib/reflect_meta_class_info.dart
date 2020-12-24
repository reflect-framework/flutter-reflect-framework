import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ClassInfo {
  static const pathAttribute = 'path';
  static const nameAttribute = 'name';
  static const annotationsAttribute = 'annotations';
  static const methodsAttribute = 'methods';
  static const propertiesAttribute = 'properties';

  final String path;
  final String name;
  final List<AnnotationInfo> annotations;
  final List<MethodInfo> methods;
  final List<PropertyInfo> properties;

  ClassInfo.fromElement(Element element)
      : path = element.source.fullName,
        name = element.name,
        annotations = [],
        methods = [],
        properties = [] {
    validate(element);
  }

  void validate(Element element) {
    if (element.kind != ElementKind.CLASS)
      throw Exception("Element is not a class.");
    if (!element.isPublic) throw Exception("Element is not public.");
    if (element.source.fullName.contains('lib/reflect_'))
      //domain classes and service classes are the only classes of interest
      throw Exception(
          "Element is part of a reflect library and is therefore ignored.");
  }

  ClassInfo.fromJson(Map<String, dynamic> json)
      : path = json[pathAttribute],
        name = json[nameAttribute],
        annotations = json[annotationsAttribute],
        methods = json[methodsAttribute],
        properties = json[propertiesAttribute];

  Map<String, dynamic> toJson() =>
      {
        pathAttribute: path,
        nameAttribute: name,
        if (annotations.isNotEmpty) annotationsAttribute: annotations,
        if (methods.isNotEmpty) methodsAttribute: methods,
        if (properties.isNotEmpty) propertiesAttribute: properties
      };
}

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
List<ClassInfo> createClasses(LibraryReader library) {
  List<ClassInfo> classes = [];
  for (Element element in library.allElements) {
    try {
      ClassInfo classInfo = ClassInfo.fromElement(element);
      classes.add(classInfo);
    } catch (e) {
      print(">>${element.library} ${element.name} $e");
      // not a problem: not all elements are an interesting classes.
    }
  }
  print(">>> ${classes.length}");
  return classes;

}

class AnnotationInfo {
  static const nameAttribute = 'name';
}

class MethodInfo {
  static const nameAttribute = 'name';
}

class PropertyInfo {
  static const nameAttribute = 'name';
}
