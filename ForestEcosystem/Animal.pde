// 담당 A. 개체 상태와 탐색, 추격, 도망, 섭식, 휴식 판단을 담당한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.
class Animal {
  final long id;
  final Species species;
  final Sex sex;
  final SpeciesProfile profile;
  final double initialAgeSeconds, lifespanSeconds;
  float x, y, directionRadians;
  float health, energy = 70, stamina = EcosystemConfig.MAX_STAMINA;
  AnimalState state = AnimalState.WANDER;

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

  AnimalSnapshot snapshot(double elapsedSeconds) {
    return new AnimalSnapshot(id, species, sex, state, x, y, directionRadians,
      health, profile.maxHealth, energy, EcosystemConfig.MAX_ENERGY, stamina, EcosystemConfig.MAX_STAMINA,
      initialAgeSeconds + elapsedSeconds, lifespanSeconds, profile.baseSpeed,
      profile.sprintSpeed, profile.visionRange, profile.visionAngleRadians);
  }
}
