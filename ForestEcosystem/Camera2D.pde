// 담당 B. 생태 계산의 지도 좌표와 화면 좌표 사이의 변환을 담당한다.
class Camera2D {
  final float viewportX;
  final float viewportY;
  final float viewportWidth;
  final float viewportHeight;
  float mapWidth;
  float mapHeight;
  float centerX;
  float centerY;
  float zoom = 1.0f;
  float baseScale;

  Camera2D(float x, float y, float viewWidth, float viewHeight,
           float worldWidth, float worldHeight) {
    viewportX = x;
    viewportY = y;
    viewportWidth = viewWidth;
    viewportHeight = viewHeight;
    setMapSize(worldWidth, worldHeight);
  }

  void setMapSize(float worldWidth, float worldHeight) {
    if (worldWidth <= 0 || worldHeight <= 0) {
      throw new IllegalArgumentException("Map dimensions must be positive.");
    }
    mapWidth = worldWidth;
    mapHeight = worldHeight;
    baseScale = min(viewportWidth / mapWidth, viewportHeight / mapHeight) * 2;
    reset();
  }

  void reset() {
    zoom = 1.0f;
    centerX = mapWidth / 2;
    centerY = mapHeight / 2;
    clampCenter();
  }

  float pixelsPerUnit() {
    return baseScale * zoom;
  }

  boolean contains(float x, float y) {
    return x >= viewportX && x < viewportX + viewportWidth
        && y >= viewportY && y < viewportY + viewportHeight;
  }

  PVector screenToWorld(float x, float y) {
    return new PVector(
      centerX + (x - viewportX - viewportWidth / 2) / pixelsPerUnit(),
      centerY + (y - viewportY - viewportHeight / 2) / pixelsPerUnit()
    );
  }

  PVector worldToScreen(float x, float y) {
    return new PVector(
      viewportX + viewportWidth / 2 + (x - centerX) * pixelsPerUnit(),
      viewportY + viewportHeight / 2 + (y - centerY) * pixelsPerUnit()
    );
  }

  void pan(float screenDX, float screenDY) {
    centerX -= screenDX / pixelsPerUnit();
    centerY -= screenDY / pixelsPerUnit();
    clampCenter();
  }

  void zoomAt(float screenX, float screenY, float wheelCount) {
    PVector before = screenToWorld(screenX, screenY);
    zoom = constrain(zoom * pow(1.12f, -wheelCount), 0.5f, 3.0f);
    PVector after = screenToWorld(screenX, screenY);
    centerX += before.x - after.x;
    centerY += before.y - after.y;
    clampCenter();
  }

  void clampCenter() {
    float halfWidth = viewportWidth / pixelsPerUnit() / 2;
    float halfHeight = viewportHeight / pixelsPerUnit() / 2;
    if (halfWidth * 2 >= mapWidth) {
      centerX = mapWidth / 2;
    } else {
      centerX = constrain(centerX, halfWidth, mapWidth - halfWidth);
    }
    if (halfHeight * 2 >= mapHeight) {
      centerY = mapHeight / 2;
    } else {
      centerY = constrain(centerY, halfHeight, mapHeight - halfHeight);
    }
  }
}
