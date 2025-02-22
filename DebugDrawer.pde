class DebugDrawer {
  void drawSphere(PVector position, float radius) {
    pushMatrix();
    translate(position.x, position.y, position.z);
    sphere(radius);
    popMatrix();
  }
}
