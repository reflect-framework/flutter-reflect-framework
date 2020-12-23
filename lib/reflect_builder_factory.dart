import 'package:build/build.dart';

import 'reflect_builder_info.dart';

/// run from command line: flutter packages pub run build_runner build lib
Builder reflectInfoJsonBuilder(BuilderOptions builderOptions) => ReflectInfoJsonBuilder();