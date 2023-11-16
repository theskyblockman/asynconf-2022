import 'dart:async';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../base.dart';
import 'accounts.dart';
import 'tasks.dart';

class Task {
  final String name;
  final String description;
  final List<String> assigned;
  final bool completed;

  Task({required this.name, required this.description, required this.assigned, required this.completed});

  Task copyWith({String? name, String? description, List<String>? assigned, bool? completed}) {
    return Task(
      name: name ?? this.name,
      description: description ?? this.description,
      assigned: assigned ?? this.assigned,
      completed: completed ?? this.completed
    );
  }
}

class User {
  final String username;
  late final String id;
  List<Permission> permissions;

  User({required this.username, String? id, required this.permissions}) {
    this.id = id ?? Uuid().v4();
  }
}

class Context {
  String _currentUserId;

  User get administrator {
    for (User user in users) {
      if (user.username == 'admin') {
        return user;
      }
    }

    users.add(User(
        username: 'Administrateur', permissions: Permission.adminPermissions));

    return users.last;
  }

  User get currentUser {
    for (User user in users) {
      if (user.id == _currentUserId) {
        return user;
      }
    }

    _currentUserId = administrator.id;

    return administrator;
  }

  set currentUser(User user) {
    _currentUserId = user.id;
  }

  Map<String, dynamic>? commandParameters;
  List<Task> tasks = [];
  List<User> users = [];

  Context({required String currentUserId, this.commandParameters})
      : _currentUserId = currentUserId;
}

abstract class Parameter<T> {
  FutureOr<({bool isValid, String? comment})> validateInput(
      String input, Context context);
  FutureOr<T> parseInput(String validatedInput, Context context);
  bool get isRequired => true;
  String get name;
  String get description;
  String get id;
}

class StringParameter extends Parameter<String> {
  @override
  final String name;
  @override
  final String description;
  @override
  final String id;
  @override
  final bool isRequired;

  StringParameter(
      {this.isRequired = false,
      required this.name,
        required this.description,
        required this.id});

  @override
  FutureOr<({bool isValid, String? comment})> validateInput(
      String input, Context context) {
    return (isValid: true, comment: null);
  }

  @override
  FutureOr<String> parseInput(String validatedInput, Context context) {
    return validatedInput;
  }
}

class TaskParameter extends Parameter<Task> {
  @override
  final String name;
  @override
  final String description;
  @override
  final String id;
  @override
  final bool isRequired;

  TaskParameter(
      {this.isRequired = false,
        required this.name,
        required this.description,
        required this.id});

  @override
  FutureOr<({bool isValid, String? comment})> validateInput(
      String input, Context context) {
    if (!context.tasks.any((element) => input == element.name)) {
      return (isValid: false, comment: 'La tâche n\'existe pas.');
    }

    return (isValid: true, comment: null);
  }

  @override
  FutureOr<Task> parseInput(String validatedInput, Context context) {
    return context.tasks
        .firstWhere((element) => validatedInput == element.name);
  }
}

class UserParameter extends Parameter<User> {
  @override
  final String name;
  @override
  final String description;
  @override
  final String id;
  @override
  final bool isRequired;

  UserParameter(
      {this.isRequired = false,
        required this.name,
        required this.description,
        required this.id});

  @override
  FutureOr<({bool isValid, String? comment})> validateInput(
      String input, Context context) {
    if (!context.users.any((element) => input == element.username)) {
      return (isValid: false, comment: 'L\'utilisateur n\'existe pas.');
    }

    return (isValid: true, comment: null);
  }

  @override
  FutureOr<User> parseInput(String validatedInput, Context context) {
    return context.users
        .firstWhere((element) => validatedInput == element.username);
  }
}

class ListParameter<T> extends Parameter<List<T>> {
  final Parameter<T> parameter;

  @override
  get isRequired => parameter.isRequired;

  @override
  get name => parameter.name;

  @override
  get description => parameter.description;

  @override
  get id => parameter.id;

  ListParameter({required this.parameter});

  @override
  FutureOr<List<T>> parseInput(String validatedInput, Context context) async {
    List<String> values = validatedInput.split(';');
    List<T> parsedValues = [];

    for(String value in values) {
      parsedValues.add(await parameter.parseInput(value, context));
    }

    return parsedValues;
  }

  @override
  FutureOr<({String? comment, bool isValid})> validateInput(String input, Context context) async {
    List<String> values = input.split(';');

    for(String value in values) {
      final validationResults = await parameter.validateInput(value, context);

      if(!validationResults.isValid) {
        return (isValid: false, comment: 'La valeur "$value" n\'est pas valide: ${validationResults.comment}');
      }
    }

    return (isValid: true, comment: null);
  }
}

abstract class Command {
  String get name;
  List<String> get alises => [];
  String get description;
  List<Parameter> get parameters;
  List<Permission>? get requiredPermissions;

  FutureOr<Context?> run(Context context);
}

