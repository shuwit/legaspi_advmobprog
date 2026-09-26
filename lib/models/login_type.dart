// Enhancement 2 Legaspi
enum LoginType {
  dummyJson,
  firebase,
}

// Enhancement 2 Legaspi
extension LoginTypeX on LoginType {
  String get label {
    switch (this) {
      case LoginType.dummyJson:
        return 'DummyJSON';
      case LoginType.firebase:
        return 'Firebase';
    }
  }

  String get storageValue => name;

  static LoginType fromStorage(String? value) {
    if (value == LoginType.firebase.name) {
      return LoginType.firebase;
    }
    return LoginType.dummyJson;
  }
}
