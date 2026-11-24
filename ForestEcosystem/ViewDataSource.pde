// B의 화면이 읽을 데이터와 A로 보낼 요청을 연결하는 경계다.
// A는 이 인터페이스를 구현한 어댑터에서 자신의 Simulation을 호출하면 된다.
interface ViewDataSource {
  SimulationSnapshot snapshot();
  void submit(SimulationRequest request);
}
