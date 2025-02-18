import java.util.List;
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
  Model3D cube;

  Chunk(IVector2 position) {
    this.position = position;
  }

  PVector getWorldPosition(PVector out) {
    return CoordSpace.getChunkWorldPosition(position, out);
  }

  void getWorldCorners(PVector outMin, PVector outMax) {
    CoordSpace.getChunkWorldCorners(this, outMin, outMax);
  }

  void generateMesh() {
    cube = new Model3D(createShape(BOX, Block.BLOCK_SIZE));

    if (!blocks.isEmpty()) {
      minY = maxY = blocks.values().iterator().next().position.y;

      for (Block block : blocks.values()) {
        if (block.position.y < minY) minY = block.position.y;
        if (block.position.y > maxY) maxY = block.position.y;
      }
    }
  }

  void draw(PShader shader) {
    if (blocks.isEmpty()) {
      return;
    }

    for (Block block : blocks.values()) {
      shader.set("faces", new int[] {1, 2, 0, 0, 0, 0});
      Model3D model = cube;

      model.position.set(block.position.x * Block.BLOCK_SIZE, block.position.y * Block.BLOCK_SIZE, block.position.z * Block.BLOCK_SIZE);
      model.position.add(position.x * CHUNK_SIZE, 0, position.y * CHUNK_SIZE);
      model.draw();
    }
  }
}
