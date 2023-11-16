import 'dart:async';

import '../base.dart';
import 'pathfinding.dart';

typedef Position = ({int x, int y});

typedef Cell = ({Position position, int type});

String runPathfinding(List<String> rawFieldLines) {
  int currentXPosition = -1;
  int currentYPosition = -1;
  int finishXPosition = -1;
  int finishYPosition = -1;
  List<List<Cell>> playingField = [];
  int currentX = -1;
  int currentY = -1;
  for (String rawFieldLine in rawFieldLines) {
    List<Cell> fieldLine = [];
    currentY++;
    currentX = -1;
    for (int rawFieldCase in rawFieldLine.codeUnits) {
      currentX++;
      String fieldCase = String.fromCharCode(rawFieldCase);
      if (fieldCase == "X") {
        currentXPosition = currentX;
        currentYPosition = currentY;
      } else if (fieldCase == "V") {
        finishXPosition = currentX;
        finishYPosition = currentY;
      }

      fieldLine.add((
        position: (x: currentX, y: currentY),
        type: fieldCase == "O" ? 0 : 1
      ));
    }

    playingField.add(fieldLine);
  }

  return PathFinding(playingField, (x: currentXPosition, y: currentYPosition),
      (x: finishXPosition, y: finishYPosition)).doPathFinding();
}

typedef InputState = ({String? value, bool isValid});

class PlayingFieldInputManager extends InputManager<InputState> {
  final int? lineLength;
  final bool spaceshipDefined;
  final bool finishDefined;

  PlayingFieldInputManager(
      {this.lineLength,
      required this.spaceshipDefined,
      required this.finishDefined});

  @override
  FutureOr<InputState> parseInput(String validatedInput) {
    validatedInput = validatedInput.trim();

    if (lineLength != null) {
      if (validatedInput.length != lineLength) {
        return (isValid: false, value: null);
      }
    }

    if (spaceshipDefined && validatedInput.contains('X')) {
      return (isValid: false, value: null);
    }

    if (finishDefined && validatedInput.contains('V')) {
      return (isValid: false, value: null);
    }

    for (final char in validatedInput.codeUnits) {
      if (!['O', '_', 'V', 'X'].contains(String.fromCharCode(char))) {
        return (isValid: false, value: null);
      }
    }

    return (isValid: true, value: validatedInput);
  }

  @override
  FutureOr<({String? comment, bool isValid})> validateInput(String input) {
    return (isValid: true, comment: null);
  }
}

class Five extends Algorithm {
  @override
  String name = 'Attaque de météorite';

  @override
  FutureOr<String>? run(bool verbose, List<String> premadeInputs) async {
    print(
        'Veuillez renseigner le terrain de jeu, insérez une entrée non-autorisé pour arrêter l\'entrée :');

    List<String> playingFieldLines = [];

    while (true) {
      final playingFieldLine = await parse<InputState>(
          PlayingFieldInputManager(
              lineLength: playingFieldLines.isNotEmpty
                  ? playingFieldLines.first.length
                  : null,
              spaceshipDefined: playingFieldLines.isNotEmpty
                  ? playingFieldLines.any((element) => element.contains('X'))
                  : false,
              finishDefined: playingFieldLines.isNotEmpty
                  ? playingFieldLines.any((element) => element.contains('V'))
                  : false),
          inputMessage: '',
          premadeInputs: premadeInputs);

      if (!playingFieldLine.isValid) {
        final validation = await parse<bool>(
            YesNoInputManager(defaultAnswer: true),
            inputMessage: 'Voulez-vous arrêter l\'entrée ? (O/n): ',
            premadeInputs: premadeInputs);

        if (validation) {
          break;
        } else {
          continue;
        }
      }

      playingFieldLines.add(playingFieldLine.value!);
    }

    String output = runPathfinding(playingFieldLines);

    print('Sortie:');
    print(output);

    return output;
  }
}
