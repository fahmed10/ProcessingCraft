import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;

Game _game = new Game();
GL4 gl;
PGraphicsOpenGL pgl;

void setup() {
  size(800, 600, P3D);
  background(255);
  Input.init(surface, width, height);
  gl = (GL4)((GLWindow)surface.getNative()).getGL();
  pgl = (PGraphicsOpenGL)g;
  _game.start();
  _game.update(0);
}

void draw() {
  background(255);
  Input.tick(width, height, mouseX, mouseY);
  _game.update(1 / frameRate);
}

void keyPressed() {
  Input.keyPressed(key, keyCode);
}

void keyReleased() {
  Input.keyReleased(key, keyCode);
}
