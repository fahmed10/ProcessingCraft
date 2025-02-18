@FunctionalInterface
interface Action0 {
  void invoke();
}

@FunctionalInterface
interface Action1<T1> {
  void invoke(T1 arg1);
}

@FunctionalInterface
interface Action2<T1, T2> {
  void invoke(T1 arg1, T2 arg2);
}

@FunctionalInterface
interface Action3<T1, T2, T3> {
  void invoke(T1 arg1, T2 arg2, T3 arg3);
}

@FunctionalInterface
interface Action4<T1, T2, T3, T4> {
  void invoke(T1 arg1, T2 arg2, T3 arg3, T4 arg4);
}

@FunctionalInterface
interface Func1<T1> {
  T1 invoke();
}

@FunctionalInterface
interface Func2<T1, T2> {
  T1 invoke(T2 arg1);
}

@FunctionalInterface
interface Func3<T1, T2, T3> {
  T1 invoke(T2 arg1, T3 arg2);
}

@FunctionalInterface
interface Func4<T1, T2, T3, T4> {
  T1 invoke(T2 arg1, T3 arg2, T4 arg3);
}

@FunctionalInterface
interface Func5<T1, T2, T3, T4, T5> {
  T1 invoke(T2 arg1, T3 arg2, T4 arg3, T5 arg4);
}

@FunctionalInterface
interface Func6<T1, T2, T3, T4, T5, T6> {
  T1 invoke(T2 arg1, T3 arg2, T4 arg3, T5 arg4, T6 arg5);
}
