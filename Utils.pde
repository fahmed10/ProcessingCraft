static class Utils {
  private static Map<String, List<Double>> profileTimes = new HashMap<>();
  private static Stack<PVector> pool = new Stack<>();

  static PVector useVector() {
    if (pool.isEmpty()) {
      return new PVector();
    }

    return pool.pop();
  }

  static void free(PVector vector) {
    if (pool.size() > 100) {
      throw new Error("PVector: Memory leak detected.");
    }
    
    pool.push(vector);
  }

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

  static color toColor(PVector vector) {
    return toColor(vector.x, vector.y, vector.z);
  }

  static color toColor(int r, int g, int b) {
    return (r << 16) | (g << 8) | b;
  }

  static color toColor(float r, float g, float b) {
    return ((int)(r * 255) << 16) | ((int)(g * 255) << 8) | (int)(b * 255);
  }
}
