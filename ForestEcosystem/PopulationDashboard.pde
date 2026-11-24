// 담당 B. 현재 수량은 스냅샷에서, 그래프는 PopulationHistory에서 읽는다.
class PopulationDashboard {
  final String[] names;
  final int[] colors;
  final String[] tabs = {"개체 정보", "그래프", "피라미드", "설정"};

  PopulationDashboard(String[] names, int[] colors) {
    this.names = names;
    this.colors = colors;
  }

  int tabAt(float x, float y) {
    if (y < 78 || y >= 112 || x < 912 || x >= 1188) return -1;
    return (int)((x - 912) / 69);
  }

  void drawTabs(int selected) {
    textAlign(CENTER, CENTER);
    textSize(13);
    for (int i = 0; i < tabs.length; i++) {
      noStroke();
      fill(i == selected ? color(54, 91, 64) : color(225, 230, 216));
      rect(912 + i * 69, 78, 65, 34, 5);
      fill(i == selected ? color(255) : color(40, 65, 46));
      text(tabs[i], 944.5f + i * 69, 95);
    }
    textAlign(LEFT, TOP);
  }

  int total(SimulationSnapshot snapshot, int from, int to) {
    int result = 0;
    Species[] all = Species.values();
    for (int i = from; i < to; i++) result += snapshot.populationCounts.get(all[i]);
    return result;
  }

  void drawSmallPyramid(SimulationSnapshot snapshot) {
    noStroke();
    fill(33, 59, 43, 230);
    rect(14, 80, 206, 112, 7);
    fill(255);
    textAlign(LEFT, TOP);
    textSize(12);
    text("먹이 피라미드 · 현재 수량", 25, 89);
    int[] amounts = {total(snapshot, 4, 6), total(snapshot, 0, 4), snapshot.activePlantCount};
    String[] labels = {"포식자", "초식동물", "풀"};
    int[] palette = {color(226, 155, 86), color(174, 199, 107), color(88, 166, 111)};
    int maximum = max(1, max(amounts[0], max(amounts[1], amounts[2])));
    for (int i = 0; i < amounts.length; i++) {
      float y = 116 + i * 23;
      fill(255);
      text(labels[i] + " " + amounts[i], 25, y);
      fill(palette[i]);
      float span = 78 * (float)amounts[i] / maximum;
      rect(170 - span / 2, y + 1, span, 13);
    }
  }

  void drawPyramid(SimulationSnapshot snapshot) {
    textAlign(LEFT, TOP);
    fill(38, 64, 46);
    textSize(19);
    text("먹이 피라미드", 920, 134);
    textSize(12);
    text("층의 폭 = 현재 수량 비율", 920, 165);
    int[] amounts = {total(snapshot, 4, 6), total(snapshot, 0, 4), snapshot.activePlantCount};
    int maximum = max(1, max(amounts[0], max(amounts[1], amounts[2])));
    String[] labels = {"3단계 · 포식자", "2단계 · 초식동물", "1단계 · 생산자"};
    String[] members = {"삵 · 담비", "멧토끼 · 대륙밭쥐 · 노루 · 고라니", "풀"};
    int[] palette = {color(226, 155, 86), color(174, 199, 107), color(88, 166, 111)};
    for (int i = 0; i < amounts.length; i++) {
      float y = 210 + i * 137;
      fill(38, 64, 46);
      textSize(14);
      text(labels[i] + "  " + amounts[i], 920, y);
      float span = 250 * (float)amounts[i] / maximum;
      noStroke();
      fill(palette[i]);
      quad(1050 - span * 0.36f, y + 32, 1050 + span * 0.36f, y + 32,
           1050 + span / 2, y + 86, 1050 - span / 2, y + 86);
      fill(80, 96, 75);
      textSize(11);
      text(members[i], 920, y + 98);
    }
    fill(80, 96, 75);
    text("0개인 층은 폭이 0으로 표시됩니다.\n위층이 아래층보다 넓어질 수 있습니다.", 920, 666);
  }

