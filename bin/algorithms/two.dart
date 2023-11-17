import 'dart:async';

import 'base.dart';

typedef Ship = ({String name, num speed, num pricePerKm});

class ShipCharacteristicsInputManager extends InputManager<Ship> {
  @override
  FutureOr<({bool isValid, String? comment})> validateInput(String input) {
    List<String> parsedParameters = input.split(';');

    if (parsedParameters.length < 3) {
      return (isValid: false, comment: 'Veuillez renseigner les 3 paramètres.');
    }

    Map<String, String> parameters = {};

    for (final parameter in parsedParameters) {
      List<String> splitEntry = parameter.split('=');
      if (splitEntry.length != 2) {
        return (
          isValid: false,
          comment:
              'Veuillez renseigner des paramètres valides avec la bonne syntaxe.'
        );
      }

      parameters[splitEntry[0]] = splitEntry[1];
    }

    final List<String> requiredParameters = ['name', 'speed', 'price'];

    for (final requiredParameter in requiredParameters) {
      if (!parameters.containsKey(requiredParameter)) {
        return (
          isValid: false,
          comment: 'Veuillez renseigner le paramètre $requiredParameter.'
        );
      }
    }

    try {
      num.parse(
          parameters['speed']!.substring(0, parameters['speed']!.length - 5));
      num.parse(
          parameters['price']!.substring(0, parameters['price']!.length - 4));
    } catch (e) {
      return (
        isValid: false,
        comment: 'Veuillez renseigner des valeurs numériques valides.'
      );
    }

    return (isValid: true, comment: null);
  }

  @override
  FutureOr<Ship> parseInput(String validatedInput) {
    List<String> parsedParameters = validatedInput.split(';');

    Map<String, String> parameters = {};

    for (final parameter in parsedParameters) {
      List<String> splitEntry = parameter.split('=');
      parameters[splitEntry[0]] = splitEntry[1];
    }

    return (
      name: parameters['name']!,
      speed: num.parse(
          parameters['speed']!.substring(0, parameters['speed']!.length - 4)),
      pricePerKm: num.parse(
          parameters['price']!.substring(0, parameters['price']!.length - 3))
    );
  }
}

class Two extends Algorithm {
  @override
  String name = 'Mission Phantom 2064';

  @override
  FutureOr<String>? run(bool verbose, List<String> premadeInputs) async {
    final ship = await parse<Ship>(ShipCharacteristicsInputManager(),
        inputMessage: 'Veuillez renseigner les caractéristiques du vaisseau : ',
        premadeInputs: premadeInputs);
    final duration = await parse<int>(IntInputManager(),
        inputMessage: 'Veuillez renseigner la durée de la mission : ',
        premadeInputs: premadeInputs);

    final distance = ship.speed * duration * 24; // In km
    final price = ship.pricePerKm * distance;

    print(
        'Sortie: Si le vaisseau ${ship.name} parcours $distance km en $duration jours à ${ship.speed} km/h, cela coûterait $price€.');

    return '$price€';
  }
}
