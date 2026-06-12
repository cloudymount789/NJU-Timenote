class AppClock {
  const AppClock();

  DateTime now() => DateTime.now();
}

class FixedAppClock extends AppClock {
  const FixedAppClock(this.fixedNow);

  final DateTime fixedNow;

  @override
  DateTime now() => fixedNow;
}
