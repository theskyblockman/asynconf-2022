import 'dart:async';
import 'dart:io';

import 'base.dart';

class AddTask extends Command {
  @override
  String get description =>
      'Créer une tâche assigné à un ou plusieurs utilisateurs';

  @override
  String get name => 'ajouter';

  @override
  List<Parameter> get parameters => [
        StringParameter(
            name: 'Nom de la tâche',
            description: 'Le nom de la tâche (ex. Démarrer le vaisseau)',
            id: 'taskName',
            isRequired: true),
        StringParameter(
            name: 'Description de la tâche',
            description: 'La description de la tâche (ex. Ne pas oublier la clé sur terre!)',
            id: 'taskDescription',
            isRequired: false),
        ListParameter(
          parameter: UserParameter(
              name: 'Nom de l\'utilisateur',
              description: 'Le nom d\'utilisateur du compte (ex. jdupont)',
              id: 'assigned',
              isRequired: true)
        )
      ];

  @override
  List<Permission>? get requiredPermissions => [
        Permission.createTask
  ];

  @override
  FutureOr<Context?> run(Context context) {
    List<String> assignedUsersIDs = [];

    for(User user in context.commandParameters!['assigned']) {
      assignedUsersIDs.add(user.id);
    }

    if(assignedUsersIDs.isEmpty) {
      print('Vous devez assigner au moins un utilisateur à la tâche.');
      return null;
    }

    context.tasks.add(
      Task(name: context.commandParameters!['taskName'], description: context.commandParameters!['taskDescription'] ?? 'Description non fournie', assigned: assignedUsersIDs, completed: false)
    );

    print('Tâche crée avec succès !');

    return context;
  }
}

class RemoveTask extends Command {
  @override
  String get description =>
      'Retirer une tâche';

  @override
  String get name => 'retirer';

  @override
  List<Parameter> get parameters => [
    TaskParameter(name: 'Nom de la tâche', description: 'Le nom de la tâche (ex. Démarrer le vaisseau)', id: 'taskName', isRequired: true)
  ];

  @override
  List<Permission>? get requiredPermissions => [
    Permission.deleteTask
  ];

  @override
  FutureOr<Context?> run(Context context) {
    stdout.write('\x1b[0;34m');

    context.tasks.remove(
        context.commandParameters!['taskName']
    );

    print('Tâche retirée avec succès !');

    stdout.write('\x1b[0;0m');

    return context;
  }
}

class CompleteTask extends Command {
  @override
  String get description =>
      'Marquer une tâche comme complétée';

  @override
  String get name => 'compléter';

  @override
  List<String> get alises => ['completer'];

  @override
  List<Parameter> get parameters => [
    TaskParameter(name: 'Nom de la tâche', description: 'Le nom de la tâche (ex. Démarrer le vaisseau)', id: 'taskName', isRequired: true)
  ];

  @override
  List<Permission>? get requiredPermissions => [
    Permission.completeTask
  ];

  @override
  FutureOr<Context?> run(Context context) {
    stdout.write('\x1b[0;34m');

    Task selectedTask = context.commandParameters!['taskName'];

    if(!context.currentUser.permissions.contains(Permission.completeAnyTask) && !selectedTask.assigned.contains(context.currentUser.id)) {
      print('Vous n\'avez pas la permission de compléter cette tâche.');
      return null;
    }

    context.tasks[context.tasks.indexOf(selectedTask)] = selectedTask.copyWith(completed: true);

    print('Tâche retirée avec succès !');

    stdout.write('\x1b[0;0m');

    return context;
  }
}

class ListTasks extends Command {
  @override
  String get description =>
      'Lister les tâches et leur état';

  @override
  String get name => 'liste';

  @override
  List<Parameter> get parameters => [];

  @override
  List<Permission>? get requiredPermissions => [
    Permission.listTasks
  ];

  @override
  FutureOr<Context?> run(Context context) {
    List<Task> assignedTasks = context.tasks.where((element) => element.assigned.contains(context.currentUser.id)).toList();

    print('\x1b[4mVos tâches:\x1b[0;0m');

    if(assignedTasks.isEmpty) {
      if(context.tasks.isEmpty && context.currentUser.permissions.contains(Permission.listAllTasks)) {
        print('Aucune tâche n\'a été crée.');
      } else {
        print('Vous n\'avez aucune tâche assignée.');
      }
      return null;
    } else {
      for(Task task in assignedTasks) {
        List<String> assignedUsernames = [];

        for(String userID in task.assigned) {
          assignedUsernames.add(context.users.firstWhere((element) => element.id == userID, orElse: () => User(username: 'Utilisateur inconnu', permissions: [])).username);
        }

        print('  ${task.completed ? '\x1b[0;32m' : '\x1b[0;31m'}${task.name} - ${task.description} (assigné à: ${assignedUsernames.join(', ')})\x1b[0;0m');
      }
    }

    if(!context.currentUser.permissions.contains(Permission.listAllTasks)) {
      return null;
    }


    List<Task> remainingTasks = context.tasks.where((element) => !element.assigned.contains(context.currentUser.id)).toList();

    if(remainingTasks.isEmpty) {
      return null;
    }

    print('');
    print('\x1b[4mToutes les autres tâches:\x1b[0;0m');

    for(Task task in remainingTasks) {
      List<String> assignedUsernames = [];

      for(String userID in task.assigned) {
        assignedUsernames.add(context.users.firstWhere((element) => element.id == userID, orElse: () => User(username: 'Utilisateur inconnu', permissions: [])).username);
      }

      print('  ${task.completed ? '\x1b[0;32m' : '\x1b[0;31m'}${task.name} - ${task.description} (assigné à: ${assignedUsernames.join(', ')})\x1b[0;0m');
    }

    return context;
  }
}

class ClearTasks extends Command {
  @override
  String get description =>
      'Retirer toutes les tâches';

  @override
  String get name => 'vider';

  @override
  List<Parameter> get parameters => [];

  @override
  List<Permission>? get requiredPermissions => [
    Permission.deleteAllTasks
  ];

  @override
  FutureOr<Context?> run(Context context) {
    stdout.write('\x1b[0;34m');

    context.tasks.clear();

    print('Tâches retirées avec succès !');

    stdout.write('\x1b[0;0m');

    return context;
  }
}