int[] arr = {5, 2, 4, 6, 1, 3};

int[] stackL = new int[100];
int[] stackR = new int[100];

int top = -1;

int left;
int right;
int i;
int j;
int pivot;

boolean sorting = true;

void setup() {
  size(700, 500);
  frameRate(2);

  top++;
  stackL[top] = 0;
  stackR[top] = arr.length - 1;
}

void draw() {
  background(255);

  for (int k = 0; k < arr.length; k++) {
    if (sorting && k >= left && k <= right) {
      fill(255, 150, 100);
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
    quickStep();
  }
}

void quickStep() {
  if (top < 0) {
    sorting = false;
    return;
  }

  left = stackL[top];
  right = stackR[top];
  top--;

  if (left >= right) {
    return;
  }

  pivot = arr[right];

  i = left - 1;

  for (j = left; j < right; j++) {
    if (arr[j] <= pivot) {
      i++;

      int temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }

  int temp = arr[i + 1];
  arr[i + 1] = arr[right];
  arr[right] = temp;

  int p = i + 1;

  if (p - 1 > left) {
    top++;
    stackL[top] = left;
    stackR[top] = p - 1;
  }

  if (p + 1 < right) {
    top++;
    stackL[top] = p + 1;
    stackR[top] = right;
  }
}