  void drawGraph(PopulationHistory history, SimulationSnapshot snapshot) {
    textAlign(LEFT, TOP);
    fill(38, 64, 46);
    textSize(18);
    text("종별 개체 수", 920, 134);
    textSize(12);
    text("시뮬레이션 " + nf((float)(snapshot.step / 600.0), 1, 2) + "일", 920, 165);
    float left = 938;
    float top = 212;
    float chartWidth = 238;
    float chartHeight = 220;
    long startStep = Math.max(0L, snapshot.step - 18000L);
    long endStep = Math.max(startStep + 600L, snapshot.step);
    int maximum = 1;
    int first = 0;
    while (first + 1 < history.points.size()
           && history.points.get(first + 1).step <= startStep) first++;
    for (int i = first; i < history.points.size(); i++) {
      for (int count : history.points.get(i).counts.values()) maximum = max(maximum, count);
    }
    maximum = max(5, (int)Math.ceil(maximum / 5.0) * 5);
    noStroke();
    fill(232, 237, 223);
    rect(left, top, chartWidth, chartHeight);
    textSize(11);
    for (int tick = 0; tick <= 4; tick++) {
      float y = top + chartHeight * tick / 4;
      stroke(207, 216, 197);
      line(left, y, left + chartWidth, y);
      fill(70, 91, 67);
      textAlign(RIGHT, CENTER);
      text(round(maximum * (4 - tick) / 4.0f), left - 5, y);
    }
    for (Species species : Species.values()) {
      stroke(lerpColor(colors[species.ordinal()], color(40, 60, 43), 0.2f));
      strokeWeight(2);
      for (int i = first; i < history.points.size(); i++) {
        PopulationPoint point = history.points.get(i);
        long until = i + 1 < history.points.size()
          ? history.points.get(i + 1).step : history.latestStep;
        float x1 = graphX(point.step, startStep, endStep, left, chartWidth);
        float x2 = graphX(until, startStep, endStep, left, chartWidth);
        float y = top + chartHeight - chartHeight * point.counts.get(species) / maximum;
        line(x1, y, x2, y);
        if (i + 1 < history.points.size()) {
          int nextCount = history.points.get(i + 1).counts.get(species);
          float nextY = top + chartHeight - chartHeight * nextCount / maximum;
          line(x2, y, x2, nextY);
        }
        point(x1, y);
      }
    }
    strokeWeight(1);
    fill(70, 91, 67);
    textSize(11);
    textAlign(LEFT, TOP);
    text(nf((float)(startStep / 600.0), 1, 1) + "일", left, top + chartHeight + 10);
    textAlign(RIGHT, TOP);
    text(nf((float)(endStep / 600.0), 1, 1) + "일", left + chartWidth, top + chartHeight + 10);
    textAlign(LEFT, TOP);
    textSize(12);
    for (Species species : Species.values()) {
      int index = species.ordinal();
      int column = index % 2;
      int row = index / 2;
      float x = 920 + column * 140;
      float y = 490 + row * 36;
      stroke(lerpColor(colors[index], color(40, 60, 43), 0.2f));
      strokeWeight(3);
      line(x, y + 8, x + 12, y + 8);
      noStroke();
      fill(38, 64, 46);
      text(names[index] + " " + snapshot.populationCounts.get(species), x + 18, y);
    }
    fill(80, 96, 75);
    textSize(11);
    text("최근 30일 · 같은 수량의 선은 겹칩니다.", 920, 612);
    if (snapshot.step == 0) {
      text("현재는 시작점만 기록된 상태입니다.", 920, 636);
    } else {
      text("시간축은 시뮬레이션 날짜입니다.", 920, 636);
    }
    text(history.notice, 920, 666, 260, 58);
  }

  float graphX(long step, long start, long end, float left, float chartWidth) {
    float fraction = (float)((double)(step - start) / (end - start));
    return left + chartWidth * constrain(fraction, 0, 1);
  }
}
