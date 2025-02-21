class Player extends Object3D {
  float walkSpeed = 200;
  float sprintSpeed = 400;
  float mouseSensitivity = 1.5;
  float minPitch = -80, maxPitch = 80;
  private Camera3D camera = new Camera3D();

  void start() {
    position.set(0, Block.BLOCK_SIZE * 6, 0);
  }

  void update(float delta) {
    float speed = 200 * delta;

    if (Input.isKeyDown(Key.SHIFT)) speed *= 2;

    PVector movement = Utils.useVector().set(0, 0, 0);
    if (Input.isKeyDown('d')) movement.add(camera.right);
    if (Input.isKeyDown('a')) movement.add(camera.right.mult(-1));
    if (Input.isKeyDown('w')) movement.add(camera.forward);
    if (Input.isKeyDown('s')) movement.add(camera.forward.mult(-1));
    movement.mult(speed);
    position.add(movement);
    Utils.free(movement);

    if (Input.isKeyDown(UP)) camera.rotation.add(-speed, 0, 0);
    if (Input.isKeyDown(DOWN)) camera.rotation.add(speed, 0, 0);
    if (Input.isKeyDown(LEFT)) camera.rotation.add(0, -speed, 0);
    if (Input.isKeyDown(RIGHT)) camera.rotation.add(0, speed, 0);

    PVector mouse = Input.getMouseMovement();
    float mouseDelta = (0.04 + delta * 7) * mouseSensitivity;
    camera.rotation.add(mouse.y * mouseDelta, mouse.x * mouseDelta);
    camera.rotation.x = constrain(camera.rotation.x, minPitch, maxPitch);
    
    camera.position.set(position);
    camera.use();
  }
}
