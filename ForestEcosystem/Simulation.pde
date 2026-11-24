// 담당 A. 고정 시간 단계, 상호작용, 상태 갱신과 초기화를 담당한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.
class Simulation {
  private static final double STEP_ROUNDING_TOLERANCE = 1e-12d;
  private final EcosystemConfig config = new EcosystemConfig();
  private final List<Animal> animals = new ArrayList<Animal>();
  private final List<Plant> plants = new ArrayList<Plant>();
  private final Map<Species, Integer> counts = new EnumMap<Species, Integer>(Species.class);
  private final DisasterSnapshot noDisaster = new DisasterSnapshot(DisasterType.NONE, 0, 0, 0, 0, 0);
  private long lastRunId, runId, step;
  private double pendingSeconds;
  private double speedMultiplier = 1.0;
  private SimulationState state = SimulationState.READY;
  private PopulationInitialState initialPopulation;
  private SimulationSnapshot latestSnapshot = captureSnapshot();
  private StartSettings startSettings;

  StartSettings defaultStartSettings() {
    return config.defaultStartSettings();
  }

  boolean applyRequest(SimulationRequest request) {
    switch (request.type) {
      case START:
        if (state != SimulationState.READY || !config.validStartSettings(request.startSettings)) return false;
        start(request.startSettings);
        break;
      case PAUSE:
        if (state != SimulationState.RUNNING) return false;
        state = SimulationState.PAUSED;
        break;
      case RESUME:
        if (state != SimulationState.PAUSED) return false;
        state = SimulationState.RUNNING;
        break;
      case RESET:
        reset();
        break;
      case SET_SPEED:
        double speed = request.speedMultiplier;
        if (speed != 0.5 && speed != 1.0 && speed != 3.0) return false;
        speedMultiplier = speed;
        break;
    }
    latestSnapshot = captureSnapshot();
    return true;
  }

  void advance(double realElapsedSeconds) {
    if (!Double.isFinite(realElapsedSeconds) || realElapsedSeconds < 0) {
      throw new IllegalArgumentException("Elapsed time must be finite and nonnegative.");
    }
    if (state != SimulationState.RUNNING) return;

    double accumulatedSeconds = pendingSeconds + realElapsedSeconds * speedMultiplier;
    double elapsedSteps = Math.floor((accumulatedSeconds + STEP_ROUNDING_TOLERANCE) / EcosystemConfig.STEP_SECONDS);
    if (elapsedSteps >= Long.MAX_VALUE - step) {
      throw new IllegalArgumentException("Elapsed time exceeds the simulation step range.");
    }
    long completedSteps = (long) elapsedSteps;
    pendingSeconds = Math.max(0, accumulatedSeconds - completedSteps * EcosystemConfig.STEP_SECONDS);
    if (completedSteps == 0) return;
    for (long index = 0; index < completedSteps; index++) {
      advanceStep();
    }
    latestSnapshot = captureSnapshot();
  }

  SimulationSnapshot snapshot() {
    return latestSnapshot;
  }

  // Null while READY. The record stays at step 0 throughout its run.
  PopulationInitialState initialPopulation() {
    return initialPopulation;
  }

  private void start(StartSettings settings) {
    startSettings = settings;
    runId = ++lastRunId;
    for (Species species : Species.values()) {
      int count = config.initialCount(species, settings);
      counts.put(species, count);
      for (int index = 0; index < count; index++) {
        Sex sex = index < count / 2 ? Sex.FEMALE : Sex.MALE;
        animals.add(new Animal(animals.size() + 1L, species, sex, config.profiles.get(species)));
      }
    }
    for (int index = 0; index < EcosystemConfig.INITIAL_PLANTS; index++) {
      plants.add(new Plant(index + 1L));
    }
    initialPopulation = new PopulationInitialState(runId, counts);
    state = SimulationState.RUNNING;
  }

  private void reset() {
    animals.clear();
    plants.clear();
    counts.clear();
    initialPopulation = null;
    startSettings = null;
    runId = 0;
    step = 0;
    pendingSeconds = 0;
    speedMultiplier = 1.0;
    state = SimulationState.READY;
  }

  private void advanceStep() {
    step++;
  }

  private SimulationSnapshot captureSnapshot() {
    List<AnimalSnapshot> animalSnapshots = new ArrayList<AnimalSnapshot>(animals.size());
    List<PlantSnapshot> plantSnapshots = new ArrayList<PlantSnapshot>(plants.size());
    int activePlantCount = 0;
    for (Animal animal : animals) {
      animalSnapshots.add(animal.snapshot(step * EcosystemConfig.STEP_SECONDS));
    }
    for (Plant plant : plants) {
      plantSnapshots.add(plant.snapshot());
      if (plant.active) activePlantCount++;
    }
    return new SimulationSnapshot(runId, step, state, speedMultiplier, EcosystemConfig.MAP_WIDTH,
      EcosystemConfig.MAP_HEIGHT, animalSnapshots, plantSnapshots, counts, activePlantCount, noDisaster);
  }
}
