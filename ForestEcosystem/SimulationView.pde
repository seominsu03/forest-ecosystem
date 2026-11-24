// 담당 B. 완료된 스냅샷을 읽어서 그린다.
class SimulationView {
  final Camera2D camera = new Camera2D(0, 65, 900, 675, 200, 150);
  final MapScene scene;
  final String[] speciesNames = {"멧토끼", "대륙밭쥐", "노루", "고라니", "삵", "담비"};
  final int[] speciesColors = {
    color(245, 236, 208), color(130, 108, 88), color(219, 150, 79),
    color(173, 110, 61), color(98, 122, 160), color(239, 187, 49)
  };
  SimulationSnapshot latest;
  long selectedId = -1;
  long displayedRun = -1;
  String sourceLabel = "";
  boolean pressed;
  boolean dragged;
  float pressX;
  float pressY;
  float lastDragX;
  float lastDragY;

  SimulationView(MapScene scene) {
    this.scene = scene;
  }

  void setSourceLabel(String label) {
    sourceLabel = label;
    selectedId = -1;
    displayedRun = -1;
  }

  void render(SimulationSnapshot snapshot) {
    latest = Objects.requireNonNull(snapshot, "snapshot");
    if (displayedRun != snapshot.runId) {
      selectedId = -1;
      pressed = false;
      camera.reset();
      displayedRun = snapshot.runId;
    }
    if (camera.mapWidth != snapshot.mapWidth || camera.mapHeight != snapshot.mapHeight) {
      camera.setMapSize(snapshot.mapWidth, snapshot.mapHeight);
    }
    background(232, 237, 228);
    pushStyle();
    clip(0, 65, 900, 675);
    pushMatrix();
    translate(camera.viewportWidth / 2, camera.viewportY + camera.viewportHeight / 2);
    scale(camera.pixelsPerUnit());
    translate(-camera.centerX, -camera.centerY);
    scene.drawGround(snapshot.mapWidth, snapshot.mapHeight);
    scene.drawDecorations();
    scene.drawPlants(snapshot.plants);
    AnimalSnapshot selected = selectedAnimal();
    if (selected != null) drawVision(selected);
    for (AnimalSnapshot animal : snapshot.animals) drawAnimal(animal);
    popMatrix();
    noClip();
    drawHeader(snapshot);
    drawPanel(selected);
    popStyle();
  }

  void drawAnimal(AnimalSnapshot animal) {
    int index = animal.species.ordinal();
    pushMatrix();
    translate(animal.x, animal.y);
    rotate(animal.directionRadians);
    stroke(42, 56, 41);
    strokeWeight(1 / camera.pixelsPerUnit());
    fill(speciesColors[index]);
    ellipse(0, 0, 2.8f, 1.9f);
    ellipse(1.25f, 0, 1.2f, 1.2f);
    if (animal.species == Species.HARE) {
      line(1.1f, -0.4f, 1.9f, -0.9f);
      line(1.1f, 0.4f, 1.9f, 0.9f);
    }
    if (index >= 4) line(-1.1f, 0, -2.2f, 0.4f);
    popMatrix();
    if (animal.id == selectedId) {
      noFill();
      stroke(255, 255, 245);
      strokeWeight(2 / camera.pixelsPerUnit());
      ellipse(animal.x, animal.y, 4.8f, 4.8f);
    }
  }

  void drawVision(AnimalSnapshot animal) {
    noStroke();
    fill(40, 89, 138, 25);
    arc(animal.x, animal.y, animal.visionRange * 2, animal.visionRange * 2,
        animal.directionRadians - animal.visionAngleRadians / 2,
        animal.directionRadians + animal.visionAngleRadians / 2, PIE);
  }

  void drawHeader(SimulationSnapshot snapshot) {
    noStroke();
    fill(33, 59, 43);
    rect(0, 0, width, 65);
    fill(247, 247, 231);
    textAlign(LEFT, TOP);
    textSize(20);
    text("한국 숲 · 관찰 지도", 20, 10);
    textSize(12);
    text("드래그 이동   휠 확대·축소   동물 클릭   R 카메라 초기화", 20, 39);
    textAlign(RIGHT, TOP);
    text(sourceLabel, width - 18, 11);
    text("배율 " + nf(camera.zoom, 1, 2) + "   ·   지도 "
        + nf(snapshot.mapWidth, 1, 0) + " × " + nf(snapshot.mapHeight, 1, 0), width - 18, 37);
    noStroke();
    fill(33, 59, 43, 220);
    rect(14, 80, 235, 34, 6);
    fill(255);
    textAlign(LEFT, CENTER);
    text("동물 " + snapshot.animals.size() + "마리  ·  풀 " + snapshot.activePlantCount + "개", 26, 97);
  }

