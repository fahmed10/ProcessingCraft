import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;

Game _game = new Game();
long _lastTime = 0;
MxGame outer;
GL4 gl;
PGraphicsOpenGL pgl;

void setup() {
  size(800, 600, P3D);
  background(0);
  outer = this;
  Input.init(surface, width, height);
  gl = (GL4)((GLWindow)surface.getNative()).getGL();
  pgl = (PGraphicsOpenGL)g;
  _game.start();
  _lastTime = System.nanoTime();
  _game.update(0);
}

void draw() {
  double delta = (double)(System.nanoTime() - _lastTime) * 1e-9;
  _lastTime = System.nanoTime();
  Input.tick(width, height, mouseX, mouseY);
  _game.update((float)delta);
}

void keyPressed() {
  Input.keyPressed(key, keyCode);

  if (key == ESC) {
    key = 0;
  }
}

void keyReleased() {
  Input.keyReleased(key, keyCode);
}

void mousePressed() {
  Input.mousePressed(mouseButton);
}

void mouseReleased() {
  Input.mouseReleased(mouseButton);
}
