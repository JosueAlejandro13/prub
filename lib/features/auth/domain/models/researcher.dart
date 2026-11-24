/// Representa al investigador en la sesión
class Researcher {
  final String phone;
  final String token;
  final DateTime sessionStartedAt;

  Researcher({
    required this.phone,
    required this.token,
    required this.sessionStartedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'token': token,
      'sessionStartedAt': sessionStartedAt.toIso8601String(),
    };
  }

  factory Researcher.fromMap(Map<String, dynamic> map) {
    return Researcher(
      phone: map['phone'] as String,
      token: map['token'] as String,
      sessionStartedAt: DateTime.parse(map['sessionStartedAt'] as String),
    );
  }
}
