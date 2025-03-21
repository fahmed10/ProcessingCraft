static class CoordSpace {
  static final IVector3[] DIRECTIONS = { new IVector3(0, 1, 0), new IVector3(0, -1, 0), new IVector3(1, 0, 0), new IVector3(-1, 0, 0), new IVector3(0, 0, 1), new IVector3(0, 0, -1) };

  static PVector getChunkWorldCenter(IVector2 position) {
    PVector out = Utils.useVector().set(position.x, 0, position.y);
    return out.mult(Chunk.CHUNK_SIZE).add(Chunk.CHUNK_SIZE / 2f, 0, Chunk.CHUNK_SIZE / 2f);
  }

  static PVector getChunkWorldPosition(IVector2 position) {
    PVector out = Utils.useVector().set(position.x, 0, position.y);
    return out.mult(Chunk.CHUNK_SIZE);
  }

  static void getChunkWorldCorners(IVector2 position, PVector outMin, PVector outMax) {
    PVector center = getChunkWorldCenter(position);
    PVector centerCopy = Utils.useVector().set(center);
    outMin.set(center.add(-Chunk.CHUNK_SIZE / 2f, Chunk.CHUNK_MIN_Y * Block.BLOCK_SIZE, -Chunk.CHUNK_SIZE / 2f));
    outMax.set(centerCopy.add(Chunk.CHUNK_SIZE / 2f, Chunk.CHUNK_MAX_Y * Block.BLOCK_SIZE, Chunk.CHUNK_SIZE / 2f));
    Utils.free(center);
    Utils.free(centerCopy);
  }

  static void getChunkWorldCorners(Chunk chunk, PVector outMin, PVector outMax) {
    PVector center = chunk.getWorldCenter();
    PVector centerCopy = Utils.useVector().set(center);
    outMin.set(center.add(-Chunk.CHUNK_SIZE / 2f, chunk.minY * Block.BLOCK_SIZE, -Chunk.CHUNK_SIZE / 2f));
    outMax.set(centerCopy.add(Chunk.CHUNK_SIZE / 2f, chunk.maxY * Block.BLOCK_SIZE, Chunk.CHUNK_SIZE / 2f));
    Utils.free(center);
    Utils.free(centerCopy);
  }

  static PVector getBlockWorldPosition(IVector2 chunkPosition, IVector3 position) {
    PVector out = getChunkWorldPosition(chunkPosition);
    return out.add(position.x * Block.BLOCK_SIZE, position.y * Block.BLOCK_SIZE, position.z * Block.BLOCK_SIZE);
  }

  static IVector2 getWorldChunkPosition(PVector position) {
    return IVector2.use().set(floor((float)(position.x + Block.BLOCK_SIZE / 2f) / Chunk.CHUNK_SIZE), floor((float)(position.z + Block.BLOCK_SIZE / 2f) / Chunk.CHUNK_SIZE));
  }

  static Pair<IVector2, IVector3> getWorldBlockPosition(PVector position) {
    IVector2 chunkPos = getWorldChunkPosition(position);
    IVector3 blockPos = IVector3.use().set(Math.floorMod(floor((position.x + Block.BLOCK_SIZE / 2f) % (float)Chunk.CHUNK_SIZE / Block.BLOCK_SIZE), Chunk.CHUNK_BLOCKS), ceil(position.y / Block.BLOCK_SIZE), Math.floorMod(floor((position.z + Block.BLOCK_SIZE / 2f) % (float)Chunk.CHUNK_SIZE / Block.BLOCK_SIZE), Chunk.CHUNK_BLOCKS));
    return new Pair<>(chunkPos, blockPos);
  }
  
  static IVector3 getWorldBlockGlobalPosition(PVector position) {
    Pair<IVector2, IVector3> pair = getWorldBlockPosition(position);
    return getBlockGlobalPosition(pair.first, pair.second);
  }
  
  static IVector3 getBlockGlobalPosition(IVector2 chunkPos, IVector3 blockPos) {
    return IVector3.use().set(chunkPos.x * Chunk.CHUNK_BLOCKS + blockPos.x, blockPos.y, chunkPos.y * Chunk.CHUNK_BLOCKS + blockPos.z);
  }
}
