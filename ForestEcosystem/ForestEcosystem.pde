// 담당 B. A와 함께 프로그램 진입점의 연결을 관리한다.
// 구현 기준은 ../문서/개발가이드.md를 따른다.

void settings() {
  size(1200, 740);
}

void setup() {
  surface.setTitle("Forest Ecosystem");
  textFont(createFont("Malgun Gothic", 18));
  noLoop();
}

void draw() {
  background(235, 241, 233);
  fill(35, 58, 42);
  textAlign(CENTER, CENTER);
  text("한국 숲 생태계 시뮬레이션", width / 2, height / 2 - 20);
  text("프로젝트 기본 파일 준비 완료", width / 2, height / 2 + 20);
}
