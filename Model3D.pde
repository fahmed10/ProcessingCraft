class Model3D extends Object3D {
  PShape mesh;

  Model3D(PShape mesh) {
    this.mesh = mesh;
  }

  void draw() {
    pushMatrix();
    translate(position.x, position.y, position.z);
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    scale(scale.x, scale.y, scale.z);
    shape(mesh);
    popMatrix();
  }
}
