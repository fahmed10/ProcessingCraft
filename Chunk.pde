import java.util.*;
import com.jogamp.newt.opengl.*;
import com.jogamp.opengl.*;

class Chunk {
  static final int CHUNK_BLOCKS = 16;
  static final int CHUNK_SIZE = CHUNK_BLOCKS * Block.BLOCK_SIZE;
  static final int CHUNK_MAX_Y = 128;
  static final int CHUNK_MIN_Y = -64;
  final IVector2 position;
  Map<IVector3, Block> blocks = new HashMap<>(CHUNK_BLOCKS * CHUNK_BLOCKS);
  int minY, maxY;
  World world;
  private Model3D model;

  Chunk(World world, IVector2 position) {
    this.position = position;
    this.world = world;
  }

  PVector getWorldCenter() {
    return CoordSpace.getChunkWorldCenter(position);
  }

  void getWorldCorners(PVector outMin, PVector outMax) {
    CoordSpace.getChunkWorldCorners(this, outMin, outMax);
  }

  void markMeshOutdated() {
    model = null;
  }

  void setBlock(IVector3 blockPos, BlockType type) {  
    if (blocks.containsKey(blockPos)) {
      blocks.get(blockPos).type = type;
      return;
    }
    
    if (blockPos.y < minY) minY = blockPos.y;
    if (blockPos.y > maxY) maxY = blockPos.y;

    IVector3 blockPosCopy = blockPos.copy();
    blocks.put(blockPosCopy, new Block(this, blockPosCopy, type));
    markMeshOutdated();
  }

  void setBlock(int x, int y, int z, BlockType type) {
    IVector3 temp = IVector3.use().set(x, y, z);
    setBlock(temp, type);
    temp.free();
  }
  
  void removeBlock(IVector3 blockPos) {
    blocks.remove(blockPos);
    markMeshOutdated();
    
    int chunkX = blockPos.x == 0 ? -1 : 0;
    int chunkY = blockPos.z == 0 ? -1 : 0;
    
    if (blockPos.x == CHUNK_BLOCKS - 1) chunkX = 1;
    if (blockPos.z == CHUNK_BLOCKS - 1) chunkY = 1;
    
    if (chunkX != 0) {
      world.getChunk(position.x + chunkX, position.y).markMeshOutdated();
    }
    
    if (chunkY != 0) {
      world.getChunk(position.x, position.y + chunkY).markMeshOutdated();
    }
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
        IVector3[] directions = CoordSpace.DIRECTIONS;

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
