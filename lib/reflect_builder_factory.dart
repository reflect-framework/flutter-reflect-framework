import 'package:build/build.dart';
import 'package:reflect_framework/reflect_builder_info.dart';
import 'package:reflect_framework/reflect_builder_info_combined.dart';

/// run from command line: flutter packages pub run build_runner build lib --delete-conflicting-outputs

Builder reflectInfoJsonBuilder(BuilderOptions builderOptions) => ReflectInfoJsonBuilder();

Builder combiningReflectInfoBuilder(BuilderOptions builderOptions) => CombiningReflectInfoBuilder();