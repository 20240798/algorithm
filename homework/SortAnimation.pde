ArrayList<Frame> frames;
int[] base;
int[] data;
boolean[] fixed;

int algo = 0;
int N = 20;
int cur = 0;
int interval = 150;
int lastTick = 0;
boolean playing = true;
int compares, writes;

String[] names = {
  "Selection Sort", "Bubble Sort", "Insertion Sort",
  "Shell Sort", "Merge Sort", "Quick Sort"
};

class Frame {
  int[] arr;
  boolean[] done;
  int a, b;
  int lo, hi;
  int cmp, wr;
  String note;

  Frame(int a, int b, int lo, int hi, String note) {
    arr  = data.clone();
    done = fixed.clone();
    this.a = a;   this.b = b;
    this.lo = lo; this.hi = hi;
    this.note = note;
    cmp = compares;
    wr  = writes;
  }
}

void snap(int a, int b, int lo, int hi, String note) {
  frames.add(new Frame(a, b, lo, hi, note));
}

void setup() {
  size(960, 600);
  textFont(createFont("Arial Bold", 18, true));
  newData();
}

void newData() {
  base = new int[N];
  for (int i = 0; i < N; i++) base[i] = (int)random(5, 100);
  build();
}

void build() {
  data = base.clone();
  fixed = new boolean[N];
  frames = new ArrayList<Frame>();
  compares = writes = 0;
  cur = 0;

  snap(-1, -1, -1, -1, "start");
  switch (algo) {
    case 0: selectionSort(); break;
    case 1: bubbleSort();    break;
    case 2: insertionSort(); break;
    case 3: shellSort();     break;
    case 4: mergeSort(0, N-1); break;
    case 5: quickSort(0, N-1); break;
  }
  for (int i = 0; i < N; i++) fixed[i] = true;
  snap(-1, -1, -1, -1, "done!");
  println(names[algo] + " : " + frames.size() + " frames, "
          + compares + " compares, " + writes + " writes");
}

void draw() {
  background(28, 30, 38);

  if (playing) {
    int wait = (cur == frames.size()-1 || cur == 0) ? 1200 : interval;
    if (millis() - lastTick > wait) {
      cur = (cur < frames.size()-1) ? cur + 1 : 0;
      lastTick = millis();
    }
  }

  Frame f = frames.get(cur);
  drawBars(f);
  drawHud(f);
}

void drawBars(Frame f) {
  float margin = 40;
  float top = 90, bottom = height - 110;
  float w = (width - 2*margin) / N;
  float maxH = bottom - top;

  if (f.lo >= 0) {
    noStroke();
    fill(60, 70, 100, 120);
    rect(margin + f.lo*w, top - 10, (f.hi - f.lo + 1)*w, maxH + 20, 6);
  }

  textAlign(CENTER, BOTTOM);
  textSize(12);
  for (int i = 0; i < N; i++) {
    float h = map(f.arr[i], 0, 100, 0, maxH);
    float x = margin + i*w;

    if      (i == f.a)   fill(240, 85, 85);
    else if (i == f.b)   fill(250, 200, 70);
    else if (f.done[i])  fill(90, 200, 130);
    else if (f.lo >= 0 && i >= f.lo && i <= f.hi) fill(120, 160, 235);
    else                 fill(170, 175, 185);

    noStroke();
    rect(x + 2, bottom - h, w - 4, h, 3, 3, 0, 0);

    fill(230);
    if (w > 18) text(f.arr[i], x + w/2, bottom - h - 3);
  }
}

void drawHud(Frame f) {
  textAlign(LEFT, TOP);
  textSize(26);
  fill(255);
  text(names[algo], 40, 25);
  float tw = textWidth(names[algo]);
  textSize(14);
  fill(160);
  text("(" + (algo+1) + "/" + names.length + ")", 40 + tw + 10, 35);

  textAlign(RIGHT, TOP);
  textSize(15);
  fill(220);
  text("compares: " + f.cmp + "   writes: " + f.wr, width - 40, 25);
  fill(playing ? color(120, 220, 140) : color(240, 120, 120));
  text((playing ? "PLAY" : "PAUSE") + "  " + interval + "ms", width - 40, 48);

  float py = height - 85;
  noStroke();
  fill(60);
  rect(40, py, width - 80, 6, 3);
  fill(120, 160, 235);
  rect(40, py, (width - 80) * cur / (float)(frames.size()-1), 6, 3);

  textAlign(LEFT, TOP);
  textSize(15);
  fill(230);
  String idx = "";
  if (f.a >= 0) idx += "[" + nf(f.a, 2);
  if (f.b >= 0) idx += ", " + nf(f.b, 2);
  if (f.a >= 0) idx += "]  ";
  text("step " + cur + "/" + (frames.size()-1) + "   " + idx + f.note, 40, py + 14);

  fill(130);
  textSize(13);
  text("SPACE play/pause   a/s speed   z/x algorithm   ←/→ step   ↑/↓ size(" + N + ")   r shuffle",
       40, height - 30);
}

