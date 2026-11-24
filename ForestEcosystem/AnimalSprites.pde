// 담당 B. 이미지만 대체하며 종 enum과 생태 상태는 수정하지 않는다.
// 최초 적용은 방향별 정지 프레임. 애니메이션 시트는 원본 그대로 보관한다.
class AnimalSprites {
  final PImage[][] frames = new PImage[6][4]; // 아래, 위, 왼쪽, 오른쪽
  int missingSpecies;

  AnimalSprites() {
    PImage hare = readSheet("hare.png");
    PImage deer = readSheet("deer.png");
    PImage bat = readSheet("bat.png");
    PImage cat = readSheet("cat_brown.png");
    PImage markings = readSheet("cat_tabby.png");
    PImage ferret = readSheet("ferret.png");
    for (int direction = 0; direction < 4; direction++) {
      frames[Species.HARE.ordinal()][direction] = cell(hare, 0, direction * 32, 32);
      frames[Species.ROE_DEER.ordinal()][direction] = cell(deer, 0, direction * 32, 32);
      frames[Species.WATER_DEER.ordinal()][direction] = cell(deer, 0, direction * 32, 32);
      frames[Species.VOLE.ordinal()][direction] = cell(bat, 0, 0, 64);
      // 고양이 원본: 아래 1행, 위 8행, 좌 3행, 우 11행 (0부터 계산).
      int[] catRows = {1, 8, 3, 11};
      PImage catFrame = cell(cat, 0, catRows[direction] * 32, 32);
      PImage pattern = cell(markings, 0, catRows[direction] * 32, 32);
      frames[Species.LEOPARD_CAT.ordinal()][direction] = withMarkings(catFrame, pattern);
      // 페럿은 측면 이미지이므로 상하 이동도 측면으로 표시한다.
      frames[Species.MARTEN.ordinal()][direction] = cell(ferret, 0, 0, 32);
    }
    for (Species species : Species.values()) {
      if (frames[species.ordinal()][0] == null) missingSpecies++;
    }
  }

  PImage readSheet(String name) {
    String relative = "animals/" + name;
    if (!new java.io.File(dataPath(relative)).isFile()) return null;
    PImage sheet = loadImage(relative);
    return sheet != null && sheet.width > 0 ? sheet : null;
  }

  PImage cell(PImage sheet, int x, int y, int size) {
    if (sheet == null || x + size > sheet.width || y + size > sheet.height) return null;
    return sheet.get(x, y, size, size);
  }

  PImage withMarkings(PImage base, PImage pattern) {
    if (base == null || pattern == null) return base;
    // 제공된 무늬의 알파만 사용해 갈색 털 위에 짙은 무늬를 합성한다.
    base.loadPixels();
    pattern.loadPixels();
    for (int i = 0; i < base.pixels.length; i++) {
      int original = base.pixels[i];
      int coverage = (pattern.pixels[i] >>> 24) & 255;
      if ((original >>> 24) == 0 || coverage == 0) continue;
      float fraction = coverage / 255.0f;
      int r = (int)(((original >> 16) & 255) * (1 - fraction) + 48 * fraction);
      int g = (int)(((original >> 8) & 255) * (1 - fraction) + 34 * fraction);
      int b = (int)((original & 255) * (1 - fraction) + 25 * fraction);
      base.pixels[i] = (original & 0xff000000) | (r << 16) | (g << 8) | b;
    }
    base.updatePixels();
    return base;
  }

  int facing(float angle) {
    float dx = cos(angle), dy = sin(angle);
    if (abs(dx) > abs(dy)) return dx < 0 ? 2 : 3;
    return dy < 0 ? 1 : 0;
  }

  boolean draw(AnimalSnapshot animal) {
    int direction = facing(animal.directionRadians);
    PImage sprite = frames[animal.species.ordinal()][direction];
    if (sprite == null) return false;
    pushStyle();
    pushMatrix();
    translate(animal.x, animal.y);
    if (animal.species == Species.MARTEN && cos(animal.directionRadians) < 0) scale(-1, 1);
    imageMode(CENTER);
    noTint();
    // 같은 사슴 원본을 사용하는 두 종은 색과 표시 크기로 구분한다.
    if (animal.species == Species.WATER_DEER) tint(210, 188, 157);
    float size = animal.species == Species.VOLE ? 4.0f
      : animal.species == Species.HARE ? 4.8f : 5.8f;
    if (animal.species == Species.WATER_DEER) size = 5.4f;
    image(sprite, 0, -size * 0.12f, size, size);
    popMatrix();
    popStyle();
    return true;
  }

  String substituteName(Species species) {
    if (species == Species.VOLE) return "박쥐";
    if (species == Species.LEOPARD_CAT) return "갈색 줄무늬 고양이";
    if (species == Species.MARTEN) return "페럿";
    if (species == Species.ROE_DEER || species == Species.WATER_DEER) return "사슴";
    return "토끼";
  }
}
