class Block {
  static final int BLOCK_SIZE = 15;
  IVector3 position;
  Chunk chunk;
  
  Block(Chunk chunk, IVector3 position) {
    this.chunk = chunk;
    this.position = position;
  }
  
  void getWorldPosition(PVector out) {
    CoordSpace.getBlockWorldPosition(chunk.position, position, out);
  }
}
