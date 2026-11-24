// 담당 A. 종별 이동속도, 시야, 체력, 수명과 번식 능력치를 담당한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.
class SpeciesProfile {
  final float baseSpeed, sprintSpeed, visionRange, visionAngleRadians, maxHealth, attackDamage;
  final double maturitySeconds, reproductionIntervalSeconds, minLifespanSeconds, maxLifespanSeconds;

  SpeciesProfile(float baseSpeed, float sprintSpeed, float visionRange, float visionAngleDegrees,
    float maxHealth, int maturityDays, int reproductionDays, int minLifespanDays,
    int maxLifespanDays, float attackDamage) {
    this.baseSpeed = baseSpeed;
    this.sprintSpeed = sprintSpeed;
    this.visionRange = visionRange;
    this.visionAngleRadians = (float) Math.toRadians(visionAngleDegrees);
    this.maxHealth = maxHealth;
    this.maturitySeconds = maturityDays * EcosystemConfig.DAY_SECONDS;
    this.reproductionIntervalSeconds = reproductionDays * EcosystemConfig.DAY_SECONDS;
    this.minLifespanSeconds = minLifespanDays * EcosystemConfig.DAY_SECONDS;
    this.maxLifespanSeconds = maxLifespanDays * EcosystemConfig.DAY_SECONDS;
    this.attackDamage = attackDamage;
  }
}
