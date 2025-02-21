class World {
  Map<IVector2, Chunk> chunks = new HashMap<>(32);

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
}