class Three extends Algorithm {
  @override
  String name = 'Gérez vos tâches';

  static List<Command> commandList = [
    AddTask(),
    RemoveTask(),
    CompleteTask(),
    ListTasks(),

    AddAccount(),
    RemoveAccount(),
    ConnectAccount(),

    HelpCommand()
  ];

  @override
  FutureOr<String>? run(bool verbose, List<String> premadeInputs) async {
    print("\x1B[2J\x1B[0;0H"); // Clear the screen.

    print(
        "\x1b[1;32mBienvenue dans l'application de gestion de tâches !");
    print("Si vous voulez arrêter une commande, entrez END à n'importe quel moment quand vous entrez ses arguments\x1B[0m");
    Context currentContext = Context(currentUserId: 'admin');

    while (true) {
      stdout.write(
          '\x1b[1;32m${currentContext.currentUser.username}@tableau-de-bord\x1b[0;0m:\x1b[1;34m~/\x1b[0;0m\$ ');
      final rawLineInput = stdin.readLineSync();

      if (rawLineInput == null) continue;

      bool foundCommand = false;

      for (final command in commandList) {
        if (rawLineInput.split(' ').first.trim() == command.name || command.alises.contains(rawLineInput.split(' ').first.trim())) {
          foundCommand = true;

          if (!(command.requiredPermissions ?? []).every((element) =>
              currentContext.currentUser.permissions.contains(element))) {
            print('Vous n\'avez pas la permission d\'effectuer cette action.');
            break;
          }

          currentContext.commandParameters ??= {};
          bool definedParameters = true;

          for (final parameter in command.parameters) {
            bool definedParameter = false;
            while(true) {
              stdout.write('${parameter.name}${parameter.isRequired ? '' : ' (optionnel)'}: ');
              final rawParameterInput = stdin.readLineSync();

              if(rawParameterInput == null || rawParameterInput.trim().isEmpty) {
                if(parameter.isRequired) {
                  continue;
                } else {
                  definedParameter = true;
                  break;
                }

              }

              if(rawParameterInput == 'END') {
                break;
              }

              final validationResults = await parameter.validateInput(rawParameterInput, currentContext);
              if(validationResults.isValid) {
                currentContext.commandParameters![parameter.id] = await parameter.parseInput(rawParameterInput, currentContext);
                definedParameter = true;
                break;
              } else {
                print(validationResults.comment);
              }
            }

            if(!definedParameter) {
              definedParameters = false;
              break;
            }
          }

          if(definedParameters) {
            await command.run(currentContext) ?? currentContext;
          }

          currentContext.commandParameters = null;
        }
      }

      if(!foundCommand && rawLineInput.isNotEmpty) {
        print('Commande inconnue');
      }
    }
  }
}

class HelpCommand extends Command {
  @override
  String get description => 'Affiche ce message';

  @override
  String get name => 'aide';

  @override
  List<String> get alises => ['help'];

  @override
  List<Parameter> get parameters => [
    StringParameter(name: 'Commande', description: 'Le nom de la commande dont vous voulez afficher l\'aide', id: 'commandName', isRequired: false)
  ];

  @override
  List<Permission>? get requiredPermissions => null;

  @override
  FutureOr<Context?> run(Context context) {
    if(!context.commandParameters!.containsKey('commandName')) {
      print('\x1b[4mCommandes disponibles:\x1b[0m');
      for (var command in Three.commandList) {
        if(command.requiredPermissions?.every((element) => context.currentUser.permissions.contains(element)) ?? true) {
          print('${command.name} - ${command.description} - ${command.parameters.isEmpty ? 'Aucun paramètres' : 'paramètre(s): ${command.parameters.map((e) => e.name).join(', ')}'}');
        }
      }
    } else {
      if(!Three.commandList.any((element) => element.name == context.commandParameters!['commandName'])) {
        print('Commande inconnue');
        return null;
      }

      final currentCommand = Three.commandList.firstWhere((element) => element.name == context.commandParameters!['commandName']);

      print('\x1b[4m${currentCommand.name}:\x1b[0m');
      print('Description:');
      print('  ${currentCommand.description}');
      print('Paramètres:');
      for(final parameter in currentCommand.parameters) {
        print('  ${parameter.name} - ${parameter.description}');
      }

      if(currentCommand.parameters.isEmpty) {
        print('Aucun paramètres');
      }
    }

    return null;
  }

}

enum Permission {
  createTask(1),
  deleteTask(2),
  deleteAllTasks(4),
  completeTask(8),
  completeAnyTask(16),
  listTasks(32),
  listAllTasks(64),
  createAccount(128),
  deleteAccount(256);

  final int permissionID;

  const Permission(this.permissionID);

  static List<Permission> adminPermissions = Permission.values;
  static List<Permission> defaultPermissions = [
    Permission.createTask,
    Permission.completeTask,
    Permission.listTasks
  ];
}
