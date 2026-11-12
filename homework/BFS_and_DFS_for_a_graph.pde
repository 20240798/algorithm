// =====================================================
// Homework 6 - BFS and DFS for a Graph (Processing)
// -----------------------------------------------------
// 조작법
//   마우스 클릭 : 시작 노드 선택
//   B          : BFS 시작
//   D          : DFS 시작
//   SPACE      : 한 단계 진행
//   A          : 자동 재생 ON/OFF
//   R          : 리셋
// =====================================================
import java.util.*;

int N = 8;
PVector[] pos = new PVector[N];
int[][] edges = {
  {0, 1}, {0, 2}, {0, 6}, {1, 3}, {1, 4},
  {2, 4}, {2, 5}, {5, 7}, {6, 7}
};
ArrayList<ArrayList<Integer>> adj = new ArrayList<ArrayList<Integer>>();

int mode = 0;            // 0: 없음, 1: BFS, 2: DFS
int startNode = 0;
boolean[] visited;
int[] parent;
int current = -1;
ArrayList<Integer> visitOrder = new ArrayList<Integer>();
ArrayDeque<Integer> queue = new ArrayDeque<Integer>();   // BFS용 큐
ArrayDeque<int[]> stack = new ArrayDeque<int[]>();       // DFS용 스택 {노드, 부모}

boolean autoPlay = false;
int lastStep = 0;
int R = 24;

void setup() {
  size(700, 620);
  textAlign(CENTER, CENTER);

  pos[0] = new PVector(250, 60);
  pos[1] = new PVector(130, 180);
  pos[2] = new PVector(330, 190);
  pos[3] = new PVector(60, 330);
  pos[4] = new PVector(220, 330);
  pos[5] = new PVector(400, 340);
  pos[6] = new PVector(560, 110);
  pos[7] = new PVector(590, 330);

  // 인접 리스트 생성 (무방향 그래프)
  for (int i = 0; i < N; i++) adj.add(new ArrayList<Integer>());
  for (int[] e : edges) {
    adj.get(e[0]).add(e[1]);
    adj.get(e[1]).add(e[0]);
  }
  for (ArrayList<Integer> list : adj) Collections.sort(list);

  // 콘솔에 정답 순서 출력 (확인용)
  println("BFS order from 0: " + bfsOrder(0));
  println("DFS order from 0: " + dfsOrder(0));

  resetSearch();
}

void draw() {
  background(245);

  // 자동 재생
  if (autoPlay && millis() - lastStep > 700) {
    if (!step()) autoPlay = false;
    lastStep = millis();
  }

  // ---- 간선 ----
  for (int[] e : edges) {
    int a = e[0], b = e[1];
    boolean treeEdge = (parent[b] == a) || (parent[a] == b);
    if (treeEdge) {
      stroke(mode == 1 ? color(40, 110, 220) : color(220, 120, 30));
      strokeWeight(5);
    } else {
      stroke(180);
      strokeWeight(2);
    }
    line(pos[a].x, pos[a].y, pos[b].x, pos[b].y);
  }

  // ---- 노드 ----
  strokeWeight(2);
  for (int i = 0; i < N; i++) {
    if (i == current)          fill(230, 70, 70);    // 현재 방문 노드: 빨강
    else if (visited[i] && !inFrontier(i)) fill(110, 200, 120); // 방문 완료: 초록
    else if (inFrontier(i))    fill(250, 210, 80);   // 큐/스택 대기: 노랑
    else                       fill(255);            // 미방문: 흰색

    stroke(i == startNode ? color(0) : color(90));
    strokeWeight(i == startNode ? 4 : 2);
    ellipse(pos[i].x, pos[i].y, R * 2, R * 2);

    fill(0);
    textSize(16);
    text(i, pos[i].x, pos[i].y);

    // 방문 순서 번호
    int idx = visitOrder.indexOf(i);
    if (idx >= 0) {
      fill(80);
      textSize(12);
      text("#" + (idx + 1), pos[i].x + R + 8, pos[i].y - R);
    }
  }

  drawInfoPanel();
}