void keyPressed() {
  if (key == ' ') playing = !playing;
  else if (key == 'a') interval = max(10, interval - (interval > 100 ? 50 : 10));
  else if (key == 's') interval = min(2000, interval + (interval >= 100 ? 50 : 10));
  else if (key == 'z') { algo = (algo + names.length - 1) % names.length; build(); }
  else if (key == 'x') { algo = (algo + 1) % names.length; build(); }
  else if (key == 'r') newData();
  else if (key == CODED) {
    if (keyCode == LEFT)  { playing = false; cur = max(0, cur - 1); }
    if (keyCode == RIGHT) { playing = false; cur = min(frames.size()-1, cur + 1); }
    if (keyCode == UP   && N < 60) { N += 4; newData(); }
    if (keyCode == DOWN && N > 8)  { N -= 4; newData(); }
  }
}

void mousePressed() {
  playing = false;
  if (mouseButton == LEFT)  cur = max(0, cur - 1);
  if (mouseButton == RIGHT) cur = min(frames.size()-1, cur + 1);
}

void swap(int i, int j) {
  int t = data[i]; data[i] = data[j]; data[j] = t;
  writes++;
}

void selectionSort() {
  for (int i = 0; i < N - 1; i++) {
    int m = i;
    for (int j = i + 1; j < N; j++) {
      compares++;
      snap(m, j, i, N-1, "min = " + data[m]);
      if (data[j] < data[m]) m = j;
    }
    swap(i, m);
    fixed[i] = true;
    snap(i, m, -1, -1, "swap " + i + " <-> " + m);
  }
}

void bubbleSort() {
  for (int i = 0; i < N - 1; i++) {
    boolean swapped = false;
    for (int j = 0; j < N - 1 - i; j++) {
      compares++;
      snap(j, j+1, 0, N-1-i, "compare");
      if (data[j] > data[j+1]) {
        swap(j, j+1);
        swapped = true;
        snap(j+1, j, 0, N-1-i, "swap");
      }
    }
    fixed[N-1-i] = true;
    if (!swapped) {
      snap(-1, -1, -1, -1, "no swap -> early exit");
      break;
    }
  }
}

void insertionSort() {
  fixed[0] = true;
  for (int i = 1; i < N; i++) {
    int key = data[i];
    int j = i - 1;
    snap(i, -1, 0, i, "key = " + key);
    while (j >= 0) {
      compares++;
      snap(j, j+1, 0, i, "key = " + key);
      if (data[j] > key) {
        data[j+1] = data[j];
        writes++;
        j--;
      } else break;
    }
    data[j+1] = key;
    writes++;
    snap(j+1, -1, 0, i, "insert " + key);
  }
}

void shellSort() {
  for (int gap = N/2; gap > 0; gap /= 2) {
    for (int i = gap; i < N; i++) {
      int tmp = data[i];
      int j = i;
      while (j >= gap) {
        compares++;
        snap(j-gap, j, -1, -1, "gap = " + gap);
        if (data[j-gap] > tmp) {
          data[j] = data[j-gap];
          writes++;
          j -= gap;
        } else break;
      }
      data[j] = tmp;
      writes++;
      snap(j, -1, -1, -1, "gap = " + gap);
    }
  }
}

void mergeSort(int lo, int hi) {
  if (lo >= hi) return;
  int mid = (lo + hi) / 2;
  snap(-1, -1, lo, hi, "split " + lo + "~" + hi);
  mergeSort(lo, mid);
  mergeSort(mid + 1, hi);
  merge(lo, mid, hi);
}

void merge(int lo, int mid, int hi) {
  int[] tmp = new int[hi - lo + 1];
  int i = lo, j = mid + 1, k = 0;
  while (i <= mid && j <= hi) {
    compares++;
    snap(i, j, lo, hi, "merge " + lo + "~" + hi);
    tmp[k++] = (data[i] <= data[j]) ? data[i++] : data[j++];
  }
  while (i <= mid) tmp[k++] = data[i++];
  while (j <= hi)  tmp[k++] = data[j++];

  for (k = 0; k < tmp.length; k++) {
    data[lo + k] = tmp[k];
    writes++;
    snap(lo + k, -1, lo, hi, "write back");
  }
}

void quickSort(int lo, int hi) {
  if (lo > hi) return;
  if (lo == hi) { fixed[lo] = true; return; }
  int p = partition(lo, hi);
  fixed[p] = true;
  snap(p, -1, lo, hi, "pivot fixed at " + p);
  quickSort(lo, p - 1);
  quickSort(p + 1, hi);
}

int partition(int lo, int hi) {
  int pivot = data[hi];
  int i = lo;
  for (int j = lo; j < hi; j++) {
    compares++;
    snap(j, hi, lo, hi, "pivot = " + pivot);
    if (data[j] < pivot) {
      swap(i, j);
      snap(i, j, lo, hi, "swap");
      i++;
    }
  }
  swap(i, hi);
  return i;
}
