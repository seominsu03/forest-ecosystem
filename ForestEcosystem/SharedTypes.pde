// A와 B가 함께 사용하는 공통 자료형. 구현 기준은 ../문서/개발가이드.md 6절.
// Snapshot은 완료된 단계의 표시용 값이다. 필드와 컬렉션은 읽기 전용이다.
// 위치·거리는 지도 단위, 방향·시야각은 라디안, 나이·수명은 시뮬레이션 초다.
import java.util.ArrayList;
import java.util.Collections;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

enum Species {
  HARE,
  VOLE,
  ROE_DEER,
  WATER_DEER,
  LEOPARD_CAT,
  MARTEN
}

enum Sex {
  MALE,
  FEMALE
}

enum AnimalState {
  WANDER,
  SEEK_FOOD,
  CHASE,
  ATTACK,
  FLEE,
  EAT,
  REST
}

enum SimulationState {
  READY,
  RUNNING,
  PAUSED,
  FINISHED
}

enum DisasterType {
  NONE,
  DROUGHT,
  WILDFIRE
}

enum PopulationEventType {
  BIRTH,
  DEATH
}

enum CommandType {
  START,
  PAUSE,
  RESUME,
  RESET,
  SET_SPEED
}

class AnimalSnapshot {
  final long id;
  final Species species;
  final Sex sex;
  final AnimalState state;
  final float x;
  final float y;
  final float directionRadians;
  final float health;
  final float maxHealth;
  final float energy;
  final float maxEnergy;
  final float stamina;
  final float maxStamina;
  final double ageSeconds;
  final double lifespanSeconds;
  final float baseSpeed;
  final float sprintSpeed;
  final float visionRange;
  final float visionAngleRadians;

  AnimalSnapshot(
    long id,
    Species species,
    Sex sex,
    AnimalState state,
    float x,
    float y,
    float directionRadians,
    float health,
    float maxHealth,
    float energy,
    float maxEnergy,
    float stamina,
    float maxStamina,
    double ageSeconds,
    double lifespanSeconds,
    float baseSpeed,
    float sprintSpeed,
    float visionRange,
    float visionAngleRadians
  ) {
    this.id = id;
    this.species = Objects.requireNonNull(species, "species");
    this.sex = Objects.requireNonNull(sex, "sex");
    this.state = Objects.requireNonNull(state, "state");
    this.x = x;
    this.y = y;
    this.directionRadians = directionRadians;
    this.health = health;
    this.maxHealth = maxHealth;
    this.energy = energy;
    this.maxEnergy = maxEnergy;
    this.stamina = stamina;
    this.maxStamina = maxStamina;
    this.ageSeconds = ageSeconds;
    this.lifespanSeconds = lifespanSeconds;
    this.baseSpeed = baseSpeed;
    this.sprintSpeed = sprintSpeed;
    this.visionRange = visionRange;
    this.visionAngleRadians = visionAngleRadians;
  }
}

class PlantSnapshot {
  final long id;
  final float x;
  final float y;
  final boolean active;

  PlantSnapshot(
    long id,
    float x,
    float y,
    boolean active
  ) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.active = active;
  }
}

class DisasterSnapshot {
  final DisasterType type;
  final long startStep;
  final long endStep;
  final float centerX;
  final float centerY;
  final float radius;

  DisasterSnapshot(
    DisasterType type,
    long startStep,
    long endStep,
    float centerX,
    float centerY,
    float radius
  ) {
    this.type = Objects.requireNonNull(type, "type");
    this.startStep = startStep;
    this.endStep = endStep;
    this.centerX = centerX;
    this.centerY = centerY;
    this.radius = radius;
  }
}

class SimulationSnapshot {
  final long runId;
  final long step;
  final SimulationState state;
  final double speedMultiplier;
  final float mapWidth;
  final float mapHeight;
  final List<AnimalSnapshot> animals;
  final List<PlantSnapshot> plants;
  final Map<Species, Integer> populationCounts;
  final int activePlantCount;
  final DisasterSnapshot disaster;

