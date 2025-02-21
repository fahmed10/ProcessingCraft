import java.util.Objects;

static class IVector2 {
  int x, y;
  private static Stack<IVector2> pool = new Stack<>();

  IVector2() {}

  IVector2(int x, int y) {
    set(x, y);
  }

  static IVector2 use() {
    if (pool.isEmpty()) {
      return new IVector2();
    }

    return pool.pop();
  }

  void free() {
    if (pool.size() > 1000) {
      throw new Error("IVector2: Memory leak detected.");
    }
    
    pool.push(this);
  }
  
  IVector2 copy() {
    return use().set(x, y);
  }

  IVector2 set(int x, int y) {
    this.x = x;
    this.y = y;
    return this;
  }

  void add(IVector2 b) {
    x += b.x;
    y += b.y;
  }

  void sub(IVector2 b) {
    x -= b.x;
    y -= b.y;
  }

  @Override
    boolean equals(Object o) {
    if (o instanceof IVector2) {
      IVector2 b = (IVector2)o;
      return x == b.x && y == b.y;
    }

    return false;
  }

  @Override
    int hashCode() {
    return Objects.hash(x, y);
  }

  @Override
    String toString() {
    return "(" + x + ", " + y + ")";
  }
}

static class IVector3 {
  int x, y, z;
  private static Stack<IVector3> pool = new Stack<>();

  IVector3() {}

  IVector3(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  static IVector3 use() {
    if (pool.isEmpty()) {
      return new IVector3();
    }

    return pool.pop();
  }

  void free() {
    if (pool.size() > 1000) {
      throw new Error("IVector3: Memory leak detected.");
    }
    
    pool.push(this);
  }

  IVector3 copy() {
    return use().set(x, y, z);
  }

  IVector3 set(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
    return this;
  }

  IVector3 add(IVector3 b) {
    x += b.x;
    y += b.y;
    z += b.z;
    return this;
  }

  @Override
    boolean equals(Object o) {
    if (o instanceof IVector3) {
      IVector3 b = (IVector3)o;
      return x == b.x && y == b.y && z == b.z;
    }

    return false;
  }

  @Override
    int hashCode() {
    return Objects.hash(x, y, z);
  }

  @Override
    String toString() {
    return "(" + x + ", " + y + ", " + z + ")";
  }
}
