// 담당 B. 설정은 다음 START의 입력이며, 진행 상태는 A의 스냅샷만 따른다.
class SimulationControls {
  int leopardCats = 4;
  int martens = 4;
  int reproductionQuarters = 4;
  int pressedButton = -1;
  float pressedX, pressedY;
  SimulationSnapshot snapshot;
  ViewDataSource source;
  String lastRequest = "아직 보낸 요청이 없습니다.";
  final double[] speeds = {0.5, 1.0, 3.0};

  void connect(SimulationSnapshot snapshot, ViewDataSource source) {
    this.snapshot = snapshot;
    this.source = source;
  }

  void clearConnection() {
    pressedButton = -1;
    snapshot = null;
    source = null;
    lastRequest = "아직 보낸 요청이 없습니다.";
  }

  boolean enabled(int id) {
    if (snapshot == null || source == null) return false;
    if (id == 0) return snapshot.state == SimulationState.READY;
    if (id == 1) return snapshot.state == SimulationState.RUNNING
      || snapshot.state == SimulationState.PAUSED;
    if (id == 2) return true;
    if (id >= 3 && id <= 5) return snapshot.state == SimulationState.RUNNING
      || snapshot.state == SimulationState.PAUSED;
    if (snapshot.state != SimulationState.READY) return false;
    if (id == 6) return leopardCats > 0;
    if (id == 7) return leopardCats < 20;
    if (id == 8) return martens > 0;
    if (id == 9) return martens < 20;
    if (id == 10) return reproductionQuarters > 2;
    if (id == 11) return reproductionQuarters < 8;
    return false;
  }

  float buttonX(int id) {
    if (id == 0) return 260;
    if (id == 1) return 340;
    if (id == 2) return 442;
    if (id <= 5) return 540 + (id - 3) * 72;
    return id % 2 == 0 ? 922 : 1136;
  }

  float buttonY(int id) {
    return id <= 5 ? 10 : 220 + ((id - 6) / 2) * 100;
  }

  float buttonWidth(int id) {
    if (id == 0) return 72;
    if (id == 1 || id == 2) return 94;
    return id <= 5 ? 64 : 40;
  }

  boolean inside(int id, float x, float y) {
    return x >= buttonX(id) && x < buttonX(id) + buttonWidth(id)
      && y >= buttonY(id) && y < buttonY(id) + 30;
  }

  int buttonAt(float x, float y, boolean settingsVisible) {
    for (int id = 0; id < (settingsVisible ? 12 : 6); id++) {
      if (inside(id, x, y)) return id;
    }
    return -1;
  }

  void drawButton(int id, String label, boolean selected) {
    boolean available = enabled(id);
    noStroke();
    fill(!available ? color(207, 214, 200)
      : selected ? color(209, 172, 74) : color(234, 239, 225));
    rect(buttonX(id), buttonY(id), buttonWidth(id), 30, 4);
    fill(available ? color(34, 61, 43) : color(124, 135, 119));
    textSize(13);
    textAlign(CENTER, CENTER);
    text(label, buttonX(id) + buttonWidth(id) / 2, buttonY(id) + 15);
    textAlign(LEFT, TOP);
  }

  String stateName() {
    if (snapshot.state == SimulationState.READY) return "시작 대기";
    if (snapshot.state == SimulationState.RUNNING) return "진행 중";
    if (snapshot.state == SimulationState.PAUSED) return "일시정지";
    return "종료";
  }

  void drawToolbar() {
    drawButton(0, "시작", false);
    drawButton(1, snapshot.state == SimulationState.PAUSED ? "재개" : "일시정지", false);
    drawButton(2, "초기화", false);
    for (int i = 0; i < speeds.length; i++) {
      drawButton(3 + i, speeds[i] + "배", snapshot.speedMultiplier == speeds[i]);
    }
    fill(247, 247, 231);
    textSize(13);
    textAlign(RIGHT, TOP);
    text(stateName() + " · " + snapshot.speedMultiplier + "배 · "
      + nf((float)(snapshot.step / 600.0), 1, 2) + "일", 1182, 12);
    textSize(11);
    text(lastRequest, 1182, 43);
    textAlign(LEFT, TOP);
  }

  void drawSettings() {
    fill(38, 64, 46);
    textAlign(LEFT, TOP);
    textSize(19);
    text("시작 설정", 920, 135);
    textSize(12);
    text("시작 대기에서만 변경할 수 있습니다.", 920, 170);
    String[] labels = {"삵 초기 수", "담비 초기 수", "번식 간격 배율"};
    String[] values = {leopardCats + "마리", martens + "마리",
      nf(reproductionQuarters / 4.0f, 1, 2) + "배"};
    String[] ranges = {"0~20마리 · 2마리 단위", "0~20마리 · 2마리 단위",
      "0.50~2.00배 · 0.25배 단위"};
    for (int row = 0; row < 3; row++) {
      fill(38, 64, 46);
      textSize(14);
      text(labels[row], 920, 197 + row * 100);
      drawButton(6 + row * 2, "−", false);
      drawButton(7 + row * 2, "+", false);
      fill(38, 64, 46);
      textAlign(CENTER, CENTER);
      text(values[row], 1050, 235 + row * 100);
      textAlign(LEFT, TOP);
      textSize(11);
      text(ranges[row], 920, 260 + row * 100);
    }
    fill(80, 96, 75);
    textSize(12);
    text("배율이 작을수록 번식 간격이 짧아집니다.\n설정은 시작 버튼을 누를 때 전달합니다.\n초기화해도 입력한 설정은 보존합니다.", 920, 500);
    text("요청 전송과 실제 적용은 다릅니다.\n상단 상태·배속은 수신한 결과입니다.", 920, 578);
    if (source instanceof ExampleDataSource) {
      text("현재는 정적 예시 데이터입니다.\n요청만 보관하며 진행·설정은 적용하지\n않습니다. A의 데이터 연결이 필요합니다.", 920, 640);
    }
  }

  boolean press(float x, float y, boolean settingsVisible) {
    pressedButton = buttonAt(x, y, settingsVisible);
    pressedX = x;
    pressedY = y;
    return pressedButton >= 0;
  }

  boolean release(float x, float y, boolean settingsVisible) {
    int id = pressedButton;
    pressedButton = -1;
    if (id < 0) return false;
    if (id == buttonAt(x, y, settingsVisible)
      && dist(x, y, pressedX, pressedY) < 5 && enabled(id)) activate(id);
    return true;
  }

  void activate(int id) {
    if (id >= 6) {
      if (id == 6) leopardCats -= 2;
      if (id == 7) leopardCats += 2;
      if (id == 8) martens -= 2;
      if (id == 9) martens += 2;
      if (id == 10) reproductionQuarters--;
      if (id == 11) reproductionQuarters++;
      return;
    }
    SimulationRequest request;
    String label;
    if (id == 0) {
      request = new SimulationRequest(new StartSettings(leopardCats, martens,
        reproductionQuarters / 4.0));
      label = "시작";
    } else if (id == 1) {
      boolean paused = snapshot.state == SimulationState.PAUSED;
      request = new SimulationRequest(paused ? CommandType.RESUME : CommandType.PAUSE);
      label = paused ? "재개" : "일시정지";
    } else if (id == 2) {
      request = new SimulationRequest(CommandType.RESET);
      label = "초기화";
    } else {
      request = new SimulationRequest(speeds[id - 3]);
      label = speeds[id - 3] + "배속";
    }
    source.submit(request);
    lastRequest = label + " 요청 전송 · 적용 결과는 상태 표시 확인";
  }
}
