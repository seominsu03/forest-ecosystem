// 담당 A. 지도, 초기 수량, 먹이 관계와 환경 설정을 담당한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.
class EcosystemConfig {
  static final double STEP_SECONDS = 0.05d;
  static final double DAY_SECONDS = 30.0;
  static final float MAP_WIDTH = 200;
  static final float MAP_HEIGHT = 150;
  static final int INITIAL_PLANTS = 120;
  static final float MAX_ENERGY = 100;
  static final float MAX_STAMINA = 100;

  final Map<Species, SpeciesProfile> profiles = new EnumMap<Species, SpeciesProfile>(Species.class);

  EcosystemConfig() {
    profiles.put(Species.HARE, new SpeciesProfile(5.0f, 9.4f, 23, 120, 65, 2, 3, 12, 17, 0));
    profiles.put(Species.VOLE, new SpeciesProfile(4.2f, 7.4f, 16, 105, 42, 1, 2, 7, 11, 0));
    profiles.put(Species.ROE_DEER, new SpeciesProfile(4.8f, 9.0f, 26, 135, 100, 3, 4, 15, 22, 0));
    profiles.put(Species.WATER_DEER, new SpeciesProfile(4.5f, 8.1f, 21, 120, 118, 3, 4, 14, 20, 0));
    profiles.put(Species.LEOPARD_CAT, new SpeciesProfile(5.2f, 10.2f, 25, 105, 82, 3, 5, 13, 19, 24));
    profiles.put(Species.MARTEN, new SpeciesProfile(5.0f, 9.6f, 23, 110, 94, 3, 4, 12, 18, 28));
  }

  StartSettings defaultStartSettings() {
    return new StartSettings(4, 4, 1.0);
  }

  int initialCount(Species species, StartSettings settings) {
    switch (species) {
      case LEOPARD_CAT: return settings.initialLeopardCats;
      case MARTEN: return settings.initialMartens;
      default: return 16;
    }
  }

  boolean validStartSettings(StartSettings settings) {
    double multiplier = settings.reproductionIntervalMultiplier;
    return validPredatorCount(settings.initialLeopardCats)
      && validPredatorCount(settings.initialMartens)
      && multiplier >= 0.5 && multiplier <= 2.0
      && Math.rint(multiplier * 4) == multiplier * 4;
  }

  private boolean validPredatorCount(int count) {
    return count >= 0 && count <= 20 && count % 2 == 0;
  }
}
