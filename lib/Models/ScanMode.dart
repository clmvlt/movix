enum ScanMode {
  Camera,
  Text,
  DT50,
  Zebra
}

ScanMode stringToScanMode(String value) {
  return ScanMode.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ScanMode.Camera,
  );
}