  void drawPanel(AnimalSnapshot selected) {
    noStroke();
    fill(249, 248, 240);
    rect(900, 65, 300, 675);
    fill(38, 64, 46);
    textAlign(LEFT, TOP);
    textSize(20);
    text("개체 정보", 920, 84);
    textSize(13);
    if (selected == null) {
      text("지도에서 동물을 클릭하세요.", 920, 125);
    } else {
      textSize(18);
      text(speciesNames[selected.species.ordinal()] + "  #" + selected.id, 920, 123);
      textSize(13);
      text("성별  " + (selected.sex == Sex.MALE ? "수컷" : "암컷"), 920, 157);
      text("행동  " + actionName(selected.state), 920, 181);
      statBar("체력", selected.health, selected.maxHealth, 220, color(172, 81, 67));
      statBar("에너지", selected.energy, selected.maxEnergy, 265, color(185, 144, 52));
      statBar("지구력", selected.stamina, selected.maxStamina, 310, color(65, 135, 114));
      fill(38, 64, 46);
      text("나이 / 수명  " + nf((float)(selected.ageSeconds / 30), 1, 1)
          + " / " + nf((float)(selected.lifespanSeconds / 30), 1, 1) + "일", 920, 362);
      text("기본 / 질주 속도  " + selected.baseSpeed + " / " + selected.sprintSpeed, 920, 390);
      text("감지 거리  " + selected.visionRange, 920, 418);
      text("시야각  " + round(degrees(selected.visionAngleRadians)) + "°", 920, 446);
      text("지도 위치  " + nf(selected.x, 1, 1) + ", " + nf(selected.y, 1, 1), 920, 474);
    }
    fill(38, 64, 46);
    textSize(14);
    text("종별 색상", 920, 520);
    for (int i = 0; i < speciesNames.length; i++) {
      int column = i % 2;
      int row = i / 2;
      fill(speciesColors[i]);
      stroke(90, 100, 80);
      ellipse(930 + column * 140, 559 + row * 28, 12, 12);
      noStroke();
      fill(38, 64, 46);
      textSize(12);
      text(speciesNames[i], 945 + column * 140, 550 + row * 28);
    }
    textSize(12);
    fill(91, 101, 87);
    text("동물은 종별 도형으로 표시합니다.\n강과 호수는 배경 배치 예시입니다.", 920, 672);
  }

  void statBar(String label, float value, float maximum, float y, int barColor) {
    textAlign(LEFT, TOP);
    fill(38, 64, 46);
    text(label + "  " + nf(value, 1, 0) + " / " + nf(maximum, 1, 0), 920, y);
    fill(223, 226, 214);
    rect(920, y + 23, 258, 9, 4);
    fill(barColor);
    float fraction = maximum > 0 ? constrain(value / maximum, 0, 1) : 0;
    rect(920, y + 23, 258 * fraction, 9, 4);
  }

  String actionName(AnimalState state) {
    String[] labels = {"탐색", "먹이로 이동", "추격", "공격", "도망", "섭식", "휴식"};
    return labels[state.ordinal()];
  }

  AnimalSnapshot selectedAnimal() {
    for (AnimalSnapshot animal : latest.animals) {
      if (animal.id == selectedId) return animal;
    }
    selectedId = -1;
    return null;
  }

  void press(float x, float y) {
    pressed = camera.contains(x, y) && !overMapLabel(x, y);
    dragged = false;
    pressX = lastDragX = x;
    pressY = lastDragY = y;
  }

  void drag(float x, float y) {
    if (!pressed) return;
    if (!dragged && dist(x, y, pressX, pressY) < 5) return;
    dragged = true;
    camera.pan(x - lastDragX, y - lastDragY);
    lastDragX = x;
    lastDragY = y;
  }

  void release(float x, float y) {
    if (pressed && !dragged && dist(x, y, pressX, pressY) >= 5) {
      drag(x, y);
    }
    if (pressed && !dragged && camera.contains(x, y) && latest != null) {
      selectedId = -1;
      float nearest = max(7, 2 * camera.pixelsPerUnit());
      // 겹친 동물은 위에 그린 개체부터 살피고 클릭 위치에 가장 가까운 중심을 선택한다.
      for (int i = latest.animals.size() - 1; i >= 0; i--) {
        AnimalSnapshot animal = latest.animals.get(i);
        PVector position = camera.worldToScreen(animal.x, animal.y);
        float distance = dist(x, y, position.x, position.y);
        if (distance < nearest) {
          selectedId = animal.id;
          nearest = distance;
        }
      }
    }
    pressed = false;
  }

  boolean overMapLabel(float x, float y) {
    return x >= 14 && x <= 249 && y >= 80 && y <= 114;
  }

  void wheel(float x, float y, float count) {
    if (camera.contains(x, y)) camera.zoomAt(x, y, count);
  }
}
