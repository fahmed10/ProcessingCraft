class Camera3D extends Object3D {
  final PVector WORLD_UP = new PVector(0, 1, 0);
  float clipNear = 1;
  float clipFar = 2000;
  PVector forward = new PVector();
  PVector right = new PVector();
  PVector up = new PVector();
  float fov = radians(60);
  float viewRatio;
  ViewFrustum frustum = new ViewFrustum();

  Camera3D() {
    setVectors();
    calculateFrustum();
  }

  private void setVectors() {
    forward.z = cos(radians(rotation.y)) * cos(radians(-rotation.x));
    forward.y = sin(radians(-rotation.x));
    forward.x = sin(radians(rotation.y)) * cos(radians(-rotation.x));
    forward = forward.normalize();
    right = right.set(forward).cross(WORLD_UP).normalize().mult(-1);
    up = up.set(forward).cross(right).normalize();
  }

  private void calculateFrustum() {
    float halfVSide = clipFar * tan(fov * 0.5);
    float halfHSide = halfVSide * viewRatio;
    PVector nearForward = Utils.useVector().set(forward).mult(clipNear);
    PVector farForward = Utils.useVector().set(forward).mult(clipFar);
    PVector vector = Utils.useVector(), vector2 = Utils.useVector(), vector3 = Utils.useVector();

    frustum.near.position.set(vector.set(position).add(nearForward));
    frustum.near.normal.set(forward).normalize();

    frustum.far.position.set(vector.set(position).add(farForward));
    frustum.far.normal.set(vector.set(forward).mult(-1)).normalize();

    frustum.top.position.set(position);
    frustum.top.normal.set(vector.set(right).cross(vector2.set(farForward).sub(vector3.set(up).mult(-halfVSide)))).normalize();

    frustum.bottom.position.set(position);
    frustum.bottom.normal.set(vector2.set(farForward).add(vector3.set(up).mult(-halfVSide)).cross(right)).normalize();

    frustum.left.position.set(position);
    frustum.left.normal.set(vector3.set(up).cross(vector2.set(farForward).add(vector.set(right).mult(-halfHSide)))).normalize();

    frustum.right.position.set(position);
    frustum.right.normal.set(vector2.set(farForward).sub(vector.set(right).mult(-halfHSide)).cross(up)).normalize();
    
    Utils.free(nearForward, farForward, vector, vector2, vector3);
  }

  void use() {
    viewRatio = (float)width/(float)height;
    setVectors();
    calculateFrustum();

    scale(1, -1, 1);
    camera(position.x, position.y, position.z,
      position.x + forward.x, position.y + forward.y, position.z + forward.z,
      -up.x, -up.y, -up.z);
    perspective(fov, viewRatio, clipNear, clipFar);
  }
}