void drawInfoPanel() {
  fill(255);
  stroke(200);
  strokeWeight(1);
  rect(10, 420, width - 20, 190, 8);

  textAlign(LEFT, TOP);
  fill(0);
  textSize(16);
  String m = (mode == 1) ? "BFS (Queue)" : (mode == 2) ? "DFS (Stack)" : "None";
  text("Mode: " + m + "     Start: " + startNode + "     Auto: " + (autoPlay ? "ON" : "OFF"), 25, 432);

  textSize(14);
  text("Visit order: " + visitOrder, 25, 465);

  if (mode == 1) {
    text("Queue (front -> back): " + queue, 25, 495);
  } else if (mode == 2) {
    ArrayList<Integer> s = new ArrayList<Integer>();
    for (int[] item : stack) s.add(item[0]);   // 앞쪽이 top
    text("Stack (top -> bottom): " + s, 25, 495);
  }

  if (mode != 0 && isFinished()) {
    fill(30, 140, 50);
    text("Search finished!", 25, 525);
  }

  fill(110);
  textSize(12);
  text("Click: start node | B: BFS | D: DFS | SPACE: step | A: auto | R: reset", 25, 560);
  text("Red = current, Yellow = waiting in queue/stack, Green = visited", 25, 580);
  textAlign(CENTER, CENTER);
}

// =====================================================
// 탐색 제어
// =====================================================
void resetSearch() {
  mode = 0;
  visited = new boolean[N];
  parent = new int[N];
  Arrays.fill(parent, -1);
  current = -1;
  visitOrder.clear();
  queue.clear();
  stack.clear();
  autoPlay = false;
}

void startBFS() {
  resetSearch();
  mode = 1;
  visited[startNode] = true;     // BFS는 큐에 넣을 때 방문 표시
  queue.add(startNode);
}

void startDFS() {
  resetSearch();
  mode = 2;
  stack.push(new int[]{startNode, -1});
}

boolean step() {
  if (mode == 1) return stepBFS();
  if (mode == 2) return stepDFS();
  return false;
}

// BFS 한 단계: 큐에서 꺼내고, 방문 안 한 이웃을 큐에 추가
boolean stepBFS() {
  if (queue.isEmpty()) { current = -1; return false; }
  int u = queue.poll();
  current = u;
  visitOrder.add(u);
  for (int v : adj.get(u)) {
    if (!visited[v]) {
      visited[v] = true;
      parent[v] = u;
      queue.add(v);
    }
  }
  return true;
}

// DFS 한 단계: 스택에서 꺼내고, 방문 안 한 이웃을 스택에 추가
boolean stepDFS() {
  while (!stack.isEmpty()) {
    int[] top = stack.pop();
    int u = top[0];
    if (visited[u]) continue;     // 이미 방문했으면 건너뜀
    visited[u] = true;
    parent[u] = top[1];
    current = u;
    visitOrder.add(u);
    // 작은 번호부터 방문하도록 역순으로 push
    ArrayList<Integer> nb = adj.get(u);
    for (int k = nb.size() - 1; k >= 0; k--) {
      int v = nb.get(k);
      if (!visited[v]) stack.push(new int[]{v, u});
    }
    return true;
  }
  current = -1;
  return false;
}

boolean inFrontier(int i) {
  if (mode == 1) return queue.contains(i);
  if (mode == 2) {
    if (visited[i]) return false;
    for (int[] item : stack) if (item[0] == i) return true;
  }
  return false;
}

boolean isFinished() {
  if (mode == 1) return queue.isEmpty();
  if (mode == 2) {
    for (int[] item : stack) if (!visited[item[0]]) return false;
    return true;
  }
  return false;
}

// =====================================================
// 콘솔용 기본 BFS / DFS (재귀) - 과제 제출용 핵심 알고리즘
// =====================================================
ArrayList<Integer> bfsOrder(int s) {
  ArrayList<Integer> order = new ArrayList<Integer>();
  boolean[] vis = new boolean[N];
  ArrayDeque<Integer> q = new ArrayDeque<Integer>();
  vis[s] = true;
  q.add(s);
  while (!q.isEmpty()) {
    int u = q.poll();
    order.add(u);
    for (int v : adj.get(u)) {
      if (!vis[v]) {
        vis[v] = true;
        q.add(v);
      }
    }
  }
  return order;
}

ArrayList<Integer> dfsOrder(int s) {
  ArrayList<Integer> order = new ArrayList<Integer>();
  dfsRec(s, new boolean[N], order);
  return order;
}

void dfsRec(int u, boolean[] vis, ArrayList<Integer> order) {
  vis[u] = true;
  order.add(u);
  for (int v : adj.get(u)) {
    if (!vis[v]) dfsRec(v, vis, order);
  }
}

// =====================================================
// 입력
// =====================================================
void mousePressed() {
  for (int i = 0; i < N; i++) {
    if (dist(mouseX, mouseY, pos[i].x, pos[i].y) < R) {
      startNode = i;
      resetSearch();
      return;
    }
  }
}

void keyPressed() {
  if (key == 'b' || key == 'B') startBFS();
  else if (key == 'd' || key == 'D') startDFS();
  else if (key == ' ') step();
  else if (key == 'a' || key == 'A') { if (mode != 0) autoPlay = !autoPlay; }
  else if (key == 'r' || key == 'R') resetSearch();
}
