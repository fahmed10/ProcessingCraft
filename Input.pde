import com.jogamp.newt.opengl.GLWindow;

static class Input {
  private static boolean[] keysDown = new boolean[Short.MAX_VALUE];
  private static PVector mouseMovement = new PVector();
  private static GLWindow r;
  private static int n = 0;

  static boolean isKeyDown(int key) {
    return keysDown[Character.toLowerCase(key)];
  }

  static PVector getMouseMovement() {
    return mouseMovement;
  }

  static void setPointerLocked(boolean locked) {
    r.confinePointer(locked);
    r.setPointerVisible(!locked);
  }

  static void init(PSurface surface, int width, int height) {
    r = (GLWindow)surface.getNative();
    setPointerLocked(true);
    r.warpPointer(width/2, height/2);
  }

  static void tick(int width, int height, int mouseX, int mouseY) {
    if (n < 2) {
      n++;
      return;
    }
    
    if (r.hasFocus()) {
      mouseMovement.set(mouseX - (width / 2), mouseY - (height / 2));
      r.warpPointer(width / 2, height / 2);
    }
  }

  private static void keyPressed(int key, int keyCode) {
    keysDown[key == CODED ? keyCode : Character.toLowerCase(key)] = true;
  }

  private static void keyReleased(int key, int keyCode) {
    keysDown[key == CODED ? keyCode : Character.toLowerCase(key)] = false;
  }
}
