import 'base.dart';

class PathFinding {
  List<List<Cell>> playField;
  final Position src;
  final Position dest;
  PathFinding(this.playField, this.src, this.dest);

  String printPos(Position pos) => "${'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[pos.x]}${pos.y + 1}";

  String getPath(Map<Cell, Cell> path, Cell from) {
    List<String> positions = [];
    Cell current = from;

    while (true) {
      if (path.containsKey(current)) {
        Cell newCurrent = path[current]!;
        positions.add(printPos(newCurrent.position));
        current = newCurrent;
      } else {
        break;
      }
    }

    positions = positions.reversed.toList();

    positions.add(printPos(dest));

    return positions.join(';');
  }

  bool isInBound(Position position) {
    return position.y < playField.length &&
        position.x < playField[0].length &&
        position.x >= 0 &&
        position.y >= 0;
  }

  Cell getCell(Position pos) {
    return playField[pos.y][pos.x];
  }

  num getH(Position pos) {
    return (pos.x - pos.x).abs() + (pos.y - pos.y).abs();
  }

  List<Cell> getNeighbours(Position currentPos) {
    List<Position> possibleNeighbours = [
      (x: currentPos.x, y: currentPos.y - 1),
      (x: currentPos.x, y: currentPos.y + 1),
      (x: currentPos.x + 1, y: currentPos.y),
      (x: currentPos.x - 1, y: currentPos.y)
    ];

    List<Cell> finalPos = [];

    for (Position possibleNeighbor in possibleNeighbours) {
      if (isInBound(possibleNeighbor)) {
        Cell createdCell = getCell(possibleNeighbor);
        if (createdCell.type != 0) {
          finalPos.add(createdCell);
        }
      }
    }

    return finalPos;
  }

  String doPathFinding() {
    List<Cell> openList = [getCell(src)];
    Map<Cell, Cell> comeFrom = {};

    Map<Position, num> gScore = {src: 0};
    Map<Position, num> fScore = {src: getH(src)};

    while (openList.isNotEmpty) {
      Cell? current;
      for (Cell cell in openList) {
        if (current == null ||
            fScore[cell.position]! < fScore[current.position]!) {
          current = cell;
        }
      }

      if (current!.position == dest) {
        return getPath(comeFrom, current);
      }

      openList.remove(current);
      for (Cell neighbor in getNeighbours(current.position)) {
        num tentativeGScore = gScore[current.position]! + 1;

        if (tentativeGScore <
            (gScore.containsKey(neighbor.position)
                ? gScore[neighbor.position]!
                : double.infinity)) {
          comeFrom[neighbor] = current;
          gScore[neighbor.position] = tentativeGScore;
          fScore[neighbor.position] = tentativeGScore + getH(neighbor.position);

          if (!openList.contains(neighbor)) {
            openList.add(neighbor);
          }
        }
      }
    }

    return "failure";
  }
}