  SimulationSnapshot(
    long runId,
    long step,
    SimulationState state,
    double speedMultiplier,
    float mapWidth,
    float mapHeight,
    List<AnimalSnapshot> animals,
    List<PlantSnapshot> plants,
    Map<Species, Integer> populationCounts,
    int activePlantCount,
    DisasterSnapshot disaster
  ) {
    this.runId = runId;
    this.step = step;
    this.state = Objects.requireNonNull(state, "state");
    this.speedMultiplier = speedMultiplier;
    this.mapWidth = mapWidth;
    this.mapHeight = mapHeight;
    this.animals = Collections.unmodifiableList(new ArrayList<AnimalSnapshot>(animals));
    this.plants = Collections.unmodifiableList(new ArrayList<PlantSnapshot>(plants));
    this.populationCounts = copyPopulationCounts(populationCounts);
    this.activePlantCount = activePlantCount;
    this.disaster = Objects.requireNonNull(disaster, "disaster");
  }

  double simulationSeconds() {
    return step * 0.05;
  }
}

class PopulationInitialState {
  final long step = 0L;
  final long runId;
  final Map<Species, Integer> populationCounts;

  PopulationInitialState(
    long runId,
    Map<Species, Integer> populationCounts
  ) {
    this.runId = runId;
    this.populationCounts = copyPopulationCounts(populationCounts);
  }
}

class PopulationEvent {
  final long runId;
  final long eventId;
  final long step;
  final Species species;
  final PopulationEventType type;

  PopulationEvent(
    long runId,
    long eventId,
    long step,
    Species species,
    PopulationEventType type
  ) {
    this.runId = runId;
    this.eventId = eventId;
    this.step = step;
    this.species = Objects.requireNonNull(species, "species");
    this.type = Objects.requireNonNull(type, "type");
  }

  int delta() {
    if (type == PopulationEventType.BIRTH) {
      return 1;
    }
    return -1;
  }
}

class StartSettings {
  final int initialLeopardCats;
  final int initialMartens;
  final double reproductionIntervalMultiplier;

  StartSettings(
    int initialLeopardCats,
    int initialMartens,
    double reproductionIntervalMultiplier
  ) {
    this.initialLeopardCats = initialLeopardCats;
    this.initialMartens = initialMartens;
    this.reproductionIntervalMultiplier = reproductionIntervalMultiplier;
  }
}

// 요청 적용 가능 여부와 설정 범위는 Simulation에서 검증한다.
// START는 설정 생성자, SET_SPEED는 배속 생성자로 만든다.
class SimulationRequest {
  final CommandType type;
  final StartSettings startSettings;
  final double speedMultiplier;

  SimulationRequest(CommandType type) {
    this.type = Objects.requireNonNull(type, "type");
    if (type == CommandType.START || type == CommandType.SET_SPEED) {
      throw new IllegalArgumentException("START and SET_SPEED require a payload.");
    }
    this.startSettings = null;
    this.speedMultiplier = 1.0;
  }

  SimulationRequest(StartSettings startSettings) {
    this.type = CommandType.START;
    this.startSettings = Objects.requireNonNull(startSettings, "startSettings");
    this.speedMultiplier = 1.0;
  }

  SimulationRequest(double speedMultiplier) {
    this.type = CommandType.SET_SPEED;
    this.startSettings = null;
    this.speedMultiplier = speedMultiplier;
  }
}

// 내부 EnumMap을 복사해 여섯 종을 모두 포함하는 읽기 전용 Map을 제공한다.
Map<Species, Integer> copyPopulationCounts(Map<Species, Integer> source) {
  Objects.requireNonNull(source, "populationCounts");
  EnumMap<Species, Integer> copy = new EnumMap<Species, Integer>(Species.class);
  for (Species species : Species.values()) {
    Integer count = source.get(species);
    copy.put(species, count == null ? 0 : count);
  }
  return Collections.unmodifiableMap(copy);
}
