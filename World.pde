class World {
  Map<IVector2, Chunk> chunks = new HashMap<>(64);

  World(int seed) {
    noiseSeed(seed);
  }

  Chunk getChunk(IVector2 position, boolean generate) {
    if (chunks.containsKey(position)) {
      Chunk chunk = chunks.get(position);
      if (generate && !chunk.hasMesh()) {
        chunk.generateMesh();
      }
      return chunk;
    }

    IVector2 positionCopy = position.copy();
    Chunk chunk = generateChunk(positionCopy);

    if (generate) {
      chunk.generateMesh();
    }

    chunks.put(positionCopy, chunk);
    return chunk;
  }

  Chunk getChunk(int x, int y) {
    IVector2 temp = IVector2.use().set(x, y);
    Chunk chunk = getChunk(temp, false);
    temp.free();
    return chunk;
  }

  private float perlinNoise2d(float x, float y, float scale) {
    return noise(x * scale + 92834, y * scale - 52976);
  }

  Chunk generateChunk(IVector2 position) {
    Chunk chunk = new Chunk(this, position);

    for (int x = 0; x < Chunk.CHUNK_BLOCKS; x++) {
      for (int z = 0; z < Chunk.CHUNK_BLOCKS; z++) {
        float noiseValue = perlinNoise2d(position.x * Chunk.CHUNK_BLOCKS + x, position.y * Chunk.CHUNK_BLOCKS + z, 0.075);
        int y = round(noiseValue * 6);

        chunk.setBlock(x, y, z, y <= 2 ? BlockType.SAND : BlockType.GRASS);
        for (int i = 1; y - i >= -5; i++) {
          chunk.setBlock(x, y - i, z, BlockType.DIRT);
        }
      }
    }

    return chunk;
  }

  Block getWorldBlock(PVector position) {
    Pair<IVector2, IVector3> pair = CoordSpace.getWorldBlockPosition(position);
    if (!chunks.containsKey(pair.first)) {
      pair.first.free();
      pair.second.free();
      return null;
    }

    Chunk chunk = chunks.get(pair.first);
    Block block = chunk.blocks.get(pair.second);
    pair.first.free();
    pair.second.free();
    return block;
  }

  Pair<Chunk, IVector3> globalToLocalBlockPosition(IVector3 position) {
    IVector2 chunkPos = IVector2.use().set(floor((float)position.x / Chunk.CHUNK_BLOCKS), floor((float)position.z / Chunk.CHUNK_BLOCKS));
    if (!chunks.containsKey(chunkPos)) {
      chunkPos.free();
      return null;
    }

    Chunk chunk = chunks.get(chunkPos);
    IVector3 blockPos = IVector3.use().set(Math.floorMod(position.x, Chunk.CHUNK_BLOCKS), position.y, Math.floorMod(position.z, Chunk.CHUNK_BLOCKS));
    chunkPos.free();
    return new Pair(chunk, blockPos);
  }

  boolean raycast(PVector position, PVector direction, float maxDistance, RaycastHit out) {
    final float step = Block.BLOCK_SIZE / 40f;
    float distance = 0f;
    PVector currentPosition = Utils.useVector().set(position);

    while (distance <= maxDistance) {
      Block block = getWorldBlock(currentPosition);

      if (block != null) {
        PVector previousPosition = currentPosition.copy().sub(direction.copy().mult(step));
        out.hitBlock = block;
        IVector3 normal = CoordSpace.getWorldBlockGlobalPosition(previousPosition).sub(CoordSpace.getWorldBlockGlobalPosition(currentPosition));
        if (normal.x > 0 && block.getBlockAtOffset(1, 0, 0) != null) normal.x = 0;
        if (normal.y > 0 && block.getBlockAtOffset(0, 1, 0) != null) normal.y = 0;
        if (normal.z > 0 && block.getBlockAtOffset(0, 0, 1) != null) normal.z = 0;
        if (normal.x < 0 && block.getBlockAtOffset(-1, 0, 0) != null) normal.x = 0;
        if (normal.y < 0 && block.getBlockAtOffset(0, -1, 0) != null) normal.y = 0;
        if (normal.z < 0 && block.getBlockAtOffset(0, 0, -1) != null) normal.z = 0;
        out.blockNormal = normal;
        Utils.free(currentPosition);
        return true;
      }

      distance += step;
      currentPosition = currentPosition.add(direction.copy().mult(step));
    }

    Utils.free(currentPosition);
    return false;
  }
}

class RaycastHit {
  Block hitBlock;
  IVector3 blockNormal;
}
