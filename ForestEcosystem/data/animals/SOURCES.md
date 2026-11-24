# 동물 표시 이미지

종 이름과 생태 규칙은 SharedTypes.pde의 기존 여섯 종을 유지한다. 이미지는 외형만 대체한다.
이번 단계는 방향별 정지 이미지 표시다. 애니메이션 재생은 아직 연결하지 않았다.
박쥐는 정면, 페럿은 측면과 좌우 반전을 사용한다. 노루와 고라니는 같은 사슴 원본을 크기와 색으로 구분한다.
삵은 갈색 고양이에 별도 줄무늬를 프로그램에서 합성한다. 이미지가 없으면 기존 도형으로 표시한다.

## 로컬 설치

각 팀원이 제작자 페이지에서 직접 다운로드한 뒤 아래 이름으로 이 폴더에 복사한다.
PNG와 JSON, 다운로드 원본 폴더는 Git에서 제외한다. 출처 안내와 코드는 공유한다.

| 파일 이름 | 다운로드 파일 안의 원본 | 화면에서 표시할 종 |
|---|---|---|
| hare.png | CraftPix PNG/With_Shadow/Hare/Hare_Idle_with_shadow.png | 멧토끼 |
| deer.png | CraftPix PNG/With_Shadow/Deer/Deer_Idle_with_shadow.png | 노루·고라니 |
| bat.png | Bat/Bat.png | 대륙밭쥐의 대체 이미지 |
| cat_brown.png | Cats Download/brown_0.png | 삵의 대체 이미지 |
| cat_tabby.png | Cats Download/Markings/Tabby Markings 000.png | 삵의 줄무늬 |
| ferret.png | Ferret Sprite Sheet.png | 담비의 대체 이미지 |

## 출처와 조건

- 토끼·사슴: [CraftPix Free Top-Down Hunt Animals](https://craftpix.net/freebies/free-top-down-hunt-animals-pixel-sprite-pack/) / [사용 조건](https://craftpix.net/file-licenses/). 무료 프로젝트 사용·수정 가능. 에셋 자체 재배포 제한.
- 박쥐: [Papoy Core — Free Bat](https://papoycore.itch.io/bat). 개인·상업 프로젝트 사용·수정 가능. 게임에 포함하는 경우 외 그래픽 자체 재배포 금지.
- 고양이: [Pop Shop Packs — Cats](https://pop-shop-packs.itch.io/cats-pixel-asset-pack). 프로젝트 사용·수정 가능. 에셋 형태 재배포 금지. 제작자 표시: Pop Shop Packs. 프로젝트에서는 갈색 원본에 줄무늬 색을 합성해 수정 사용한다.
- 페럿: [Elthen — Ferret](https://elthen.itch.io/2d-pixel-art-ferret-sprites) / [사용 조건](https://www.patreon.com/elthen/posts/licensing-27430241). 개인·상업 프로젝트 사용·수정 가능. 원본과 수정본 에셋 자체 재배포 금지.

이미지 표시와 크기·방향은 실행 확인 전이다. 사용자가 Processing에서 직접 확인한다.
