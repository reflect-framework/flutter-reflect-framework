import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:reflect_framework/reflect_meta_json_info.dart';

/// Combines all .reflect_info.json files into one lib/reflect_info.json file
class CombiningReflectInfoBuilder implements Builder {
  @override
  final buildExtensions = const {
    r'$lib$': ['reflect_info.json']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    try {
      ReflectInfo combinedReflectInfo = ReflectInfo.empty();
      final exports =
          buildStep.findAssets(Glob('**/*${ReflectInfo.jsonExtension}'));
      await for (var exportLibrary in exports) {
        String jsonString = await buildStep.readAsString(exportLibrary);
        combinedReflectInfo.add(jsonString);
      }

      var encoder = new JsonEncoder.withIndent("     ");
      String formattedJson = encoder.convert(combinedReflectInfo);
      buildStep.writeAsString(
          AssetId(buildStep.inputId.package, 'lib/reflect_info.json'),
          formattedJson);
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }

    //
  }
}
