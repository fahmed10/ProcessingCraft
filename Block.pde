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
}

enum BlockType {
  GRASS(1, 2, 0, 0, 0, 0),
  DIRT(2, 2, 2, 2, 2, 2),
  SAND(4, 4, 4, 4, 4, 4);

  private int[] faceIds;

  private BlockType(int py, int ny, int px, int nx, int pz, int nz) {
    this.faceIds = new int[] {py, ny, px, nx, pz, nz};
  }

  int getId() {
    return ordinal();
  }

  int[] getFaceIds() {
    return faceIds;
  }
}
