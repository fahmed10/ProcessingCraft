class Camera3D extends Object3D {
  private final PVector UP_DIR = new PVector(0, 1, 0);
  private final float CLIP_NEAR = 1;
  private final float CLIP_FAR = 1000;
  PVector forward = new PVector();
  PVector right = new PVector();
  float fov = radians(60);
  float viewRatio;
  ViewFrustum frustum = new ViewFrustum();
  PMatrix3D inverseView = new PMatrix3D();

  Camera3D() {
    setVectors();
    calculateFrustum();
  }

  private void setVectors() {
    forward.z = cos(radians(rotation.y)) * cos(radians(-rotation.x));
    forward.y = sin(radians(-rotation.x));
    forward.x = sin(radians(rotation.y)) * cos(radians(-rotation.x));
    forward = forward.normalize();
    right = right.set(forward).cross(UP_DIR).normalize().mult(-1);
    
    PVector zAxis = forward.copy().mult(-1);
    zAxis.y = 0;
    zAxis = zAxis.normalize();
    PVector xAxis = UP_DIR.copy().cross(zAxis).normalize().mult(-1);
    PVector yAxis = UP_DIR;
    
    // println("X: " + xAxis + ", Y: " + yAxis + ", Z: " + zAxis);
    
    inverseView.m00 = xAxis.x;  inverseView.m01 = xAxis.y;  inverseView.m02 = xAxis.z;  inverseView.m03 = 0;
    inverseView.m10 = yAxis.x;  inverseView.m11 = yAxis.y;  inverseView.m12 = yAxis.z;  inverseView.m13 = 0;
    inverseView.m20 = zAxis.x;  inverseView.m21 = zAxis.y;  inverseView.m22 = zAxis.z;  inverseView.m23 = 0;
    inverseView.m30 = 0; inverseView.m31 = 0; inverseView.m32 = 0; inverseView.m33 = 1;
  }

  private void calculateFrustum() {
    float y_scale = 1 / tan(fov / 2);
    float x_scale = y_scale * viewRatio;

    float near_x = CLIP_NEAR * x_scale;
    float near_y = CLIP_NEAR * y_scale;

    float far_x = CLIP_FAR * x_scale;
    float far_y = CLIP_FAR * y_scale;

    float[] dest = new float[3];
    frustum.nearBottomLeft.set(near_x, near_y, CLIP_NEAR);
    frustum.nearBottomRight.set(-near_x, near_y, CLIP_NEAR);
    frustum.nearTopLeft.set(near_x, -near_y, CLIP_NEAR);
    frustum.nearTopRight.set(-near_x, -near_y, CLIP_NEAR);
    
    frustum.farBottomLeft.set(far_x, far_y, CLIP_FAR);
    frustum.farBottomRight.set(-far_x, far_y, CLIP_FAR);
    frustum.farTopLeft.set(far_x, -far_y, CLIP_FAR);
    frustum.farTopRight.set(-far_x, -far_y, CLIP_FAR);
    
    frustum.nearBottomRight.set(inverseView.mult(frustum.nearBottomRight.array(), dest)).add(position);
    frustum.nearTopLeft.set(inverseView.mult(frustum.nearTopLeft.array(), dest)).add(position);
    frustum.farBottomRight.set(inverseView.mult(frustum.farBottomRight.array(), dest)).add(position);
    frustum.farTopLeft.set(inverseView.mult(frustum.farTopLeft.array(), dest)).add(position);
    
    frustum.nearBottomLeft.set(inverseView.mult(frustum.nearBottomLeft.array(), dest)).add(position);
    frustum.nearTopRight.set(inverseView.mult(frustum.nearTopRight.array(), dest)).add(position);
    frustum.farBottomLeft.set(inverseView.mult(frustum.farBottomLeft.array(), dest)).add(position);
    frustum.farTopRight.set(inverseView.mult(frustum.farTopRight.array(), dest)).add(position);
  }
  
  PShape s;
  Model3D ss;
  
  void dv(PVector... vs) { for(PVector v : vs) { ss.position.set(v.x, v.y, v.z); ss.draw(); } }

  void use() {
    viewRatio = (float)width/(float)height;
    setVectors();
    calculateFrustum();
    
    if (s == null || Input.isKeyDown('f')) {
      s = createShape(SPHERE, 1);
      ss = new Model3D(s);
    }

    // dv(frustum.nearBottomRight, frustum.nearTopRight, frustum.nearTopLeft, frustum.nearBottomLeft, frustum.farBottomRight, frustum.farTopLeft, frustum.farBottomLeft, frustum.farTopRight);

    scale(1, -1, 1);
    camera(position.x, position.y, position.z,
      position.x + forward.x, position.y + forward.y, position.z + forward.z,
      -UP_DIR.x, -UP_DIR.y, -UP_DIR.z);
    perspective(fov, viewRatio, CLIP_NEAR, CLIP_FAR);
  }
}
