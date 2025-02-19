import java.util.*;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;

class Chunk {
  static final int CHUNK_BLOCKS = 16;
  static final int CHUNK_SIZE = CHUNK_BLOCKS * Block.BLOCK_SIZE;
  static final int CHUNK_MAX_Y = 128;
  static final int CHUNK_MIN_Y = -64;
  final IVector2 position;
  Map<IVector3, Block> blocks = new HashMap<>();
  int minY;
  int maxY;
  private Model3D model;

  Chunk(IVector2 position) {
    this.position = position;
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
    IVector3 position = new IVector3();
    List<Integer> colors = new ArrayList<>();

    if (!blocks.isEmpty()) {
      minY = maxY = blocks.values().iterator().next().position.y;

      for (Block block : blocks.values()) {
        IVector3 bp = block.position;

        if (bp.y < minY) minY = block.position.y;
        if (bp.y > maxY) maxY = block.position.y;

        int blockId = block.type.getId();
        int verticesDrawn = 0;

        if (!blockAtOffset(bp, position.set(0, 1, 0))) { drawPlaneTop(mesh, bp.x, bp.y, bp.z, blockId); verticesDrawn += 4; }
        if (!blockAtOffset(bp, position.set(0, -1, 0))) { drawPlaneBottom(mesh, bp.x, bp.y, bp.z, blockId); verticesDrawn += 4; }
        if (!blockAtOffset(bp, position.set(0, 0, 1))) { drawPlaneSideZ(mesh, bp.x, bp.y, bp.z, blockId); verticesDrawn += 4; }
        if (!blockAtOffset(bp, position.set(0, 0, -1))) { drawPlaneSideNZ(mesh, bp.x, bp.y, bp.z, blockId); verticesDrawn += 4; }
        if (!blockAtOffset(bp, position.set(1, 0, 0))) { drawPlaneSideX(mesh, bp.x, bp.y, bp.z, blockId); verticesDrawn += 4; }
        if (!blockAtOffset(bp, position.set(-1, 0, 0))) { drawPlaneSideNX(mesh, bp.x, bp.y, bp.z, blockId); verticesDrawn += 4; }
        
        for (int i = 0; i < verticesDrawn; i++) {
          colors.add(blockId);
        }
      }
    }

    mesh.endShape();
    model = new Model3D(mesh);
    
    for (int i = 0; i < mesh.getVertexCount(); i++) {
      mesh.setFill(i, color(colors.get(i), 0, 0));
    }
  }

  private boolean blockAtOffset(IVector3 bp, IVector3 offset) {
    IVector3 position = offset.add(bp);

    if (position.x >= 0 && position.y >= 0 && position.z >= 0 && position.x < CHUNK_BLOCKS && position.y < CHUNK_BLOCKS && position.z < CHUNK_BLOCKS) {
      return blocks.containsKey(position);
    }

    return false; // TODO: Check for blocks at chunk boundaries
  }

  void draw() {
    if (blocks.isEmpty()) {
      return;
    }

    model.position.set(position.x * CHUNK_SIZE, 0, position.y * CHUNK_SIZE);
    model.draw();
  }

  private void drawPlaneTop(PShapeOpenGL mesh, int x, int y, int z, float uvOffset) {
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), y * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1 + uvOffset, 1 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), y * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 1 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), y * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), y * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 0 + uvOffset, 1 + uvOffset);
  }

  private void drawPlaneBottom(PShape mesh, int x, int y, int z, float uvOffset) {
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 0 + uvOffset, 1 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 1 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1 + uvOffset, 1 + uvOffset);
  }

  private void drawPlaneSideZ(PShape mesh, int x, int y, int z, float uvOffset) {
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 0 + uvOffset, 1 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 0 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1 + uvOffset, 1 + uvOffset);
  }

  private void drawPlaneSideNZ(PShape mesh, int x, int y, int z, float uvOffset) {
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 1 + uvOffset, 1 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 1 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0 + uvOffset, 1 + uvOffset);
  }

  private void drawPlaneSideX(PShape mesh, int x, int y, int z, float uvOffset) {
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1 + uvOffset, 1 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x + 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0 + uvOffset, 1 + uvOffset);
  }

  private void drawPlaneSideNX(PShape mesh, int x, int y, int z, float uvOffset) {
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0 + uvOffset, 1 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z - 0.5), 0 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y - 1) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1 + uvOffset, 0 + uvOffset);
    mesh.vertex(Block.BLOCK_SIZE * (x - 0.5), (y) * Block.BLOCK_SIZE, Block.BLOCK_SIZE * (z + 0.5), 1 + uvOffset, 1 + uvOffset);
  }
}
