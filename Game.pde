import java.util.*;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;
import java.time.*;
import processing.sound.*;

class Game {
  World world = new World();
  Player player = new Player(world);
  PShader shader;
  PImage blockAtlas;
  float drawRadius = 3000;
  PVector skyColor = new PVector(0, 0.85, 1);
  PVector sunDirection = new PVector(1, -2, 0.75).normalize();

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
    shader.set("viewportSize", (float)width, (float)height);
    background(Utils.toColor(skyColor));
    noStroke();
    gl.glEnable(GL.GL_CULL_FACE);
    println(delta * 1e3 + "ms (" + (int)frameRate + " FPS)");

    if (Input.isKeyDown(Key.ESC)) {
      Input.setPointerLocked(false);
    }

    if (Input.isMouseButtonDown(Mouse.LEFT)) {
      Input.setPointerLocked(true);
    }

    player.update(delta);

    drawTerrain();
  }

  void drawTerrain() {
    IVector2 currentChunkPosition = CoordSpace.getWorldChunkPosition(player.position);
    int drawChunks = ceil(drawRadius / Chunk.CHUNK_SIZE);
    int chunksGenerated = 0;

    for (int x = -drawChunks; x <= drawChunks; x++) {
      for (int y = -drawChunks; y <= drawChunks; y++) {
        IVector2 chunkPos = IVector2.use().set(currentChunkPosition.x + x, currentChunkPosition.y + y);

        PVector chunkMin = Utils.useVector();
        PVector chunkMax = Utils.useVector();
        CoordSpace.getChunkWorldCorners(chunkPos, chunkMin, chunkMax);
        boolean inFrustum = player.camera.frustum.containsBox(chunkMin, chunkMax);

        if (!inFrustum) {
          Utils.free(chunkMin);
          Utils.free(chunkMax);
          chunkPos.free();
          continue;
        }

        if (!world.chunks.containsKey(chunkPos) || !world.chunks.get(chunkPos).hasMesh()) {
          if (chunksGenerated >= 3) {
            chunkPos.free();
            Utils.free(chunkMin);
            Utils.free(chunkMax);
            continue;
          } else {
            chunksGenerated++;
          }
        }

        Chunk chunk = world.getChunk(chunkPos, true);
        chunk.getWorldCorners(chunkMin, chunkMax);
        inFrustum = player.camera.frustum.containsBox(chunkMin, chunkMax);
        chunkPos.free();
        Utils.free(chunkMin);
        Utils.free(chunkMax);

        if (!inFrustum) {
          continue;
        }

        chunk.draw();
      }
    }
  }
}
