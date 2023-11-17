import 'dart:async';

import 'base.dart';
import 'five/base.dart';
import 'four.dart';
import 'one.dart';
import 'three/base.dart';
import 'two.dart';

class Tests extends Algorithm {
  @override
  String name = 'Tests';

  @override
  FutureOr<String>? run(bool verbose, List<String> premadeInputs) async {
    Map<Algorithm, Map<List<String>, String>> algorithmsToTest = {
      One(): {
        ['Jupiter;Terre']: 'J6T4',
        ['Lune;Terre;Soleil']: 'L3T4S5',
        ['Terre;Mars;Mercure']: 'T4M3Me5',
        ['Pluton;Mercure;Terre;Mars;Calisto']: 'P5M6T4Ma2C6',
      },
      Two(): {
        ['name=Crystal;speed=20000km/h;price=400/km', '10']: '1920000000€',
        ['name=Atmos;speed=2045km/h;price=23/km', '2']: '2257680€',
        ['name=CircleBurn;speed=178547km/h;price=3612/km', '6']: '92867294016€',
        ['name=SpaceDestroyer;speed=98928423km/h;price=9294/km', '12']: '264798939848256€',
      },
      Three(): {
        // Cannot be tested
      },
      Four(): {
        ['WwogICAgewogICAgICAgICJuYW1lIjogIlNpbG9wcCIsCiAgICAgICAgInNpemUiOiAxNDkyNCwKICAgICAgICAiZGlzdGFuY2VUb1N0YXIiOiA5MDI0ODQ1MiwKICAgICAgICAibWFzcyI6IDE5NDUzMgogICAgfSwKICAgIHsKICAgICAgICAibmFtZSI6ICJBc3RyaW9uIiwKICAgICAgICAic2l6ZSI6IDE1MjAwMCwKICAgICAgICAiZGlzdGFuY2VUb1N0YXIiOiAxNDkzMDIsCiAgICAgICAgIm1hc3MiOiAyMTk0CiAgICB9LAogICAgewogICAgICAgICJuYW1lIjogIlZhbGVudXMiLAogICAgICAgICJzaXplIjogMjkwNDUwLAogICAgICAgICJkaXN0YW5jZVRvU3RhciI6IDIwOTQ4NTkzNDU1LAogICAgICAgICJtYXNzIjogMTk1MjkzCiAgICB9Cl0=']:
        '''Nom : Astrion
Taille : 152000km
Masse : 2194 tonnes
Distance à l’étoile : 149302km

Nom : Silopp
Taille : 14924km
Masse : 194532 tonnes
Distance à l’étoile : 90248452km

Nom : Valenus
Taille : 290450km
Masse : 195293 tonnes
Distance à l’étoile : 20948593455km''',
      },
      Five(): {
        [
          'O___O_OO__OO__VO_O_O',
          '__O___O_OOO_OO_____O',
          'OO___O___OOO_OOOOO_O',
          '__OO__X__OO_O___O__O',
          '_OO___OO______O___OO',
          '', // To run the algorithm
          ''
        ]: 'G4;H4;I4;I5;J5;K5;L5;M5;N5;N4;O4;P4;P5;Q5;R5;R4;S4;S3;S2;R2;Q2;P2;O2;O1',
        [
          'X___OO__O___O',
          '__O__OOOO____',
          'OO_O__OO__O__',
          '_OO_O____OO_O',
          '__O_O__O_OOVO',
          '',
          ''
        ]: 'A1;B1;C1;D1;D2;E2;E3;F3;F4;G4;H4;I4;I3;J3;J2;K2;L2;L3;L4;L5',
      }
    };

    for (final algorithm in algorithmsToTest.keys) {
      print('\x1b[34mTesting algorithm ${algorithm.name} (${algorithmsToTest.keys.toList().indexOf(algorithm) + 1}/${algorithmsToTest.length})\x1b[0m');
      for (final input in algorithmsToTest[algorithm]!.keys) {
        final String? result = await algorithm.run(verbose, input);
        if(result?.trim() != algorithmsToTest[algorithm]![input]?.trim()) {
          print('\x1b[41mTest failed for algorithm ${algorithm.name}\x1b[0m');
          print('\x1b[31mExpected\n${algorithmsToTest[algorithm]![input]}\nbut got \n$result\x1b[0m');
          return 'Test failed';
        }
      }

      print('\x1b[32mTests passed for algorithm ${algorithm.name}\x1b[0m');
    }

    print('\x1b[42mAll tests passed!\x1b[0m');

    return 'Tests passed';
  }
}