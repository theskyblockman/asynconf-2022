import 'dart:async';
import 'dart:io';

import '../base.dart';
import 'base.dart';

class AddAccount extends Command {
  @override
  String get description => 'Ajoute un compte';

  @override
  String get name => 'ajouter-compte';

  @override
  List<Parameter> get parameters => [
        StringParameter(
            name: 'nom d\'utilisateur',
            description: 'Le nom d\'utilisateur du compte (ex. jdupont)',
            isRequired: true,
            id: 'username'),
      ];

  @override
  List<Permission>? get requiredPermissions => [Permission.createAccount];

  @override
  FutureOr<Context?> run(Context context) async {
    stdout.write('\x1b[0;34m');
    print(
        'L\'utilisateur "${context.commandParameters!['username']}" va être créé. Veuillez sélectionner les permissions de ce compte:');
    for (int i = 0; i < Permission.values.length; i++) {
      print('${i + 1}) ${Permission.values[i].name}');
    }
    stdout.write(
        '\nVeuillez sélectionner les permissions pour le compte qui va être créé (ex. 1;2;3 pour les 3 premières permissions): ');

    final inputManager =
        ListInputManager<int>(individualParameterManager: IntInputManager());

    final input = stdin.readLineSync();

    if (input == null || !(await inputManager.validateInput(input)).isValid) {
      print('Veuillez renseigner des valeurs valides dans le bon format.');
      return null;
    }

    final parsedInput = await inputManager.parseInput(input);
    List<Permission> permissions = [];

    for (int i = 0; i < Permission.values.length; i++) {
      if (parsedInput.contains(i + 1)) {
        permissions.add(Permission.values[i]);
      }
    }
    final createdUser = User(
        username: context.commandParameters!['username'],
        permissions: permissions);
    context.users.add(createdUser);

    stdout.write(
        'L\'utilisateur "${context.commandParameters!['username']}" a été créé. Voulez vous vous connecter avec ce compte ? (O/n) ');
    if (['o', 'oui', ''].contains(stdin.readLineSync()?.trim() ?? 'n')) {
      context.currentUser = createdUser;
    }

    stdout.write('\x1b[0;0m');

    return context;
  }
}

class RemoveAccount extends Command {
  @override
  String get description => 'Retire un compte';

  @override
  String get name => 'supprimer-compte';

  @override
  List<Parameter> get parameters => [
        UserParameter(
            name: 'nom d\'utilisateur',
            description: 'Le nom d\'utilisateur du compte (ex. jdupont)',
            id: 'username',
            isRequired: true)
      ];

  @override
  List<Permission>? get requiredPermissions => [Permission.deleteAccount];

  @override
  FutureOr<Context?> run(Context context) async {
    stdout.write('\x1b[0;34m');

    final User userToDelete = context.commandParameters!['username'];

    stdout.write(
        'L\'utilisateur "${userToDelete.username}" va être supprimé. Voulez vous continuer ? (O/n) ');
    if (['o', 'oui', ''].contains(stdin.readLineSync()?.trim() ?? 'n')) {
      if(context.currentUser == userToDelete) {
        context.currentUser = context.administrator;
      }

      context.users.remove(userToDelete);

      print('L\'utilisateur "${userToDelete.username}" a été supprimé.');
    }

    stdout.write('\x1b[0;0m');

    return context;
  }
}


class ConnectAccount extends Command {
  @override
  String get description => 'Connecter à votre compte';

  @override
  String get name => 'connecter';

  @override
  List<Parameter> get parameters => [
    UserParameter(
        name: 'nom d\'utilisateur',
        description: 'Le nom d\'utilisateur du compte (ex. jdupont)',
        id: 'username',
        isRequired: true)
  ];

  @override
  List<Permission>? get requiredPermissions => null;

  @override
  FutureOr<Context?> run(Context context) {
    stdout.write('\x1b[0;34m');

    final User userToConnect = context.commandParameters!['username'];

    if(context.currentUser == userToConnect) {
      print('Vous êtes déjà connecté avec ce compte.');
      return null;
    }

    context.currentUser = userToConnect;

    stdout.write('\x1b[0;0m');

    return context;
  }

}