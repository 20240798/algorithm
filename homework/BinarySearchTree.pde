class Node { //<>//
  int key;
  Node left, right;
  float x, y;
  Node(int k) { key = k; }
}

Node root;
String input = "";
String msg = "";
ArrayList<Node> order = new ArrayList<Node>();
ArrayList<Node> path = new ArrayList<Node>();
Node found = null;
String orderName = "";
int step = 0;
int lastTick = 0;
int speed = 500;
int counter, total;

void setup() {
  size(1000, 650);
  textFont(createFont("Arial Bold", 16, true));
  int[] init = {50, 30, 70, 20, 40, 60, 80, 35, 65};
  for (int v : init) root = insert(root, v);
  msg = "type a number, then press i(insert) / d(delete) / s(search)";
}

void draw() {
  background(250, 248, 240);
  if (step < order.size() && millis() - lastTick > speed) {
    step++;
    lastTick = millis();
  }
  layout();
  drawEdges(root);
  drawNodes(root);
  drawHud();
}

void layout() {
  total = countNodes(root);
  counter = 0;
  place(root, 0);
}

int countNodes(Node n) {
  if (n == null) return 0;
  return 1 + countNodes(n.left) + countNodes(n.right);
}

void place(Node n, int depth) {
  if (n == null) return;
  place(n.left, depth + 1);
  n.x = (total == 1) ? width/2 : map(counter, 0, total - 1, 50, width - 50);
  n.y = 120 + depth * 75;
  counter++;
  place(n.right, depth + 1);
}

void drawEdges(Node n) {
  if (n == null) return;
  stroke(120);
  strokeWeight(2);
  if (n.left != null)  line(n.x, n.y, n.left.x, n.left.y);
  if (n.right != null) line(n.x, n.y, n.right.x, n.right.y);
  drawEdges(n.left);
  drawEdges(n.right);
}

void drawNodes(Node n) {
  if (n == null) return;
  int idx = order.indexOf(n);

  if (n == found)                     fill(90, 200, 120);
  else if (idx >= 0 && idx == step-1) fill(240, 80, 80);
  else if (idx >= 0 && idx < step)    fill(250, 180, 90);
  else if (path.contains(n))          fill(140, 190, 250);
  else                                fill(255);

  stroke(60);
  strokeWeight(2);
  ellipse(n.x, n.y, 42, 42);

  fill(20);
  textAlign(CENTER, CENTER);
  textSize(15);
  text(n.key, n.x, n.y);

  if (idx >= 0 && idx < step) {
    fill(200, 60, 60);
    textSize(12);
    text(idx + 1, n.x + 22, n.y - 22);
  }

  drawNodes(n.left);
  drawNodes(n.right);
}

void drawHud() {
  textAlign(LEFT, TOP);
  fill(30);
  textSize(24);
  text("Binary Search Tree", 30, 20);

  textSize(16);
  fill(255);
  stroke(100);
  rect(30, 58, 140, 30, 5);
  fill(30);
  text("input: " + input + (frameCount / 30 % 2 == 0 ? "_" : ""), 40, 64);

  fill(80, 80, 160);
  text(msg, 190, 64);

  textAlign(RIGHT, TOP);
  fill(100);
  text("nodes: " + total + "   height: " + height(root) + "   speed: " + speed + "ms", width - 30, 25);

  if (order.size() > 0) {
    String s = orderName + " : ";
    for (int i = 0; i < step; i++) s += order.get(i).key + (i < order.size()-1 ? " -> " : "");
    textAlign(LEFT, TOP);
    fill(200, 80, 40);
    text(s, 30, height - 75);
  }

  textAlign(LEFT, TOP);
  fill(130);
  textSize(13);
  text("0-9 input   i insert   d delete   s search   n inorder   p preorder   o postorder   r random   c clear   +/- speed",
       30, height - 35);
}

int height(Node n) {
  if (n == null) return 0;
  return 1 + max(height(n.left), height(n.right));
}

boolean contains(Node n, int key) {
  while (n != null) {
    if (key == n.key) return true;
    n = (key < n.key) ? n.left : n.right;
  }
  return false;
}

Node insert(Node n, int key) {
  if (n == null) return new Node(key);
  if (key < n.key) n.left = insert(n.left, key);
  else if (key > n.key) n.right = insert(n.right, key);
  return n;
}

Node delete(Node n, int key) {
  if (n == null) return null;
  if (key < n.key) n.left = delete(n.left, key);
  else if (key > n.key) n.right = delete(n.right, key);
  else {
    if (n.left == null) return n.right;
    if (n.right == null) return n.left;
    Node s = n.right;
    while (s.left != null) s = s.left;
    n.key = s.key;
    n.right = delete(n.right, s.key);
  }
  return n;
}

void search(int key) {
  path.clear();
  found = null;
  Node n = root;
  while (n != null) {
    path.add(n);
    if (key == n.key) { found = n; break; }
    n = (key < n.key) ? n.left : n.right;
  }
  if (found != null) msg = key + " found (" + path.size() + " compares)";
  else msg = key + " not found (" + path.size() + " compares)";
}

void inorder(Node n) {
  if (n == null) return;
  inorder(n.left);
  order.add(n);
  inorder(n.right);
}

void preorder(Node n) {
  if (n == null) return;
  order.add(n);
  preorder(n.left);
  preorder(n.right);
}

void postorder(Node n) {
  if (n == null) return;
  postorder(n.left);
  postorder(n.right);
  order.add(n);
}

void startTraversal(int type) {
  clearMarks();
  if (type == 0) { orderName = "Inorder";   inorder(root); }
  if (type == 1) { orderName = "Preorder";  preorder(root); }
  if (type == 2) { orderName = "Postorder"; postorder(root); }
  step = 0;
  lastTick = millis();
  msg = orderName + " traversal";
}

void clearMarks() {
  order.clear();
  path.clear();
  found = null;
  step = 0;
}

void keyPressed() {
  if (key >= '0' && key <= '9') {
    if (input.length() < 3) input += key;
    return;
  }
  if (key == BACKSPACE) {
    if (input.length() > 0) input = input.substring(0, input.length() - 1);
    return;
  }

  if (key == 'i' || key == 'd' || key == 's') {
    if (input.length() == 0) { msg = "enter a number first"; return; }
    int v = Integer.parseInt(input);
    input = "";
    clearMarks();
    if (key == 'i') {
      if (contains(root, v)) msg = v + " already exists";
      else { root = insert(root, v); msg = v + " inserted"; search(v); msg = v + " inserted"; }
    } else if (key == 'd') {
      if (!contains(root, v)) msg = v + " not in tree";
      else { root = delete(root, v); msg = v + " deleted"; }
    } else {
      search(v);
    }
  }
  else if (key == 'n') startTraversal(0);
  else if (key == 'p') startTraversal(1);
  else if (key == 'o') startTraversal(2);
  else if (key == 'r') {
    root = null;
    clearMarks();
    for (int i = 0; i < 12; i++) root = insert(root, (int)random(1, 100));
    msg = "random tree";
  }
  else if (key == 'c') { root = null; clearMarks(); msg = "cleared"; }
  else if (key == '+' || key == '=') speed = max(100, speed - 100);
  else if (key == '-') speed = min(2000, speed + 100);
}
