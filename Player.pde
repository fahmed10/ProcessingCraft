class Player extends Object3D {
  float walkSpeed = 200;
  float sprintSpeed = 400;
  float mouseSensitivity = 1.5;
  float minPitch = -80, maxPitch = 80;
  Camera3D camera = new Camera3D();
  private World world;
  private BlockType currentBlockType = BlockType.DIRT;

  Player(World world) {
    this.world = world;
  }

  void start() {
    position.set(0, Block.BLOCK_SIZE * 6, 0);
  }

  void update(float delta) {
    float speed = 200 * delta;

    if (Input.isKeyDown(Key.SHIFT)) speed *= 2;

    PVector movement = Utils.useVector().set(0, 0, 0);
    if (Input.isKeyDown('d')) movement.add(camera.right);
    if (Input.isKeyDown('a')) movement.sub(camera.right);
    if (Input.isKeyDown('w')) movement.add(camera.forward);
    if (Input.isKeyDown('s')) movement.sub(camera.forward);
    movement.mult(speed);
    position.add(movement);
    Utils.free(movement);

    if (Input.isMouseButtonDown(Mouse.LEFT)) {
      Pair<IVector2, IVector3> pos = CoordSpace.getWorldBlockPosition(position);
      Chunk chunk = world.getChunk(pos.first, false);
      chunk.setBlock(pos.second, currentBlockType);
      chunk.markMeshOutdated();
      pos.first.free();
    }

    if (Input.isMouseButtonDown(Mouse.RIGHT)) {
      currentBlockType = BlockType.fromId((currentBlockType.getId() + 1) % BlockType.ids());
    }

    PVector mouse = Input.getMouseMovement();
    float mouseDelta = (0.04 + delta * 7) * mouseSensitivity;
    camera.rotation.add(mouse.y * mouseDelta, mouse.x * mouseDelta);
    camera.rotation.x = constrain(camera.rotation.x, minPitch, maxPitch);

    Block block = world.raycast(position, camera.forward, Block.BLOCK_SIZE * 10);
    if (block != null) {
      PVector blockPosition = block.getWorldPosition();
      resetShader();
      pushMatrix();
      translate(blockPosition.x, blockPosition.y - Block.BLOCK_SIZE / 2f + 0.02, blockPosition.z);
      noFill();
      strokeJoin(ROUND);
      stroke(0, 0, 0, 150);
      strokeWeight(0.15);
      box(Block.BLOCK_SIZE + 0.025);
      fill(255);
      shader(_game.shader);
      popMatrix();
    }

    camera.position.set(position);
    camera.use();
  }
}
