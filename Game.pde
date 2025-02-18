import java.util.Map;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;
import java.time.*;

class Game {
  Camera3D camera = new Camera3D();
  Map<IVector2, Chunk> chunks = new HashMap<>();
  PShader shader;
  PImage blockAtlas;
  float drawRadius = 3;

  void start() {
    shader = loadShader("block.frag", "block.vert");
    camera.position.set(0, 80, 0);
    ((PGraphicsOpenGL)g).textureSampling(2);
    blockAtlas = loadImage("img/block_atlas.png");
    PGraphicsOpenGL.maxAnisoAmount = 1; // Fix black lines appearing between blocks

    shader(shader);
    shader.set("tex", blockAtlas);
    shader.set("fogFar", drawRadius * 180);
    shader.set("fogNear", drawRadius * 160);
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
    camera.rotation.add(mouse.y * 0.2, mouse.x * 0.2);
    camera.rotation.x = constrain(camera.rotation.x, -80, 80);

    camera.use();

    drawTerrain();
  }

  void drawTerrain() {
    int chunkX = floor(camera.position.x / Chunk.CHUNK_SIZE);
    int chunkY = floor(camera.position.z / Chunk.CHUNK_SIZE);
    int drawChunks = ceil(drawRadius);
    PVector vector = new PVector();
    PVector chunkMin = new PVector();
    PVector chunkMax = new PVector();

    for (int x = -drawChunks; x <= drawChunks; x++) {
      for (int y = -drawChunks; y <= drawChunks; y++) {
        IVector2 chunkPos = new IVector2(chunkX + x, chunkY + y);
        CoordSpace.getChunkWorldPosition(chunkPos, vector);
        
        if (chunks.containsKey(chunkPos)) {
          getChunk(chunkPos).getWorldCorners(chunkMin, chunkMax);
        } else {
          CoordSpace.getChunkWorldCorners(chunkPos, chunkMin, chunkMax);
        }

        boolean inRadius = Utils.distLesser(camera.position, vector, drawRadius * Chunk.CHUNK_SIZE);
        boolean inFrustum = camera.frustum.containsBox(chunkMin, chunkMax);

        if (inRadius && (inFrustum || Utils.distLesser(camera.position, vector, 1 * Chunk.CHUNK_SIZE))) {
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
        int y = round(noiseValue * 5);
        IVector3 blockPos = new IVector3(x, y, z);
        chunk.blocks.put(blockPos, new Block(chunk, blockPos));
      }
    }

    chunk.generateMesh();
    return chunk;
  }
}
