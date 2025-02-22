import java.util.*;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;
import java.time.*;
import processing.sound.*;

class Game {
  World world = new World(321225);
  Player player = new Player(world);
  PShader shader;
  PImage blockAtlas;
  float drawRadius = 4000;
  PVector skyColor = new PVector(0, 0.85, 1);
  PVector sunDirection = new PVector(1, -2, 0.75).normalize();
  int chunksGenerated;
  long frameStartTime;

  void start() {
    frameRate(1000);
    shader = loadShader("block.frag", "block.vert");
    pgl.textureSampling(2);
    blockAtlas = loadImage(dataPath("img/block_atlas.png"));
    PGraphicsOpenGL.maxAnisoAmount = 1; // Fix black lines appearing between blocks

    shader(shader);
    shader.set("tex", blockAtlas);
    shader.set("fogFar", drawRadius - Chunk.CHUNK_SIZE / 1.75);
    shader.set("fogNear", (drawRadius - Chunk.CHUNK_SIZE / 1.75) * 0.9 - 30);
    shader.set("fogColor", skyColor);
    shader.set("sunDirection", sunDirection);

    SoundFile music = new SoundFile(outer, "audio/music.mp3");
    music.loop();
    music.play(1, 0.5);

    player.camera.clipFar = drawRadius;
    player.start();
  }

  void update(float delta) {
    frameStartTime = System.nanoTime();
    shader.set("viewportSize", (float)width, (float)height);
    background(Utils.toColor(skyColor));
    noStroke();
    // gl.glEnable(GL.GL_CULL_FACE);
    println(delta * 1e3 + "ms (" + (int)frameRate + " FPS)");

    if (Input.isKeyDown(Key.ESC)) {
      Input.setPointerLocked(false);
    }

    if (Input.isMouseButtonDown(Mouse.LEFT)) {
      Input.setPointerLocked(true);
    }

    drawTerrain();
    player.update(delta);
  }

  double frameTime() {
    return (double)(System.nanoTime() - frameStartTime) * 1e-9;
  }

  void drawTerrain() {
    IVector2 currentChunkPosition = CoordSpace.getWorldChunkPosition(player.position);
    int drawChunks = ceil(drawRadius / Chunk.CHUNK_SIZE);
    chunksGenerated = 0;

    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        drawChunk(currentChunkPosition, x, y);
      }
    }

    for (int x = -drawChunks; x <= drawChunks; x++) {
      for (int y = -drawChunks; y <= drawChunks; y++) {
        if (abs(x) <= 1 && abs(y) <= 1) {
          continue;
        }

        drawChunk(currentChunkPosition, x, y);
      }
    }

    currentChunkPosition.free();
  }

  void drawChunk(IVector2 currentChunkPosition, int x, int y) {
    IVector2 chunkPos = IVector2.use().set(currentChunkPosition.x, currentChunkPosition.y).add(x, y);

    PVector chunkMin = Utils.useVector();
    PVector chunkMax = Utils.useVector();
    Chunk chunk = world.getChunk(chunkPos, false);
    chunkPos.free();
    chunk.getWorldCorners(chunkMin, chunkMax);
    boolean inFrustum = player.camera.frustum.containsBox(chunkMin, chunkMax);
    Utils.free(chunkMin);
    Utils.free(chunkMax);

    if (!inFrustum) {
      return;
    }

    if (!chunk.hasMesh()) {
      if (chunksGenerated >= 1 && frameTime() > 1d/70) {
        return;
      } else {
        chunk.generateMesh();
        chunksGenerated++;
      }
    }

    chunk.draw();
  }
}
