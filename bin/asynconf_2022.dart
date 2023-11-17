import 'package:args/args.dart';

import 'algorithms/base.dart';
import 'algorithms/five/base.dart';
import 'algorithms/four.dart';
import 'algorithms/one.dart';
import 'algorithms/tests.dart';
import 'algorithms/three/base.dart';
import 'algorithms/two.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    )

    ..addCommand(
        'run',
        ArgParser()
          ..addOption(
              'algorithm',
              abbr: 'a',
              help: 'Algorithm to run',
              allowed: ['1', '2', '3', '4', '5', 'tests'],
              defaultsTo: 'tests'
          )
    )
  ;
}

void printUsage(ArgParser argParser) {
  print('Usage: dart asynconf_2022.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('asynconf_2022 version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }

    if (results.command != null) {
      switch (results.command!.name) {
        case 'run':
          Algorithm? algorithm;

          switch (results.command!.rest[0]) {
            case '1':
              algorithm = One();
              break;
            case '2':
              algorithm = Two();
              break;
            case '3':
              algorithm = Three();
              break;
            case '4':
              algorithm = Four();
              break;
            case '5':
              algorithm = Five();
              break;
            case 'tests':
              algorithm = Tests();
              break;
            default:
              print('Unknown algorithm');
              break;
          }

          if(algorithm != null) {
            algorithm.run(verbose, []);
          }
          break;
        default:
          print('Unknown command');
          printUsage(argParser);
          break;
      }
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
