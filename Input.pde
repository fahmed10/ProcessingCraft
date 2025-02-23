import com.jogamp.newt.opengl.GLWindow;

static class Input {
  private static boolean[] keysDown = new boolean[512];
  private static boolean[] buttonsDown = new boolean[40];
  private static byte[] keyState = new byte[512];
  private static byte[] buttonState = new byte[40];
  private static PVector mouseMovement = new PVector();
  private static GLWindow window;
  private static int n = 0;

  static boolean isKeyDown(int key) {
    return keysDown[key];
  }

  static boolean isKeyDown(char key) {
    return keysDown[Character.toLowerCase(key)];
  }

  static boolean isKeyPressed(int key) {
    return keyState[key] == 1;
  }

  static boolean isKeyPressed(char key) {
    return keyState[Character.toLowerCase(key)] == 1;
  }

  static boolean isKeyReleased(int key) {
    return keyState[key] == 2;
  }

  static boolean isKeyReleased(char key) {
    return keyState[Character.toLowerCase(key)] == 2;
  }

  static boolean isMouseButtonDown(int button) {
    return buttonsDown[button];
  }

  static boolean isMouseButtonPressed(int button) {
    return buttonState[button] == 1;
  }

  static boolean isMouseButtonReleased(int button) {
    return buttonState[button] == 2;
  }

  static PVector getMouseMovement() {
    return mouseMovement;
  }

  static void setPointerLocked(boolean locked) {
    window.confinePointer(locked);
    window.setPointerVisible(!locked);
  }

  static void init(PSurface surface, int width, int height) {
    window = (GLWindow)surface.getNative();
    setPointerLocked(true);
    window.warpPointer(width/2, height/2);
  }

  static void tick(int width, int height, int mouseX, int mouseY) {
    if (n < 2) {
      n++;
      return;
    }

    if (window.hasFocus() && window.isVisible() && !window.isPointerVisible()) {
      mouseMovement.set(mouseX - (width / 2), mouseY - (height / 2));
      window.warpPointer(width / 2, height / 2);
    }

    if (window.isPointerVisible() && !window.isPointerConfined()) {
      mouseMovement.set(0, 0);
    }
  }

  static void clearState() {
    Arrays.fill(keyState, (byte)0);
    Arrays.fill(buttonState, (byte)0);
  }

  private static void keyPressed(int key, int keyCode) {
    int id = key == CODED ? keyCode : Character.toLowerCase(key);
    keysDown[id] = true;
    keyState[id] = 1;
  }

  private static void keyReleased(int key, int keyCode) {
    int id = key == CODED ? keyCode : Character.toLowerCase(key);
    keysDown[id] = false;
    keyState[id] = 2;
  }

  private static void mousePressed(int mouseButton) {
    buttonsDown[mouseButton] = true;
    buttonState[mouseButton] = 1;
  }

  private static void mouseReleased(int mouseButton) {
    buttonsDown[mouseButton] = false;
    buttonState[mouseButton] = 2;
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
