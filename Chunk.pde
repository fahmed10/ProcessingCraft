import java.util.*;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;

class Chunk {
  static final int CHUNK_BLOCKS = 16;
  static final int CHUNK_SIZE = CHUNK_BLOCKS * Block.BLOCK_SIZE;
  static final int CHUNK_MAX_Y = 128;
  static final int CHUNK_MIN_Y = -64;
  final IVector2 position;
  final IVector3[] directions = { new IVector3(0, 1, 0), new IVector3(0, -1, 0), new IVector3(1, 0, 0), new IVector3(-1, 0, 0), new IVector3(0, 0, 1), new IVector3(0, 0, -1) };
  Map<IVector3, Block> blocks = new HashMap<>();
  int minY;
  int maxY;
  World world;
  private Model3D model;

  Chunk(World world, IVector2 position) {
    this.position = position;
    this.world = world;
  }

  PVector getWorldCenter(PVector out) {
    return CoordSpace.getChunkWorldCenter(position, out);
  }

  void getWorldCorners(PVector outMin, PVector outMax) {
    CoordSpace.getChunkWorldCorners(this, outMin, outMax);
  }

  void generateMesh() {
    PShapeOpenGL mesh = PShapeOpenGL.createShape(pgl, createShape());
    mesh.beginShape(QUADS);
    List<Integer> vertexData = new ArrayList<>();

    if (!blocks.isEmpty()) {
      minY = maxY = blocks.values().iterator().next().position.y;

      for (Block block : blocks.values()) {
        if (block.position.y < minY) minY = block.position.y;
        if (block.position.y > maxY) maxY = block.position.y;

        int[] faces = block.type.getFaceIds();

        for (int i = 0; i < directions.length; i++) {
          if (!blockAtOffset(block.position, directions[i])) {
            drawPlane(mesh, block.position, directions[i]);
            for (int j = 0; j < 4; j++) {
              vertexData.add(color(faces[i] / 256, faces[i] % 256, 0, 0));
            }
          }
        }
      }
    }

    mesh.endShape();
    model = new Model3D(mesh);

    for (int i = 0; i < mesh.getVertexCount(); i++) {
      mesh.setFill(i, vertexData.get(i));
    }
  }

  private boolean blockAtOffset(IVector3 bp, IVector3 offset) {
    IVector3 offsetPosition = bp.copy().add(offset);

    if (offsetPosition.x >= 0 && offsetPosition.z >= 0 && offsetPosition.x < CHUNK_BLOCKS && offsetPosition.z < CHUNK_BLOCKS) {
      return blocks.containsKey(offsetPosition);
    }

    IVector2 chunkPosition = new IVector2(position.x + offset.x, position.y + offset.z);

    Chunk chunk = world.getChunk(chunkPosition, false);
    offsetPosition = offsetPosition.set(offsetPosition.x - offset.x * CHUNK_BLOCKS, offsetPosition.y, offsetPosition.z - offset.z * CHUNK_BLOCKS);
    return chunk.blocks.containsKey(offsetPosition);
  }
  
  boolean hasMesh() {
    return model != null;
  }

  void draw() {
    if (blocks.isEmpty()) {
      return;
    }

    model.position.set(position.x * CHUNK_SIZE, 0, position.y * CHUNK_SIZE);
    model.draw();
  }

  private void drawPlane(PShape mesh, IVector3 position, IVector3 direction) {
    if (direction.y == 1) drawPlaneTop(mesh, position.x, position.y, position.z);
    else if (direction.y == -1) drawPlaneBottom(mesh, position.x, position.y, position.z);
    else if (direction.x == 1) drawPlaneSideX(mesh, position.x, position.y, position.z);
    else if (direction.x == -1) drawPlaneSideNX(mesh, position.x, position.y, position.z);
    else if (direction.z == 1) drawPlaneSideZ(mesh, position.x, position.y, position.z);
    else drawPlaneSideNZ(mesh, position.x, position.y, position.z);
  }

  private void drawPlaneTop(PShape mesh, int x, int y, int z) {
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), y * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1, 1);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), y * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 1, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), y * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), y * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 0, 1);
  }

  private void drawPlaneBottom(PShape mesh, int x, int y, int z) {
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 0, 1);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 1, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1, 1);
  }

  private void drawPlaneSideZ(PShape mesh, int x, int y, int z) {
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 0, 1);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 0, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1, 1);
  }

  private void drawPlaneSideNZ(PShape mesh, int x, int y, int z) {
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 1, 1);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 1, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0, 1);
  }

  private void drawPlaneSideX(PShape mesh, int x, int y, int z) {
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1, 1);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0, 1);
  }

  private void drawPlaneSideNX(PShape mesh, int x, int y, int z) {
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0, 1);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1, 0);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1, 1);
  }
}
