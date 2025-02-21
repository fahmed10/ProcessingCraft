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
  float drawRadius = 2500;
  final float maxMouseDelta = 6000;
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
    shader.set("fogFar", drawRadius - 200);
    shader.set("fogNear", (drawRadius - 200) * 0.9 - 20);
    shader.set("fogColor", skyColor);
    shader.set("sunDirection", sunDirection);
    
    SoundFile music = new SoundFile(outer, "audio/music.mp3");
    music.loop();
    music.play(1, 0.5);
    
    player.start();
  }

  void update(float delta) {
    shader.set("viewportSize", (float)width, (float)height);
    background(Utils.toColor(skyColor));
    noStroke();
    gl.glEnable(GL.GL_CULL_FACE);
    println(delta * 1e3 + "ms (" + (int)frameRate + " FPS)");

    player.update(delta);

    drawTerrain();
  }

  void drawTerrain() {
    IVector2 currentChunkPosition = CoordSpace.getWorldChunkPosition(player.position);
    int drawChunks = ceil(drawRadius / Chunk.CHUNK_SIZE);
    PVector vector = new PVector();
    PVector chunkMin = new PVector();
    PVector chunkMax = new PVector();
    int chunksGenerated = 0;

    for (int x = -drawChunks; x <= drawChunks; x++) {
      for (int y = -drawChunks; y <= drawChunks; y++) {
        IVector2 chunkPos = new IVector2(currentChunkPosition.x + x, currentChunkPosition.y + y);
        CoordSpace.getChunkWorldCenter(chunkPos, vector);
        PVector cameraXZ = player.position.copy();
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
