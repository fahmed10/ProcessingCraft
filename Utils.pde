static class Utils {
  private static Map<String, List<Double>> profileTimes = new HashMap<>();
  
  static boolean distGreater(PVector a, PVector b, float dist) {
    return sq(b.x - a.x) + sq(b.y - a.y) > sq(dist);
  }
  
  static boolean distLesser(PVector a, PVector b, float dist) {
    return !distGreater(a, b, dist);
  }
  
  static void profile(String name, Action0 fn) {
    long start = System.nanoTime();
    fn.invoke();
    double time = (double)(System.nanoTime() - start) * 1e-6;
    profileTimes.computeIfAbsent(name, n -> new ArrayList<>()).add(time);
    println(name + ": " + String.format("%.2f", time) + "ms <Avg: " + String.format("%.2f", profileTimes.get(name).stream().mapToDouble(d -> d).average().orElseThrow()) + "ms>");
  }
  
  static <T> T profile(String name, Func1<T> fn) {
    long start = System.nanoTime();
    T value = fn.invoke();
    double time = (double)(System.nanoTime() - start) * 1e-6;
    profileTimes.computeIfAbsent(name, n -> new ArrayList<>()).add(time);
    println(name + ": " + String.format("%.2f", time) + "ms <Avg: " + String.format("%.2f", profileTimes.get(name).stream().mapToDouble(d -> d).average().orElseThrow()) + "ms>");
    return value;
  }
  
  static void profileMicro(String name, Action0 fn) {
    long start = System.nanoTime();
    fn.invoke();
    double time = (double)(System.nanoTime() - start) * 1e-3;
    profileTimes.computeIfAbsent(name, n -> new ArrayList<>()).add(time);
    println(name + ": " + String.format("%.3f", time) + "us <Avg: " + String.format("%.3f", profileTimes.get(name).stream().mapToDouble(d -> d).average().orElseThrow()) + "us>");
  }
  
  static <T> T profileMicro(String name, Func1<T> fn) {
    long start = System.nanoTime();
    T value = fn.invoke();
    double time = (double)(System.nanoTime() - start) * 1e-3;
    profileTimes.computeIfAbsent(name, n -> new ArrayList<>()).add(time);
    println(name + ": " + String.format("%.3f", time) + "us <Avg: " + String.format("%.3f", profileTimes.get(name).stream().mapToDouble(d -> d).average().orElseThrow()) + "us>");
    return value;
  }
  
  static void addAll(Collection<Integer> collection, int[] array) {
    for (int i : array) {
      collection.add(i);
    }
  }
  
  static PVector calculateVector(Func3<Float, Float, Float> fn, PVector v1, PVector v2, PVector out) {
    return out.set(fn.invoke(v1.x, v2.x), fn.invoke(v1.y, v2.y), fn.invoke(v1.z, v2.z));
  }
  
  static PVector calculateVector(Func4<Float, Float, Float, Float> fn, PVector v1, PVector v2, PVector v3, PVector out) {
    return out.set(fn.invoke(v1.x, v2.x, v3.x), fn.invoke(v1.y, v2.y, v3.y), fn.invoke(v1.z, v2.z, v3.z));
  }
  
  static PVector calculateVector(Func4<Float, Float, Float, Float> fn, float f, PVector v2, PVector v3, PVector out) {
    return out.set(fn.invoke(f, v2.x, v3.x), fn.invoke(f, v2.y, v3.y), fn.invoke(f, v2.z, v3.z));
  }
  
  static PVector calculateVector(Func5<Float, Float, Float, Float, Float> fn, PVector v1, PVector v2, PVector v3, PVector v4, PVector out) {
    return out.set(fn.invoke(v1.x, v2.x, v3.x, v4.x), fn.invoke(v1.y, v2.y, v3.y, v4.y), fn.invoke(v1.z, v2.z, v3.z, v4.z));
  }
  
  static PVector calculateVector(Func6<Float, Float, Float, Float, Float, Float> fn, PVector v1, PVector v2, PVector v3, PVector v4, PVector v5, PVector out) {
    return out.set(fn.invoke(v1.x, v2.x, v3.x, v4.x, v5.x), fn.invoke(v1.y, v2.y, v3.y, v4.y, v5.y), fn.invoke(v1.z, v2.z, v3.z, v4.z, v5.z));
  }
  
  static PVector calculateVector(Func6<Float, Float, Float, Float, Float, Float> fn, float f1, float f2, PVector v3, PVector v4, PVector v5, PVector out) {
    return out.set(fn.invoke(f1, f2, v3.x, v4.x, v5.x), fn.invoke(f1, f2, v3.y, v4.y, v5.y), fn.invoke(f1, f2, v3.z, v4.z, v5.z));
  }
}
