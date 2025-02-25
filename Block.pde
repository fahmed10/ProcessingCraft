static class Block {
  static final int BLOCK_SIZE = 15;
  IVector3 position;
  Chunk chunk;
  BlockType type;

  Block(Chunk chunk, IVector3 position, BlockType type) {
    this.chunk = chunk;
    this.position = position;
    this.type = type;
  }

  PVector getWorldPosition() {
    return CoordSpace.getBlockWorldPosition(chunk.position, position);
  }
  
  IVector3 getGlobalPosition() {
    return CoordSpace.getBlockGlobalPosition(chunk.position, position);
  }
  
  Block getBlockAtOffset(IVector3 offset) {
    IVector3 globalPosition = getGlobalPosition();
    Pair<Chunk, IVector3> pair = chunk.world.globalToLocalBlockPosition(globalPosition.add(offset));
    globalPosition.free();
    return pair.first.blocks.get(pair.second);
  }
  
  Block getBlockAtOffset(int x, int y, int z) {
    IVector3 temp = IVector3.use().set(x, y, z);
    Block block = getBlockAtOffset(temp);
    temp.free();
    return block;
  }
}

enum BlockType {
  GRASS(1, 2, 0, 0, 0, 0),
  DIRT(2, 2, 2, 2, 2, 2),
  SAND(4, 4, 4, 4, 4, 4),
  STONE(5, 5, 5, 5, 5, 5),
  DEBUG(3, 3, 3, 3, 3, 3);

  private static BlockType[] values = BlockType.values();
  private int[] faceIds;

  private BlockType(int py, int ny, int px, int nx, int pz, int nz) {
    this.faceIds = new int[] {py, ny, px, nx, pz, nz};
  }
  
  static BlockType fromId(int id) {
    return values[id];
  }
  
  static int ids() {
    return values.length;
  }

  int getId() {
    return ordinal();
  }

  int[] getFaceIds() {
    return faceIds;
  }
}
