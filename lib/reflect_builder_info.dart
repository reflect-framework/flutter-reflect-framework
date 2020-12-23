import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:reflect_framework/reflect_gui_action_method_pre_processor_info.dart';
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
        createActionMethodPreProcessorInfos(lib);
    for (ActionMethodPreProcessorInfo info in infos) {
      json.writeln(jsonEncode(info));
    }

    if (json.isNotEmpty)
      buildStep.writeAsString(destination, json.toString());
  }
}


