abstract class NomVaccinEvent {}

class LoadNomsVaccins extends NomVaccinEvent {
  final String typeVaccinId;
  
  LoadNomsVaccins(this.typeVaccinId);
}

class ClearNomsVaccins extends NomVaccinEvent {} 