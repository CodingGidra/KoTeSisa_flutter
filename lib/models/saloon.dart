class Saloon {
  final int? saloonId;
  final String nazivSalona;
  final String adresaUlica;
  final String? adresaBroj;
  final String grad;
  final String? postanskiBroj;
  final String? lokacija;
  final String brojTelefona;
  final String email;
  final String? radnoVrijeme;
  final String? logo;
  final String adminIme;
  final String password;
  final String? radnoVrijemeOd;
  final String? radnoVrijemeDo;

  Saloon({
    this.saloonId,
    required this.nazivSalona,
    required this.adresaUlica,
    this.adresaBroj,
    required this.grad,
    this.postanskiBroj,
    this.lokacija = "",
    required this.brojTelefona,
    required this.email,
    this.radnoVrijeme,
    this.logo,
    required this.adminIme,
    required this.password,
    this.radnoVrijemeOd,
    this.radnoVrijemeDo
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "nazivSalona": nazivSalona,
      "adresaUlica": adresaUlica,
      "adresaBroj": adresaBroj,
      "grad": grad,
      "postanskiBroj": postanskiBroj,
      "lokacija": lokacija,
      "brojTelefona": brojTelefona,
      "email": email,
      "adminIme": adminIme,
      "password": password,
      "radnoVrijeme": radnoVrijeme,
      "logo": logo,
      "radnoVrijemeOd": radnoVrijemeOd,
      "radnoVrijemeDo": radnoVrijemeDo,
    };

    if (saloonId != null) {
      map["saloonId"] = saloonId; // samo kod PUT-a
    }
    return map;
  }

  factory Saloon.fromJson(Map<String, dynamic> json) => Saloon(
    saloonId: json['saloonId'],
    nazivSalona: json["nazivSalona"] ?? "",
    adresaUlica: json["adresaUlica"] ?? "",
    adresaBroj: json["adresaBroj"] as String?,
    grad: json["grad"] ?? "",
    postanskiBroj: json["postanskiBroj"] as String?,
    lokacija: json["lokacija"] as String?,
    brojTelefona: json["brojTelefona"] ?? "",
    email: json["email"] ?? "",
    adminIme: json["adminIme"] ?? "",
    password: json["password"] ?? "",
    radnoVrijeme: json["radnoVrijeme"] as String?,
    radnoVrijemeOd: json['radnoVrijemeOd'] as String?,
    radnoVrijemeDo: json['radnoVrijemeDo'] as String?,
    logo: json["logo"] as String?,
  );
}
