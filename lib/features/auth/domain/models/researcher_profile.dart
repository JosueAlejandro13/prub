/// Entidad que representa los datos de perfil del investigador
class ResearcherProfile {
  final String phone;
  final String name;
  final String rank;
  final String dimension;
  final String notes;

  const ResearcherProfile({
    required this.phone,
    this.name = '',
    this.rank = 'Explorador Novato',
    this.dimension = 'Tierra C-137',
    this.notes = '',
  });

  ResearcherProfile copyWith({
    String? phone,
    String? name,
    String? rank,
    String? dimension,
    String? notes,
  }) {
    return ResearcherProfile(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      rank: rank ?? this.rank,
      dimension: dimension ?? this.dimension,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'rank': rank,
      'dimension': dimension,
      'notes': notes,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory ResearcherProfile.fromMap(Map<String, dynamic> map) {
    return ResearcherProfile(
      phone: map['phone'] as String,
      name: map['name'] as String? ?? '',
      rank: map['rank'] as String? ?? 'Explorador Novato',
      dimension: map['dimension'] as String? ?? 'Tierra C-137',
      notes: map['notes'] as String? ?? '',
    );
  }
}
