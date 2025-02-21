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
    if (Input.isKeyDown('a')) movement.add(camera.right.mult(-1));
    if (Input.isKeyDown('w')) movement.add(camera.forward);
    if (Input.isKeyDown('s')) movement.add(camera.forward.mult(-1));
    movement.mult(speed);
    position.add(movement);
    Utils.free(movement);

    if (Input.isMouseButtonDown(Mouse.LEFT)) {
      Pair<IVector2, IVector3> pos = CoordSpace.getWorldBlockPosition(position);
      Chunk chunk = world.getChunk(pos.first, false);

      if (chunk.blocks.containsKey(pos.second)) {
        chunk.blocks.get(pos.second).type = currentBlockType;
        pos.second.free();
      } else {
        chunk.blocks.put(pos.second, new Block(chunk, pos.second, currentBlockType));
      }

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

    camera.position.set(position);
    camera.use();
  }
}
