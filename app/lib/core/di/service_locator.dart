/// Simple service locator, same pattern as the Hope and caisse projects.
final sl = ServiceLocator();

class ServiceLocator {
  final _lazy = <Type, Object Function()>{};
  final _factories = <Type, Object Function()>{};
  final _singletons = <Type, Object>{};

  /// Registers an already built instance.
  void registerSingleton<T extends Object>(T instance) {
    _singletons[T] = instance;
  }

  /// Registers a single shared instance, created on first [get].
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _lazy[T] = factory;
  }

  /// Registers a per-call instance, never cached.
  void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  T get<T extends Object>() {
    final existing = _singletons[T];
    if (existing != null) return existing as T;
    final lazy = _lazy[T];
    if (lazy != null) return (_singletons[T] = lazy()) as T;
    final factory = _factories[T];
    if (factory != null) return factory() as T;
    throw StateError('No registration for $T. Did you call configureDependencies()?');
  }

  void reset() {
    _lazy.clear();
    _factories.clear();
    _singletons.clear();
  }
}
