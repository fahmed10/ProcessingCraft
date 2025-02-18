import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;

Game _game = new Game();
GL4 gl;

void setup() {
  size(800, 600, P3D);
  background(255);
  Input.init(surface, width, height);
  gl = (GL4)((GLWindow)surface.getNative()).getGL();
  _game.start();
  _game.update(0);
}

void draw() {
  float deltaTime = 1 / frameRate;
  background(255);
  Input.tick(width, height, mouseX, mouseY);
  _game.update(deltaTime);
}

void keyPressed() {
  Input.keyPressed(key, keyCode);
}

void keyReleased() {
  Input.keyReleased(key, keyCode);
}
