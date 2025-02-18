import java.util.Objects;

class IVector2 {
  int x, y;
  
  IVector2() {}
  
  IVector2(int x, int y) {
    set(x, y);
  }
  
  void set(int x, int y) {
    this.x = x;
    this.y = y;
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

class IVector3 {
  int x, y, z;
  
  IVector3() {}
  
  IVector3(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  IVector3 copy() {
    return new IVector3(x, y, z);
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
