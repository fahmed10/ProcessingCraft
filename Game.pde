import java.util.*;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;
import java.time.*;
import processing.sound.*;

class Game {
  Camera3D camera = new Camera3D();
  World world = new World();
  PShader shader;
  PImage blockAtlas;
  float drawRadius = 2000;
  final float maxMouseDelta = 6000;

  void start() {
    frameRate(1000);
    shader = loadShader("block.frag", "block.vert");
    camera.position.set(0, 80, 0);
    pgl.textureSampling(2);
    blockAtlas = loadImage(dataPath("img/block_atlas.png"));
    PGraphicsOpenGL.maxAnisoAmount = 1; // Fix black lines appearing between blocks

    shader(shader);
    shader.set("tex", blockAtlas);
    shader.set("fogFar", drawRadius - 200);
    shader.set("fogNear", (drawRadius - 200) * 0.93 - 15);
    
    new SoundFile(outer, "audio/music.mp3").play(1, 0.5);
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
    int drawChunks = ceil(drawRadius / Chunk.CHUNK_SIZE);
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
        boolean inRadius = Utils.distLesser(cameraXZ, vector, drawRadius);
        
        CoordSpace.getChunkWorldCorners(chunkPos, chunkMin, chunkMax);
        boolean inFrustum = true; //camera.frustum.containsBox(chunkMin, chunkMax) || camera.frustum.containsBox(new PVector(chunkMax.x, 0, chunkMin.z), new PVector(chunkMin.x, 0, chunkMax.z));

        if (!inRadius || !inFrustum) {
          continue;
        }

        if (!world.chunks.containsKey(chunkPos) || !world.chunks.get(chunkPos).hasMesh()) {
          if (chunksGenerated >= 4) {
            continue;
          } else {
            chunksGenerated++;
          }
        }

        Chunk chunk = world.getChunk(chunkPos, true);
        chunk.draw();
      }
    }
  }
}
