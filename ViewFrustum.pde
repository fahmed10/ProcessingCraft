class ViewFrustum {
  PVector nearBottomLeft = new PVector();
  PVector nearBottomRight = new PVector();
  PVector nearTopLeft = new PVector();
  PVector nearTopRight = new PVector();
  
  PVector farBottomLeft = new PVector();
  PVector farBottomRight = new PVector();
  PVector farTopLeft = new PVector();
  PVector farTopRight = new PVector();
  
  boolean containsPoint(PVector point) {
    return pointPlaneDistance(nearBottomRight, farBottomRight, nearTopRight, point) > 0 && // Right
    pointPlaneDistance(nearTopLeft, farBottomLeft, nearBottomLeft, point) > 0 && // Left
    pointPlaneDistance(nearTopLeft, nearTopRight, farTopRight, point) > 0 && // Top
    pointPlaneDistance(farBottomRight, nearBottomRight, nearBottomLeft, point) > 0 && // Bottom
    pointPlaneDistance(farTopLeft, farBottomRight, farBottomLeft, point) > 0; // Far
  }
  
  boolean containsBox(PVector min, PVector max) {
    return (pointPlaneDistance(nearBottomRight, farBottomRight, nearTopRight, min) > 0 || pointPlaneDistance(nearBottomRight, farBottomRight, nearTopRight, max) > 0) && // Right
    (pointPlaneDistance(nearTopLeft, farBottomLeft, nearBottomLeft, min) > 0 || pointPlaneDistance(nearTopLeft, farBottomLeft, nearBottomLeft, max) > 0); // Left
    //(pointPlaneDistance(nearTopLeft, nearTopRight, farTopRight, min) > 0 || pointPlaneDistance(nearTopLeft, nearTopRight, farTopRight, max) > 0) && // Top
    //(pointPlaneDistance(farBottomRight, nearBottomRight, nearBottomLeft, min) > 0 || pointPlaneDistance(farBottomRight, nearBottomRight, nearBottomLeft, max) > 0) && // Bottom
    //(pointPlaneDistance(farTopLeft, farBottomRight, farBottomLeft, min) > 0 || pointPlaneDistance(farTopLeft, farBottomRight, farBottomLeft, max) > 0); // Far
  }
  
  private float pointPlaneDistance(PVector p1, PVector p2, PVector p3, PVector point) {
    return getTriangleNormal(p1, p2, p3).dot(point.copy().sub(p1));
  }
  
  private PVector getTriangleNormal(PVector p1, PVector p2, PVector p3) {
    return new PVector(
      (p2.y - p1.y) * (p3.z - p1.z) - (p2.z - p1.z) * (p3.y - p1.y),
      (p2.z - p1.z) * (p3.x - p1.x) - (p2.x - p1.x) * (p3.z - p1.z),
      (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
    ).normalize();
  }
}
