// 담당 A. 풀의 위치, 섭취 상태와 재생 대기를 담당한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.
class Plant {
  private static final long REGROWTH_STEPS = 600;
  final long id;
  float x, y;
  boolean active = true;
  private long regrowthStep;

  Plant(long id) {
    this.id = id;
    randomizeLocation();
  }

  private void randomizeLocation() {
    x = random(EcosystemConfig.MAP_WIDTH);
    y = random(EcosystemConfig.MAP_HEIGHT);
  }

  void consume(long step) {
    active = false;
    regrowthStep = step + REGROWTH_STEPS;
  }

  boolean regrowIfDue(long step) {
    if (active || step < regrowthStep) return false;
    randomizeLocation();
    active = true;
    return true;
  }

  PlantSnapshot snapshot() {
    return new PlantSnapshot(id, x, y, active);
  }
}
