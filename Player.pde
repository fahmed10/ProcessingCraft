class Player extends Object3D {
  float walkSpeed = 200;
  float sprintSpeed = 400;
  float mouseSensitivity = 1.35;
  float minPitch = -80, maxPitch = 80;
  float yVelocity = 0;
  boolean canJump = false;
  Camera3D camera = new Camera3D();
  private World world;
  private BlockType currentBlockType = BlockType.DIRT;
  private IVector3 cursor = new IVector3();
  private IVector3 cursorOffset = new IVector3();

  Player(World world) {
    this.world = world;
  }

  void start() {
    position.set(0, Block.BLOCK_SIZE * 20, 0);
  }

  void update(float delta) {
    float speed = 100 * delta;
    yVelocity -= delta * 200;
    yVelocity = max(yVelocity, 0);

    if (Input.isKeyDown(Key.SHIFT)) speed *= 2;
    if (Input.isKeyDown(Key.CTRL)) speed /= 3;
    if (canJump && Input.isKeyPressed(Key.SPACE)) { 
      yVelocity = 265;
      canJump = false;
    }

    PVector movement = Utils.useVector().set(0, 0, 0);
    if (Input.isKeyDown('d')) movement.add(camera.right);
    if (Input.isKeyDown('a')) movement.sub(camera.right);
    if (Input.isKeyDown('w')) movement.add(camera.forward);
    if (Input.isKeyDown('s')) movement.sub(camera.forward);
    movement.y = 0;
    movement.normalize().mult(speed);
    position.add(movement);
    
    position.add(0, yVelocity * delta, 0);
    if (world.getWorldBlock(position.copy().sub(-4, Block.BLOCK_SIZE / 2f, -4)) == null && world.getWorldBlock(position.copy().sub(4, Block.BLOCK_SIZE / 2f, 4)) == null) {
      position.sub(0, min(delta * 170, Block.BLOCK_SIZE), 0);
    } else {
      canJump = true;
      yVelocity = 0;
    }

    if (cursor != null) {
      if (Input.isMouseButtonPressed(Mouse.LEFT)) {
        Pair<Chunk, IVector3> pair = world.globalToLocalBlockPosition(cursor);
        pair.first.removeBlock(pair.second);
        pair.second.free();
      }

      if (Input.isMouseButtonPressed(Mouse.RIGHT) && !cursor.copy().add(cursorOffset).equals(CoordSpace.getWorldBlockGlobalPosition(position)) && !cursor.copy().add(cursorOffset).add(0, -1, 0).equals(CoordSpace.getWorldBlockGlobalPosition(position))) {
        Pair<Chunk, IVector3> pair = world.globalToLocalBlockPosition(cursor.copy().add(cursorOffset));
        pair.first.setBlock(pair.second, currentBlockType);
        pair.second.free();
      }

      if (Input.isKeyPressed('e')) {
        currentBlockType = BlockType.fromId((currentBlockType.getId() + 1) % BlockType.ids());
      }
    }

    PVector mouse = Input.getMouseMovement();
    float mouseDelta = (0.04 + delta * 7) * mouseSensitivity;
    camera.rotation.add(mouse.y * mouseDelta, mouse.x * mouseDelta);
    camera.rotation.x = constrain(camera.rotation.x, minPitch, maxPitch);

    resetShader();
    RaycastHit raycastHit = new RaycastHit();

    int i = 0;
    movement = movement.normalize();
    while ((world.raycast(position.copy().add(1, 1, 1), movement, 9.5, raycastHit) || world.raycast(position.copy().sub(1, 1, 1), movement, 10.5, raycastHit)) && i < 20) {
      if (raycastHit.blockNormal.absSum() == 0) {
        movement.set(movement.copy().mult(-speed));
      } else {
        movement.set(Utils.reflectVector(movement.copy().mult(speed), raycastHit.blockNormal.toPVector()));
      }
      position.add(movement);
      movement = movement.normalize();
      i++;
    }

    if (!world.raycast(camera.position, camera.forward, Block.BLOCK_SIZE * 5, raycastHit)) {
      cursor = null;
    } else {
      cursor = raycastHit.hitBlock.getGlobalPosition();
      cursorOffset = raycastHit.blockNormal;
      PVector blockPosition = raycastHit.hitBlock.getWorldPosition();
      pushMatrix();
      translate(blockPosition.x, blockPosition.y - Block.BLOCK_SIZE / 2f + 0.02, blockPosition.z);
      noFill();
      strokeJoin(ROUND);
      stroke(0, 0, 0, 150);
      strokeWeight(0.1);
      box(Block.BLOCK_SIZE + 0.025);
      popMatrix();
    }

    Utils.free(movement);
    camera.position.set(position);
    camera.position.add(0, Block.BLOCK_SIZE, 0);
    camera.calculateFrustum();
    camera.use();

    fill(255);
    pushMatrix();
    translate(camera.position.x, camera.position.y, camera.position.z);
    translate(camera.forward.x, camera.forward.y, camera.forward.z);
    noStroke();
    sphere(0.003);
    popMatrix();
  }
}
