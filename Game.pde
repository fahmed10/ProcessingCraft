import java.util.*;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;
import java.time.*;

class Game {
  Camera3D camera = new Camera3D();
  Map<IVector2, Chunk> chunks = new HashMap<>();
  PShader shader;
  PImage blockAtlas;
  float drawRadius = 8;

  void start() {
    frameRate(1000);
    shader = loadShader("block.frag", "block.vert");
    camera.position.set(0, 80, 0);
    pgl.textureSampling(2);
    blockAtlas = loadImage("img/block_atlas.png");
    PGraphicsOpenGL.maxAnisoAmount = 1; // Fix black lines appearing between blocks

    shader(shader);
    shader.set("tex", blockAtlas);
    shader.set("fogFar", drawRadius * Chunk.CHUNK_SIZE - 220);
    shader.set("fogNear", drawRadius * Chunk.CHUNK_SIZE - 265);
    
    List<Integer> faceIds = new ArrayList<>();
    for (BlockType type : BlockType.values()) {
      Utils.addAll(faceIds, type.getFaceIds());
    }
    shader.set("faces", faceIds.stream().mapToInt(i -> i).toArray());
  }

  void update(float delta) {
    noStroke();
    gl.glEnable(GL.GL_CULL_FACE);
    println(delta + " (" + frameRate + ")");

    float speed = 100 * delta;

    if (Input.isKeyDown(Key.SHIFT)) speed *= 2;

    PVector movement = new PVector();
    if (Input.isKeyDown('d')) movement.add(camera.right);
    if (Input.isKeyDown('a')) movement.add(camera.right.mult(-1));
    if (Input.isKeyDown('w')) movement.add(camera.forward);
    if (Input.isKeyDown('s')) movement.add(camera.forward.mult(-1));
    movement.mult(speed);
    camera.position.add(movement);

    if (Input.isKeyDown(UP)) camera.rotation.add(-speed, 0, 0);
    if (Input.isKeyDown(DOWN)) camera.rotation.add(speed, 0, 0);
    if (Input.isKeyDown(LEFT)) camera.rotation.add(0, -speed, 0);
    if (Input.isKeyDown(RIGHT)) camera.rotation.add(0, speed, 0);

    PVector mouse = Input.getMouseMovement();
    camera.rotation.add(mouse.y * (0.025 + delta * 25), mouse.x * (0.025 + delta * 25));
    camera.rotation.x = constrain(camera.rotation.x, -80, 80);

    camera.use();

    drawTerrain();
  }

  void drawTerrain() {
    IVector2 currentChunkPosition = CoordSpace.getWorldChunkPosition(camera.position);
    int drawChunks = ceil(drawRadius);
    PVector vector = new PVector();
    PVector chunkMin = new PVector();
    PVector chunkMax = new PVector();

    for (int x = -drawChunks; x <= drawChunks; x++) {
      for (int y = -drawChunks; y <= drawChunks; y++) {
        IVector2 chunkPos = new IVector2(currentChunkPosition.x + x, currentChunkPosition.y + y);
        CoordSpace.getChunkWorldCenter(chunkPos, vector);
        Chunk chunk = getChunk(chunkPos);
        chunk.getWorldCorners(chunkMin, chunkMax);

        PVector cameraXZ = camera.position.copy();
        cameraXZ.y = 0;
        boolean inRadius = Utils.distLesser(cameraXZ, vector, drawRadius * Chunk.CHUNK_SIZE);
        inRadius |= Utils.distLesser(cameraXZ, vector, drawRadius * Chunk.CHUNK_SIZE);
        boolean inFrustum = true || camera.frustum.containsBox(chunkMin, chunkMax);
        vector.y = 0;

        if (inRadius && (inFrustum || Utils.distLesser(cameraXZ, vector, 2 * Chunk.CHUNK_SIZE))) {
          getChunk(chunkPos).draw(shader);
        }
      }
    }
  }

  Chunk getChunk(IVector2 position) {
    if (chunks.containsKey(position)) {
      return chunks.get(position);
    }

    Chunk chunk = generateChunk(position);
    chunks.put(position, chunk);
    return chunk;
  }

  Chunk generateChunk(IVector2 position) {
    Chunk chunk = new Chunk(position);

    for (int x = 0; x < Chunk.CHUNK_BLOCKS; x++) {
      for (int z = 0; z < Chunk.CHUNK_BLOCKS; z++) {
        float noiseValue = noise((position.x * Chunk.CHUNK_BLOCKS + x) * 0.1, (position.y * Chunk.CHUNK_BLOCKS + z) * 0.1);
        int y = round(noiseValue * 6);
        IVector3 blockPos = new IVector3(x, y, z);
        chunk.blocks.put(blockPos, new Block(chunk, blockPos, BlockType.DIRT));
      }
    }

    chunk.generateMesh();
    return chunk;
  }
}
