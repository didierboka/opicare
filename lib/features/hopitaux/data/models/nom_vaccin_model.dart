class NomVaccinModel {
  final String idVac;
  final String nomVac;
  final String periodeVac;

  NomVaccinModel({
    required this.idVac,
    required this.nomVac,
    required this.periodeVac,
  });

  factory NomVaccinModel.fromJson(Map<String, dynamic> json) {
    return NomVaccinModel(
      idVac: json['IDVAC']?.toString() ?? '',
      nomVac: json['NOMVAC']?.toString() ?? '',
      periodeVac: json['PERIODEVAC']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDVAC': idVac,
      'NOMVAC': nomVac,
      'PERIODEVAC': periodeVac,
    };
  }

  @override
  String toString() {
    return 'NomVaccinModel(idVac: $idVac, nomVac: $nomVac, periodeVac: $periodeVac)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NomVaccinModel &&
        other.idVac == idVac &&
        other.nomVac == nomVac &&
        other.periodeVac == periodeVac;
  }

  @override
  int get hashCode {
    return idVac.hashCode ^ nomVac.hashCode ^ periodeVac.hashCode;
  }
} 