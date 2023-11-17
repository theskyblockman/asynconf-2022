import 'dart:async';
import 'dart:convert';

import 'base.dart';

class JSONInputManager extends InputManager<dynamic> {
  @override
  FutureOr<({bool isValid, String? comment})> validateInput(String input) {
    try {
      jsonDecode(input);
    } on FormatException {
      return (isValid: false, comment: 'Veuillez renseigner un JSON valide.');
    }

    return (isValid: true, comment: null);
  }

  @override
  FutureOr<dynamic> parseInput(String validatedInput) {
    return jsonDecode(validatedInput);
  }
}

class Base64ChainInputManager<T> extends InputManager<T> {
  final InputManager<T> chain;

  Base64ChainInputManager({required this.chain});

  @override
  FutureOr<T> parseInput(String validatedInput) {
    return chain.parseInput(utf8.decode(base64Decode(validatedInput)));
  }

  @override
  FutureOr<({String? comment, bool isValid})> validateInput(String input) {
    input = input.replaceAll('\n', '').replaceAll(' ', '');

    try {
      print(base64Decode(input));
    } on FormatException {
      return (
        isValid: false,
        comment: 'Veuillez renseigner une base64 valide.'
      );
    }

    return chain.validateInput(utf8.decode(base64Decode(input)));
  }
}

typedef Star = ({String name, int size, int mass, int distanceToStar});

class Four extends Algorithm {
  @override
  String name = 'La supernova';

  @override
  FutureOr<String>? run(bool verbose, List<String> premadeInputs) async {
    final input = await parse<dynamic>(
        Base64ChainInputManager<dynamic>(chain: JSONInputManager()),
        premadeInputs: premadeInputs);

    List<Star> stars = [];

    for (Map<String, dynamic> rawStar in input) {
      stars.add((
        name: rawStar['name'],
        size: rawStar['size'],
        mass: rawStar['mass'],
        distanceToStar: rawStar['distanceToStar']
      ));
    }

    // Sorting
    for(int i = 0; i < stars.length; i++) {
      for(int j = i + 1; j < stars.length; j++) {
        if(stars[i].distanceToStar > stars[j].distanceToStar) {
          Star temp = stars[i];
          stars[i] = stars[j];
          stars[j] = temp;
        }
      }
    }

    List<String> finalSortedStars = [];

    for(final star in stars) {
      finalSortedStars.add('Nom : ${star.name}\nTaille : ${star.size}km\nMasse : ${star.mass} tonnes\nDistance à l’étoile : ${star.distanceToStar}km');
    }

    String finalOutput = finalSortedStars.join('\n\n');

    print('Sortie:');
    print(finalOutput);

    return finalOutput;
  }
}