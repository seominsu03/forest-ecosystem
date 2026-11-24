// 담당 A. 풀의 위치, 섭취 상태와 재생 대기를 담당한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.
class Plant {
  final long id;
  float x, y;
  boolean active = true;

  Plant(long id) {
    this.id = id;
    x = random(EcosystemConfig.MAP_WIDTH);
    y = random(EcosystemConfig.MAP_HEIGHT);
  }

  PlantSnapshot snapshot() {
    return new PlantSnapshot(id, x, y, active);
  }
}
