// 담당 A. 개체 상태와 탐색, 추격, 도망, 섭식, 휴식 판단을 담당한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.
class Animal {
  private static final int WANDER_TURN_STEPS = 12;
  private static final int SATED_CYCLE_STEPS = 40;
  private static final float MAX_WANDER_TURN = (float) Math.toRadians(25);
  private static final float SATED_ENERGY = 85;
  private static final float SATED_SPEED_FACTOR = 0.6f;
  final long id;
  final Species species;
  final Sex sex;
  final SpeciesProfile profile;
  final double initialAgeSeconds, lifespanSeconds;
  float x, y, directionRadians;
  float health, energy = 70, stamina = EcosystemConfig.MAX_STAMINA;
  AnimalState state = AnimalState.WANDER;
  private int wanderSteps;
  private int satedSteps;

  Animal(long id, Species species, Sex sex, SpeciesProfile profile) {
    this.id = id;
    this.species = species;
    this.sex = sex;
    this.profile = profile;
    x = random(EcosystemConfig.MAP_WIDTH);
    y = random(EcosystemConfig.MAP_HEIGHT);
    directionRadians = random(TWO_PI);
    health = profile.maxHealth;
    lifespanSeconds = random((float) profile.minLifespanSeconds, (float) profile.maxLifespanSeconds);
    initialAgeSeconds = random((float) profile.maturitySeconds, (float) (lifespanSeconds / 2));
  }

  boolean eatsGrassAsPrimaryFood() {
    return species != Species.LEOPARD_CAT && species != Species.MARTEN;
  }

  Plant nearestVisiblePlant(List<Plant> candidates) {
    Plant nearest = null;
    float nearestDistanceSquared = Float.POSITIVE_INFINITY;
    float forwardX = cos(directionRadians);
    float forwardY = sin(directionRadians);
    float minimumCosine = cos(profile.visionAngleRadians / 2);
    float rangeSquared = profile.visionRange * profile.visionRange;
    for (Plant plant : candidates) {
      float dx = plant.x - x;
      float dy = plant.y - y;
      float distanceSquared = dx * dx + dy * dy;
      if (!plant.active || distanceSquared > rangeSquared || distanceSquared >= nearestDistanceSquared) continue;
      if (dx * forwardX + dy * forwardY < sqrt(distanceSquared) * minimumCosine) continue;
      nearest = plant;
      nearestDistanceSquared = distanceSquared;
    }
    return nearest;
  }

  void move(Plant target) {
    if (target != null && energy < SATED_ENERGY) {
      state = AnimalState.SEEK_FOOD;
      wanderSteps = 0;
      satedSteps = 0;
      float dx = target.x - x;
      float dy = target.y - y;
      if (dx == 0 && dy == 0) return;
      directionRadians = atan2(dy, dx);
      moveForward(min(sqrt(dx * dx + dy * dy), (float) (profile.baseSpeed * EcosystemConfig.STEP_SECONDS)));
      return;
    }

    state = AnimalState.WANDER;
    float speed = profile.baseSpeed;
    if (energy >= SATED_ENERGY) {
      boolean moving = satedSteps < SATED_CYCLE_STEPS / 2;
      satedSteps = (satedSteps + 1) % SATED_CYCLE_STEPS;
      if (!moving) return;
      speed *= SATED_SPEED_FACTOR;
    } else {
      satedSteps = 0;
    }
    if (++wanderSteps == WANDER_TURN_STEPS) {
      directionRadians += random(-MAX_WANDER_TURN, MAX_WANDER_TURN);
      wanderSteps = 0;
    }
    moveForward((float) (speed * EcosystemConfig.STEP_SECONDS));
  }

  private void moveForward(float distance) {
    float dx = cos(directionRadians) * distance;
    float dy = sin(directionRadians) * distance;
    x += dx;
    y += dy;
    if ((x <= 0 && dx < 0) || (x >= EcosystemConfig.MAP_WIDTH && dx > 0)) {
      x = constrain(x, 0, EcosystemConfig.MAP_WIDTH);
      directionRadians = PI - directionRadians;
    }
    if ((y <= 0 && dy < 0) || (y >= EcosystemConfig.MAP_HEIGHT && dy > 0)) {
      y = constrain(y, 0, EcosystemConfig.MAP_HEIGHT);
      directionRadians = -directionRadians;
    }
    directionRadians = (directionRadians % TWO_PI + TWO_PI) % TWO_PI;
  }

  AnimalSnapshot snapshot(double elapsedSeconds) {
    return new AnimalSnapshot(id, species, sex, state, x, y, directionRadians,
      health, profile.maxHealth, energy, EcosystemConfig.MAX_ENERGY, stamina, EcosystemConfig.MAX_STAMINA,
      initialAgeSeconds + elapsedSeconds, lifespanSeconds, profile.baseSpeed,
      profile.sprintSpeed, profile.visionRange, profile.visionAngleRadians);
  }
}
