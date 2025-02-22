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
  
  Block raycast(PVector position, PVector direction, float maxDistance) {
    final float step = Block.BLOCK_SIZE / 15f;
    float distance = 0f;
    PVector currentPosition = Utils.useVector().set(position);
    
    while (distance <= maxDistance) {
      Block block = getWorldBlock(currentPosition);
      
      if (block != null) {
        Utils.free(currentPosition);
        return block;
      }
      
      distance += step;
      currentPosition = currentPosition.add(direction.copy().mult(step));
    }
    
    Utils.free(currentPosition);
    return null;
  }
}
