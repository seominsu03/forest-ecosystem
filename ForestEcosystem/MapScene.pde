// 담당 B. 표시용 지형과 장식. 이동 제한과 생태 효과는 A와 별도로 합의한다.
class MapScene {
  final float tileSize = 5.0f;
  final PImage ground;
  final PImage food;
  final PImage[] decorations;
  final PImage[][] shores = new PImage[3][3];
  final ArrayList<PVector> positions = new ArrayList<PVector>();
  final ArrayList<Integer> kinds = new ArrayList<Integer>();

  MapScene() {
    ground = loadImage("forest/ground_grass.png");
    food = loadImage("forest/food_grass.png");
    decorations = new PImage[] {
      loadImage("forest/tree_round.png"), loadImage("forest/tree_pine.png"),
      loadImage("forest/bush_small.png"), loadImage("forest/bush_large.png"),
      loadImage("forest/stone.png")
    };
    for (int row = 0; row < 3; row++) {
      for (int column = 0; column < 3; column++) {
        shores[column][row] = loadImage("forest/water_edge_" + column + "_" + row + ".png");
      }
    }
    java.util.Random layout = new java.util.Random(31L);
    for (int i = 0; i < 65; i++) {
      float x = 4 + layout.nextFloat() * 192;
      float y = 5 + layout.nextFloat() * 140;
      if (!isWater(x, y)) {
        positions.add(new PVector(x, y));
        kinds.add(layout.nextInt(decorations.length));
      }
    }
  }

  boolean isWaterTile(int column, int row) {
    boolean lake = column >= 10 && column < 23 && row >= 7 && row < 18;
    boolean river = column >= 22 && column < 40 && row >= 10 && row < 14;
    return lake || river;
  }

  boolean isWater(float x, float y) {
    return isWaterTile(floor(x / tileSize), floor(y / tileSize));
  }

  void drawGround(float worldWidth, float worldHeight) {
    imageMode(CORNER);
    for (int row = 0; row < ceil(worldHeight / tileSize); row++) {
      for (int column = 0; column < ceil(worldWidth / tileSize); column++) {
        image(ground, column * tileSize, row * tileSize, tileSize, tileSize);
        if (isWaterTile(column, row)) {
          int shoreColumn = 1;
          int shoreRow = 1;
          if (!isWaterTile(column - 1, row)) shoreColumn = 0;
          else if (!isWaterTile(column + 1, row)) shoreColumn = 2;
          if (!isWaterTile(column, row - 1)) shoreRow = 0;
          else if (!isWaterTile(column, row + 1)) shoreRow = 2;
          image(shores[shoreColumn][shoreRow],
                column * tileSize, row * tileSize, tileSize, tileSize);
        }
      }
    }
  }

  void drawDecorations() {
    imageMode(CENTER);
    for (int i = 0; i < positions.size(); i++) {
      PVector position = positions.get(i);
      PImage sprite = decorations[kinds.get(i)];
      float spriteHeight = 4 * (float)sprite.height / sprite.width;
      image(sprite, position.x, position.y - spriteHeight / 2 + 1, 4, spriteHeight);
    }
    imageMode(CORNER);
  }

  void drawPlants(List<PlantSnapshot> plants) {
    imageMode(CENTER);
    for (PlantSnapshot plant : plants) {
      if (plant.active) image(food, plant.x, plant.y, 2.2f, 2.2f);
    }
    imageMode(CORNER);
  }
}
