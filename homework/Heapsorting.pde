int[] arr = {5, 2, 4, 6, 1, 3};

int heapSize;
int i;
int step = 0;

boolean sorting = true;

void setup() {
  size(700, 500);
  frameRate(2);

  heapSize = arr.length;
  i = heapSize / 2 - 1;
}

void draw() {
  background(255);

  for (int k = 0; k < arr.length; k++) {
    if (k >= heapSize) {
      fill(150, 220, 150);
    } else {
      fill(100, 150, 255);
    }

    rect(50 + k * 100,
         450 - arr[k] * 50,
         60,
         arr[k] * 50);

    fill(0);
    textSize(25);
    text(arr[k], 70 + k * 100, 480);
  }

  if (sorting) {
    heapStep();
  }
}

void heapStep() {
  if (step == 0) {
    if (i >= 0) {
      heapify(arr, heapSize, i);
      i--;
    } else {
      step = 1;
      heapSize = arr.length;
    }
  } else {
    if (heapSize > 1) {
      int temp = arr[0];
      arr[0] = arr[heapSize - 1];
      arr[heapSize - 1] = temp;

      heapSize--;

      heapify(arr, heapSize, 0);
    } else {
      sorting = false;
    }
  }
}

void heapify(int[] arr, int n, int i) {
  int largest = i;
  int left = 2 * i + 1;
  int right = 2 * i + 2;

  if (left < n && arr[left] > arr[largest]) {
    largest = left;
  }

  if (right < n && arr[right] > arr[largest]) {
    largest = right;
  }

  if (largest != i) {
    int temp = arr[i];
    arr[i] = arr[largest];
    arr[largest] = temp;
  }
}
