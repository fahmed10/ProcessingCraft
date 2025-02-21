import com.jogamp.newt.opengl.GLWindow;

static class Input {
  private static boolean[] keysDown = new boolean[Short.MAX_VALUE];
  private static boolean[] buttonsDown = new boolean[64];
  private static PVector mouseMovement = new PVector();
  private static GLWindow r;
  private static int n = 0;

  static boolean isKeyDown(int key) {
    return keysDown[key];
  }
  
  static boolean isKeyDown(char key) {
    return keysDown[Character.toLowerCase(key)];
  }
  
  static boolean isMouseButtonDown(int button) {
    return buttonsDown[button];
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
    
    if (r.hasFocus() && r.isVisible()) {
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
  
  private static void mousePressed(int mouseButton) {
    buttonsDown[mouseButton] = true;
  }
  
  private static void mouseReleased(int mouseButton) {
    buttonsDown[mouseButton] = false;
  }
}

static class Key {
  static int
  SHIFT = 16,
  CTRL = 17,
  LALT = 18,
  RALT = 19,
  ESC = 27,
  BACKSPACE = 8,
  INSERT = 26,
  DELETE = 147;
}

static class Mouse {
  static int
  LEFT = 37,
  RIGHT = 39,
  MIDDLE = 3;
}
