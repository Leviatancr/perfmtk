enum ProfileType {
  performance('performance'),
  balanced('balanced');

  const ProfileType(this.value);
  final String value;

  static ProfileType fromString(String value) {
    return ProfileType.values.firstWhere((profile) => profile.value == value,
        orElse: () => ProfileType.balanced);
  }

  String get displayName {
    switch (this) {
      case ProfileType.performance:
        return 'Performance';
      case ProfileType.balanced:
        return 'Balanced';
    }
  }
}
