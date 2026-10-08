int[] arr = {5, 2, 4, 6, 1, 3};

int size = 1;
int left = 0;
int mid;
int right;

boolean sorting = true;

void setup() {
  size(700, 500);
  frameRate(2);
}

void draw() {
  background(255);

  for (int i = 0; i < arr.length; i++) {
    if (i >= left && i <= right) {
      fill(255, 150, 100);
    } else {
      fill(100, 150, 255);
    }

    rect(50 + i * 100,
         450 - arr[i] * 50,
         60,
         arr[i] * 50);

    fill(0);
    textSize(25);
    text(arr[i], 70 + i * 100, 480);
  }

  if (sorting) {
    mergeStep();
  }
}

void mergeStep() {
  if (size >= arr.length) {
    sorting = false;
    return;
  }

  if (left < arr.length) {
    mid = min(left + size - 1, arr.length - 1);
    right = min(left + size * 2 - 1, arr.length - 1);

    merge(arr, left, mid, right);

    left += size * 2;
  } else {
    size *= 2;
    left = 0;
  }
}

void merge(int[] arr, int left, int mid, int right) {
  int[] temp = new int[right - left + 1];

  int i = left;
  int j = mid + 1;
  int k = 0;

  while (i <= mid && j <= right) {
    if (arr[i] <= arr[j]) {
      temp[k] = arr[i];
      i++;
    } else {
      temp[k] = arr[j];
      j++;
    }
    k++;
  }

  while (i <= mid) {
    temp[k] = arr[i];
    i++;
    k++;
  }

  while (j <= right) {
    temp[k] = arr[j];
    j++;
    k++;
  }

  for (i = 0; i < temp.length; i++) {
    arr[left + i] = temp[i];
  }
}
