// 담당 B. A의 생태 계산과 분리된 화면 개발용 정적 배치다.
class ExampleDataSource implements ViewDataSource {
  final SimulationSnapshot current;
  final ArrayList<SimulationRequest> pendingRequests = new ArrayList<SimulationRequest>();

  ExampleDataSource(MapScene scene) {
    ArrayList<AnimalSnapshot> animals = new ArrayList<AnimalSnapshot>();
    ArrayList<PlantSnapshot> plants = new ArrayList<PlantSnapshot>();
    EnumMap<Species, Integer> counts = new EnumMap<Species, Integer>(Species.class);
    java.util.Random sample = new java.util.Random(20261124L);
    int[] health = {65, 42, 100, 118, 82, 94};
    float[] walking = {5.0f, 4.2f, 4.8f, 4.5f, 5.2f, 5.0f};
    float[] sprinting = {9.4f, 7.4f, 9.0f, 8.1f, 10.2f, 9.6f};
    float[] range = {23, 16, 26, 21, 25, 23};
    float[] angle = {120, 105, 135, 120, 105, 110};
    for (Species species : Species.values()) {
      int index = species.ordinal();
      int count = index < 4 ? 16 : 4;
      counts.put(species, count);
      for (int i = 0; i < count; i++) {
        PVector position = landPosition(sample, scene);
        animals.add(new AnimalSnapshot(
          animals.size() + 1L, species, i < count / 2 ? Sex.MALE : Sex.FEMALE,
          AnimalState.WANDER, position.x, position.y, sample.nextFloat() * TWO_PI,
          health[index], health[index], 70, 100, 100, 100,
          90, 450, walking[index], sprinting[index], range[index], radians(angle[index])
        ));
      }
    }
    for (int i = 0; i < 120; i++) {
      PVector position = landPosition(sample, scene);
      plants.add(new PlantSnapshot(i + 1L, position.x, position.y, true));
    }
    current = new SimulationSnapshot(
      1L, 0L, SimulationState.PAUSED, 1.0, 200, 150,
      animals, plants, counts, plants.size(),
      new DisasterSnapshot(DisasterType.NONE, 0, 0, 0, 0, 0)
    );
  }

  PVector landPosition(java.util.Random sample, MapScene scene) {
    PVector position;
    do {
      position = new PVector(3 + sample.nextFloat() * 194, 3 + sample.nextFloat() * 144);
    } while (scene.isWater(position.x, position.y));
    return position;
  }

  public SimulationSnapshot snapshot() {
    return current;
  }

  public void submit(SimulationRequest request) {
    pendingRequests.add(Objects.requireNonNull(request, "request"));
  }

  // 예시 모드에서는 요청만 보관한다. 실제 어댑터는 submit에서 A에게 전달한다.
  List<SimulationRequest> drainRequests() {
    ArrayList<SimulationRequest> result = new ArrayList<SimulationRequest>(pendingRequests);
    pendingRequests.clear();
    return result;
  }
}
