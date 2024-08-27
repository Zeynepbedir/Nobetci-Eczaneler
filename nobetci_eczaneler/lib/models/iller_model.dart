class CityAndDistrict {
  CityAndDistrict({
    required this.ilAdi,
    required this.ilceler,
  });

  final String? ilAdi;
  final List<Ilceler> ilceler;

  factory CityAndDistrict.fromJson(Map<String, dynamic> json) {
    return CityAndDistrict(
      ilAdi: json["il_adi"],
      ilceler: json["ilceler"] == null
          ? []
          : List<Ilceler>.from(
              json["ilceler"]!.map((x) => Ilceler.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "il_adi": ilAdi,
        "ilceler": ilceler.map((x) => x?.toJson()).toList(),
      };
}

class Ilceler {
  Ilceler({
    required this.ilceAdi,
  });

  final String? ilceAdi;

  factory Ilceler.fromJson(Map<String, dynamic> json) {
    return Ilceler(
      ilceAdi: json["ilce_adi"],
    );
  }

  Map<String, dynamic> toJson() => {
        "ilce_adi": ilceAdi,
      };
}
