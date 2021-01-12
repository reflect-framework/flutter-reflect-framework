import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

import 'reflect_info_behavioural.dart';
import 'reflect_info_json.dart';

/// The [ReflectFramework] creates an [ApplicationInfo] class (with [ApplicationInfoCodeFactory]).

class ApplicationInfoCodeFactory {
  final ClassJson applicationClassJson;

  ApplicationInfoCodeFactory(ReflectJson reflectJson)
      : applicationClassJson = findApplicationClassJson(reflectJson);

  Class create() {
    Map pubSpecYaml = _readPubSpecYaml();
    return Class((b) => b
          ..name = 'ApplicationInfo'
          //..extend = refer('ClassInfo','package:reflect_framework/reflect_info_service.dart')
          ..methods.add(DisplayName.createMethod(applicationClassJson.type))
          ..methods
              .add(ImagePath.createMethod(applicationClassJson, pubSpecYaml))
        //TODO add version using pubSpecYaml
        //TODO add home page using pubSpecYaml?
        //TODO add dependencies using pubSpecYaml?
        //TODO add about page when clicking splashImage?
        );
  }

  Map _readPubSpecYaml() {
    File f = new File("pubspec.yaml");
    String yamlString = f.readAsStringSync();
    Map yaml = loadYaml(yamlString);
    return yaml;
  }

  static ClassJson findApplicationClassJson(ReflectJson reflectJson) {
    //TODO find classes that implement or extend Reflect(Gui)Application, throw error when more or less than 1, otherwise return found
    return reflectJson.classes.firstWhere((c) => c.type.name == 'MyFirstApp');
  }
}

/// A [ReflectGuiApplication] shows a [TitleImage] when no tabs are opened.
/// By default this is the [ReflectGuiApplication] name as a text (See generated ApplicationInfo.name).
/// A better alternative is to add a title image, e.g.:
/// * Your Application class is named: MyFirstApplication
/// * You have added a title image as assets\my_first_application.png
///   * Note that the file name is your Application class name in snake_case format.
///   * Note that you can use any accessible folder in your project, except the project root folder
///   * Note that you can use the following image file extensions: jpeg, webp, gif, png, bmp, wbmp
///   * Note that you can have add multiple image files for different resolutions and dark or light themes, see https://flutter.dev/docs/development/ui/assets-and-images)
/// * You have defined an asset with the path to your title image file in the flutter section of the pubspec.yaml file:
///     assets:
///     - assets/my_first_app.png
// TODO about page is shown when the title app is long or right clicked
class ImagePath {
  //TODO change in TitleImage?

  static Method createMethod(ClassJson applicationClassJson, Map pubSpecYaml) {
    String fileName = ReCase(applicationClassJson.type.name).snakeCase;
    String foundAsset = _findAssetPath(pubSpecYaml, fileName);
    // TODO if foundAsset show warning and add alternative (text?) vs (Image)?
    String code = "return '$foundAsset';";

    return Method((b) => b
      ..name = 'imagePath'
      ..type = MethodType.getter
      ..returns = refer('String')
      ..body = Code(code));
  }

  static String _findAssetPath(Map pubSpecYaml, String fileName) {
    List<String> assets = _findAssets(pubSpecYaml);
    RegExp imageAsset = RegExp(
        '/' + fileName + '\.(jpeg|webp|gif|png|bmp|wbmp)',
        caseSensitive: false);
    String found =
        assets.firstWhere((asset) => imageAsset.hasMatch(asset), orElse: null);
    return found;
  }

  static List<String> _findAssets(Map pubSpecYaml) {
    var flutter = pubSpecYaml['flutter'];
    if (flutter == null) {
      return const [];
    }
    YamlList assets = flutter['assets'];
    if (assets == null) {
      return const [];
    }
    return assets.map((asset) => asset.toString()).toList();
  }
}
