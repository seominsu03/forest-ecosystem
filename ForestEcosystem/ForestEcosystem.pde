// 담당 B. 실제 데이터 연결 시 A와 프로그램 진입점의 호출 순서를 맞춘다.
import processing.event.MouseEvent;

ViewDataSource viewDataSource;
SimulationView simulationView;
SimulationDataSource simulationDataSource;

void setup() {
  size(1200, 740);
  noSmooth();
  surface.setTitle("Forest Ecosystem");
  textFont(createFont("Malgun Gothic", 16));
  frameRate(60);
  MapScene scene = new MapScene();
  simulationView = new SimulationView(scene);
  simulationDataSource = new SimulationDataSource();
  connectViewDataSource(simulationDataSource, "실제 시뮬레이션 · 이동과 풀 섭취");
}

// A가 ViewDataSource를 구현한 어댑터를 전달하면 같은 표시 경로를 사용한다.
void connectViewDataSource(ViewDataSource source, String label) {
  viewDataSource = Objects.requireNonNull(source, "source");
  simulationView.setSourceLabel(label);
}

void draw() {
  if (viewDataSource == simulationDataSource) simulationDataSource.advanceToNow();
  simulationView.render(viewDataSource.snapshot(), viewDataSource);
}

void mousePressed() {
  if (mouseButton == LEFT) simulationView.press(mouseX, mouseY);
}

void mouseDragged() {
  simulationView.drag(mouseX, mouseY);
}

void mouseReleased() {
  simulationView.release(mouseX, mouseY);
}

void mouseWheel(MouseEvent event) {
  simulationView.wheel(mouseX, mouseY, event.getCount());
}

void keyPressed() {
  if (key == 'r' || key == 'R') simulationView.camera.reset();
}
