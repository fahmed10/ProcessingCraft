class World {
  Map<IVector2, Chunk> chunks = new HashMap<>();

  Chunk getChunk(IVector2 position, boolean generate) {
    if (chunks.containsKey(position)) {
      Chunk chunk = chunks.get(position);
      if (generate && !chunk.hasMesh()) {
        chunk.generateMesh();
      }
      return chunk;
    }

    Chunk chunk = generateChunk(position);

    if (generate) {
      chunk.generateMesh();
    }

    chunks.put(position, chunk);
    return chunk;
  }

  Chunk generateChunk(IVector2 position) {
    Chunk chunk = new Chunk(this, position);

    for (int x = 0; x < Chunk.CHUNK_BLOCKS; x++) {
      for (int z = 0; z < Chunk.CHUNK_BLOCKS; z++) {
        float noiseValue = noise((position.x * Chunk.CHUNK_BLOCKS + x) * 0.1, (position.y * Chunk.CHUNK_BLOCKS + z) * 0.1);
        int y = round(noiseValue * 6);

        var local = new Object() {
          void addBlock(int x, int y, int z, BlockType type) {
            IVector3 blockPos = new IVector3(x, y, z);
            chunk.blocks.put(blockPos, new Block(chunk, blockPos, type));
          }
        };

        local.addBlock(x, y, z, y <= 1 ? BlockType.SAND : BlockType.GRASS);
        for (int i = 1; y - i >= -5; i++) {
          local.addBlock(x, y - i, z, BlockType.DIRT);
        }
      }
    }

    return chunk;
  }
}
