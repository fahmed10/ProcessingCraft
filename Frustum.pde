static class ViewFrustum {
  Plane near = new Plane(), far = new Plane(), top = new Plane(), bottom = new Plane(), left = new Plane(), right = new Plane();

  boolean containsPoint(PVector point) {
    return right.distanceTo(point) > 0 &&
      left.distanceTo(point) > 0 &&
      top.distanceTo(point) > 0 &&
      bottom.distanceTo(point) > 0 &&
      far.distanceTo(point) > 0;
  }

  boolean containsBox(PVector min, PVector max) {
    return right.intersectsBox(min, max) &&
      left.intersectsBox(min, max) &&
      top.intersectsBox(min, max) &&
      bottom.intersectsBox(min, max) &&
      far.intersectsBox(min, max);
  }
}

static class Plane {
  PVector position = new PVector();
  PVector normal = new PVector();

  float distanceTo(PVector point) {
    PVector pointCopy = Utils.useVector().set(point);
    float d = normal.dot(pointCopy.sub(position));
    Utils.free(pointCopy);
    return d;
  }

  boolean intersectsBox(PVector min, PVector max) {
    PVector point = Utils.useVector();
    boolean intersect = distanceTo(point.set(min.x, min.y, min.z)) > 0 ||
      distanceTo(point.set(max.x, min.y, min.z)) > 0 ||
      distanceTo(point.set(min.x, max.y, min.z)) > 0 ||
      distanceTo(point.set(min.x, min.y, max.z)) > 0 ||
      distanceTo(point.set(max.x, max.y, max.z)) > 0 ||
      distanceTo(point.set(min.x, max.y, max.z)) > 0 ||
      distanceTo(point.set(max.x, min.y, max.z)) > 0 ||
      distanceTo(point.set(max.x, max.y, min.z)) > 0;
    Utils.free(point);
    return intersect;
  }
}
