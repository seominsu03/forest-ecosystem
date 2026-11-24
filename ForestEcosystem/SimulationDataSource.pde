// A의 계산과 B의 표시를 연결한다. 생태 규칙이나 공통 자료형은 바꾸지 않는다.
// 현재 A 브랜치에는 출생·사망 사건 API가 없어 ViewDataSource로 연결한다.
class SimulationDataSource implements ViewDataSource {
  final Simulation simulation = new Simulation();
  long previousNanos = System.nanoTime();

  void advanceToNow() {
    long now = System.nanoTime();
    double elapsed = (now - previousNanos) / 1000000000.0;
    previousNanos = now;
    simulation.advance(elapsed);
  }

  public SimulationSnapshot snapshot() {
    return simulation.snapshot();
  }

  public void submit(SimulationRequest request) {
    // 요청 직전까지의 시간은 이전 진행 상태·배속으로 처리한다.
    // 대기·정지 시간은 A가 무시하며 재개 때 한꺼번에 진행되지 않는다.
    advanceToNow();
    simulation.applyRequest(Objects.requireNonNull(request, "request"));
  }
}
