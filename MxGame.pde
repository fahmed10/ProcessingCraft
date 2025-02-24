import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;

Game _game = new Game();
long _lastTime = 0;
MxGame outer;
GL4 gl;
PGraphicsOpenGL pgl;
DebugDrawer Debug = new DebugDrawer();

void setup() {
  size(800, 600, P3D);
  hint(ENABLE_STROKE_PERSPECTIVE);
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
  Input.clearState();
}

void keyPressed(KeyEvent e) {
  Input.keyPressed(key, keyCode);
  if (key == CONTROL) postProcessKeyEvent(e);
  key = 0;
  keyCode = 0;
}

void keyReleased(KeyEvent e) {
  Input.keyReleased(key, keyCode);

  if (key == CONTROL) postProcessKeyEvent(e);
  key = 0;
  keyCode = 0;
}

void postProcessKeyEvent(KeyEvent e) {
  var field = getField(e.getClass(), "modifiers");
  field.setAccessible(true);
  try {
    field.set(e, 0);
  }
  catch (Exception ex) {
  }
}

java.lang.reflect.Field getField(Class klass, String fieldName) {
  try {
    return klass.getDeclaredField(fieldName);
  }
  catch (NoSuchFieldException e) {
    Class superClass = klass.getSuperclass();
    if (superClass == null) return null;
    else return getField(superClass, fieldName);
  }
}

void mousePressed() {
  Input.mousePressed(mouseButton);
}

void mouseReleased() {
  Input.mouseReleased(mouseButton);
}
