import "dart:async";
import "dart:io";

abstract class Algorithm {
  abstract String name;
  String get getName => name;
  FutureOr<String>? run(bool verbose, List<String> premadeInputs);
}

abstract class InputManager<T> {
  /// Called when [shouldEndInput] returns true and the input is not null,
  /// if [validateInput] returns true,
  /// the input is parsed with [parseInput] and returned by [parse].
  FutureOr<({bool isValid, String? comment})> validateInput(String input);
  /// Is the data inputted by the user valid ?
  FutureOr<T> parseInput(String validatedInput);
  /// When a user ends a line, should the input be ended ?
  FutureOr<bool> shouldEndInput(String input) => true;
}

class BatchInputManager<T> extends InputManager<Map<String, T>> {
  final InputManager<T> individualParameterManager;
  final List<String> parameters;
  final String divider;

  BatchInputManager({required this.individualParameterManager, required this.parameters, this.divider = ';'});

  @override
  FutureOr<Map<String, T>> parseInput(String validatedInput) async {
    if(validatedInput.endsWith(divider)) validatedInput = validatedInput.substring(0, validatedInput.length - 1);

    List<String> parsedParameters = validatedInput.split(divider);

    Map<String, T> parsedParametersMap = {};

    for(final parameter in parameters) {
      parsedParametersMap[parameter] = await individualParameterManager.parseInput(parsedParameters[parameters.indexOf(parameter)]);
    }

    return parsedParametersMap;
  }

  @override
  FutureOr<({String? comment, bool isValid})> validateInput(String input) async {
    if(input.endsWith(divider)) input = input.substring(0, input.length - 1);

    List<String> parsedParameters = input.split(divider);

    if(parsedParameters.length != parameters.length) {
      return (isValid: false, comment: 'Veuillez renseigner ${parameters.length == 1 ? 'un' : parameters.length} paramètre${parameters.length > 1 ? 's séparés par: $divider' : ''}');
    }

    for(final parsedParameter in parsedParameters) {
      final validationResults = await individualParameterManager.validateInput(parsedParameter);
      if(!validationResults.isValid) {
        return validationResults;
      }
    }

    return (isValid: true, comment: null);
  }
}

class ListInputManager<T> extends InputManager<List<T>> {
  final InputManager<T> individualParameterManager;
  final String divider;

  ListInputManager({required this.individualParameterManager, this.divider = ';'});

  @override
  FutureOr<List<T>> parseInput(String validatedInput) async {
    if(validatedInput.endsWith(divider)) validatedInput = validatedInput.substring(0, validatedInput.length - 1);

    List<String> parsedParameters = validatedInput.split(divider);

    List<T> parsedParametersList = [];

    for(final parsedParameter in parsedParameters) {
      parsedParametersList.add(await individualParameterManager.parseInput(parsedParameter));
    }

    return parsedParametersList;
  }

  @override
  FutureOr<({String? comment, bool isValid})> validateInput(String input) async {
    if(input.endsWith(divider)) input = input.substring(0, input.length - 1);

    List<String> parsedParameters = input.split(divider);

    for(final parsedParameter in parsedParameters) {
      final validationResults = await individualParameterManager.validateInput(parsedParameter);
      if(!validationResults.isValid) {
        return validationResults;
      }
    }

    return (isValid: true, comment: null);
  }
}

class IntInputManager extends InputManager<int> {
  @override
  FutureOr<({bool isValid, String? comment})> validateInput(String input) {
    try {
      int.parse(input);
    } catch (e) {
      return (
      isValid: false,
      comment: 'Veuillez renseigner une valeur numérique valide.'
      );
    }

    return (isValid: true, comment: null);
  }

  @override
  FutureOr<int> parseInput(String validatedInput) {
    return int.parse(validatedInput);
  }
}

class YesNoInputManager extends InputManager<bool> {
  final bool? defaultAnswer;

  YesNoInputManager({this.defaultAnswer});

  @override
  FutureOr<bool> parseInput(String validatedInput) {
    return ['y', 'yes', 'o', 'oui'].contains(validatedInput.trim().toLowerCase()) || defaultAnswer!;
  }

  @override
  FutureOr<({String? comment, bool isValid})> validateInput(String input) {
    if(!['y', 'yes', 'o', 'oui' 'n', 'no', 'non'].contains(input.trim().toLowerCase()) && defaultAnswer == null) {
      return (
        isValid: false,
        comment: 'Veuillez renseigner une valeur valide (y/n).'
      );
    }

    return (
      isValid: true,
      comment: null
    );
  }
}

Future<T> parse<T>(InputManager<T> inputManager,
    {String inputMessage = 'Veuillez écrire la valeur : ', List<String>? premadeInputs}) async {
  String? input;
  List<String> buildingInput = [];

  while (input == null) {
    if(premadeInputs != null && premadeInputs.isNotEmpty) {
      input = premadeInputs.removeAt(0);
    } else {
      stdout.write(inputMessage);
      input = stdin.readLineSync();
      if(input != null) {
        buildingInput.add(input);
        input = null;
      }
    }

    if (buildingInput.isEmpty && input == null) {
      print('\nVeuillez renseigner une valeur');
    } else {
      String builtInput = input ?? buildingInput.join('\n');

      if(!(await inputManager.shouldEndInput(builtInput))) {
        input = null;
        continue;
      }

      final result = await inputManager.validateInput(builtInput);

      if (!result.isValid) {
        print('${result.comment}');
        input = null;
        continue;
      }

      return await inputManager.parseInput(builtInput);
    }
  }

  throw StdinException(
      'Impossible de récupérer la valeur depuis l\'utilisateur');
}
