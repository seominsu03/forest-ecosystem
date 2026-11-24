// 담당 B. 실행 ID와 사건 번호로 중복을 막고 단계별 최종 개체 수를 보관한다.
class PopulationPoint {
  final long step;
  final Map<Species, Integer> counts;

  PopulationPoint(long step, Map<Species, Integer> counts) {
    this.step = step;
    this.counts = copyPopulationCounts(counts);
  }
}

class PopulationHistory {
  final ArrayList<PopulationPoint> points = new ArrayList<PopulationPoint>();
  final ArrayList<PopulationEvent> recordedEvents = new ArrayList<PopulationEvent>();
  final EnumMap<Species, Integer> counts = new EnumMap<Species, Integer>(Species.class);
  long runId = -1;
  long latestStep = 0;
  long lastEventId = -1;
  boolean eventMode;
  String notice = "";

  void clear() {
    points.clear();
    recordedEvents.clear();
    counts.clear();
    runId = -1;
    latestStep = 0;
    lastEventId = -1;
    notice = "";
  }

  void update(SimulationSnapshot snapshot, ViewDataSource source) {
    boolean hasEvents = source instanceof PopulationDataSource;
    if (runId != snapshot.runId || snapshot.step < latestStep || eventMode != hasEvents) {
      clear();
      eventMode = hasEvents;
      runId = snapshot.runId;
      if (hasEvents) {
        PopulationInitialState initial = ((PopulationDataSource)source).initialPopulation();
        if (initial == null || initial.runId != runId) {
          runId = -1;
          notice = "초기 개체 수 기록 수신 대기";
          return;
        }
        counts.putAll(initial.populationCounts);
        points.add(new PopulationPoint(initial.step, counts));
      } else {
        counts.putAll(snapshot.populationCounts);
        points.add(new PopulationPoint(snapshot.step, counts));
      }
    }
    latestStep = snapshot.step;
    if (!hasEvents) {
      notice = "시점별 집계 · 출생/사망 기록 연결 대기";
      if (!counts.equals(snapshot.populationCounts)) {
        counts.clear();
        counts.putAll(snapshot.populationCounts);
        record(snapshot.step);
      }
      return;
    }
    PopulationDataSource eventsSource = (PopulationDataSource)source;
    List<PopulationEvent> batch = eventsSource.populationEventsAfter(lastEventId);
    ArrayList<PopulationEvent> events = new ArrayList<PopulationEvent>(batch);
    Collections.sort(events, new java.util.Comparator<PopulationEvent>() {
      public int compare(PopulationEvent first, PopulationEvent second) {
        return Long.compare(first.eventId, second.eventId);
      }
    });
    notice = "";
    for (PopulationEvent event : events) {
      if (event.runId != runId || event.eventId <= lastEventId) continue;
      if (event.step > snapshot.step) break;
      if (event.step < points.get(points.size() - 1).step
          || counts.get(event.species) + event.delta() < 0) {
        notice = "기록 순서 또는 개체 수 확인 필요";
        return;
      }
      counts.put(event.species, counts.get(event.species) + event.delta());
      lastEventId = event.eventId;
      recordedEvents.add(event);
      record(event.step);
    }
    if (!counts.equals(snapshot.populationCounts)) {
      notice = "현재 수량과 출생/사망 기록 불일치";
    }
  }

  void record(long step) {
    int last = points.size() - 1;
    PopulationPoint point = new PopulationPoint(step, counts);
    if (last >= 0 && points.get(last).step == step) {
      points.set(last, point);
    } else {
      points.add(point);
    }
  }
}
