import java.util.*;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;
import java.time.*;

class Game {
  Camera3D camera = new Camera3D();
  World world = new World();
  PShader shader;
  PImage blockAtlas;
  float drawRadius = 12;
  final float maxMouseDelta = 6000;

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
  }

  void update(float delta) {
    noStroke();
    gl.glEnable(GL.GL_CULL_FACE);
    println(delta * 1e3 + "ms (" + (int)frameRate + " FPS)");

    float speed = 200 * delta;

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
    float mouseDelta = (0.04 + delta * 7) * 1.5;
    camera.rotation.add(constrain(mouse.y * mouseDelta, -maxMouseDelta, maxMouseDelta), constrain(mouse.x * mouseDelta, -maxMouseDelta, maxMouseDelta));
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
    int chunksGenerated = 0;

    for (int x = -drawChunks; x <= drawChunks; x++) {
      for (int y = -drawChunks; y <= drawChunks; y++) {
        IVector2 chunkPos = new IVector2(currentChunkPosition.x + x, currentChunkPosition.y + y);
        CoordSpace.getChunkWorldCenter(chunkPos, vector);
        PVector cameraXZ = camera.position.copy();
        cameraXZ.y = 0;
        vector.y = 0;
        boolean inRadius = Utils.distLesser(cameraXZ, vector, drawRadius * Chunk.CHUNK_SIZE);

        if (!inRadius) {
          continue;
        }

        if (!world.chunks.containsKey(chunkPos) || !world.chunks.get(chunkPos).hasMesh()) {
          if (chunksGenerated >= 2) {
            continue;
          } else {
            chunksGenerated++;
          }
        }

        Chunk chunk = world.getChunk(chunkPos, true);
        chunk.getWorldCorners(chunkMin, chunkMax);
        boolean inFrustum = true; // camera.frustum.containsBox(chunkMin, chunkMax);

        if (inFrustum) {
          chunk.draw();
        }
      }
    }
  }
}
