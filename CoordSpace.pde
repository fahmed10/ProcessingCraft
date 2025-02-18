static class CoordSpace {
  static PVector getChunkWorldPosition(IVector2 position, PVector out) {
    out.set(position.x, 0, position.y);
    out.mult(Chunk.CHUNK_SIZE);
    return out.add(Chunk.CHUNK_SIZE / 2, Chunk.CHUNK_SIZE / 2);
  }
  
  static void getChunkWorldCorners(IVector2 position, PVector outMin, PVector outMax) {
    PVector center = getChunkWorldPosition(position, new PVector());
    outMin.set(center.copy().add(-Chunk.CHUNK_SIZE / 2, Chunk.CHUNK_MIN_Y * Block.BLOCK_SIZE, -Chunk.CHUNK_SIZE / 2));
    outMax.set(center.copy().add(Chunk.CHUNK_SIZE / 2, Chunk.CHUNK_MAX_Y * Block.BLOCK_SIZE, Chunk.CHUNK_SIZE / 2));
  }
  
  static void getChunkWorldCorners(Chunk chunk, PVector outMin, PVector outMax) {
    PVector center = chunk.getWorldPosition(new PVector());
    outMin.set(center.copy().add(-Chunk.CHUNK_SIZE / 2, chunk.minY * Block.BLOCK_SIZE, -Chunk.CHUNK_SIZE / 2));
    outMax.set(center.copy().add(Chunk.CHUNK_SIZE / 2, chunk.maxY * Block.BLOCK_SIZE, Chunk.CHUNK_SIZE / 2));
  }
  
  static PVector getBlockWorldPosition(IVector2 chunkPosition, IVector3 position, PVector out) {
    getChunkWorldPosition(chunkPosition, out);
    return out.add(position.x * Block.BLOCK_SIZE, position.y * Block.BLOCK_SIZE, position.z * Block.BLOCK_SIZE);
  }
}
