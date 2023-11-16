import 'dart:async';

import 'base.dart';

class StringInputManager extends InputManager<String> {
  @override
  FutureOr<({bool isValid, String? comment})> validateInput(String input) {
    return (isValid: true, comment: null);
  }

  @override
  FutureOr<String> parseInput(String validatedInput) {
    return validatedInput;
  }
}

class One extends Algorithm {
  @override
  String name = 'Nommons les étoiles';

  @override
  FutureOr<String>? run(bool verbose, List<String> premadeInputs) async {
    Map<String, String> alreadyUsedNames = {};

    final List<String> planetList = await parse<List<String>>(ListInputManager(individualParameterManager: StringInputManager()),
        inputMessage: 'Veuillez écrire le nom des planètes chacune divisée par un point-virgule : ', premadeInputs: premadeInputs);

    String finalName = '';

    for(final planet in planetList) {
      if(alreadyUsedNames.containsValue(planet)) {
        finalName += alreadyUsedNames.entries.firstWhere((element) => element.value == planet).key;
        continue;
      }

      bool foundName = false;
      int currentLevel = 1;

      while(!foundName) {
        if(alreadyUsedNames.containsKey(planet.substring(0, currentLevel))) {
          currentLevel++;
          if(verbose) {
            print('Already used name: ${planet.substring(0, currentLevel)}');
          }
        } else {
          foundName = true;
          alreadyUsedNames[planet.substring(0, currentLevel)] = planet;
          finalName += planet.substring(0, currentLevel) + (planet.length - currentLevel).toString();
        }
      }
    }

    print('Sortie: $finalName');

    return finalName;
  }
  
}