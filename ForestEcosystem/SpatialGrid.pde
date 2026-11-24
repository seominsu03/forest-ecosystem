// 담당 A. 지도 칸별 동물과 풀을 관리하고 주변 탐색 후보를 제공한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.
class SpatialGrid<T> {
  private static final int CELL_SIZE = 20;
  private final int columns = (int) Math.ceil(EcosystemConfig.MAP_WIDTH / CELL_SIZE);
  private final int rows = (int) Math.ceil(EcosystemConfig.MAP_HEIGHT / CELL_SIZE);
  private final List<List<T>> cells = new ArrayList<List<T>>();

  SpatialGrid() {
    for (int index = 0; index < columns * rows; index++) {
      cells.add(new ArrayList<T>());
    }
  }

  void clear() {
    for (List<T> cell : cells) cell.clear();
  }

  void add(T item, float x, float y) {
    cells.get(cellIndex(y, rows) * columns + cellIndex(x, columns)).add(item);
  }

  void collectNearby(float x, float y, float range, List<T> candidates) {
    candidates.clear();
    int firstColumn = cellIndex(x - range, columns);
    int lastColumn = cellIndex(x + range, columns);
    int firstRow = cellIndex(y - range, rows);
    int lastRow = cellIndex(y + range, rows);
    for (int row = firstRow; row <= lastRow; row++) {
      for (int column = firstColumn; column <= lastColumn; column++) {
        candidates.addAll(cells.get(row * columns + column));
      }
    }
  }

  private int cellIndex(float coordinate, int cellCount) {
    return Math.max(0, Math.min(cellCount - 1, (int) (coordinate / CELL_SIZE)));
  }
}
