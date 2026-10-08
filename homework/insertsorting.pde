int[] arr = {5, 2, 4, 6, 1, 3};

int i = 1;
int j;
int key;

void setup() {
  size(700, 500);
  frameRate(2);
}

void draw() {
  background(255);

  // 배열을 막대그래프로 표시
  for (int k = 0; k < arr.length; k++) {
    fill(100, 150, 255);
    rect(50 + k * 100, 450 - arr[k] * 50,
         60, arr[k] * 50);

    fill(0);
    textSize(25);
    text(arr[k], 70 + k * 100, 480);
  }
  if (i < arr.length) {

    key = arr[i];
    j = i - 1;

    while (j >= 0 && arr[j] > key) {
      arr[j + 1] = arr[j];
      j--;
    }

    arr[j + 1] = key;

    i++;

  } else {
    // 정렬 완료
    noLoop();
  }
}
