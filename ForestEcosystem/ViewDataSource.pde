// B의 화면이 읽을 데이터와 A로 보낼 요청을 연결하는 경계다.
// A는 이 인터페이스를 구현한 어댑터에서 자신의 Simulation을 호출하면 된다.
interface ViewDataSource {
  SimulationSnapshot snapshot();
  void submit(SimulationRequest request);
}

// 출생·사망을 빠짐없이 전달하는 선택적 연결 경로다. 기존 ViewDataSource도 유지한다.
interface PopulationDataSource extends ViewDataSource {
  PopulationInitialState initialPopulation();
  // 최초 요청 커서는 -1이다. 0부터 시작하는 사건도 포함해 반환한다.
  List<PopulationEvent> populationEventsAfter(long eventId);
}
