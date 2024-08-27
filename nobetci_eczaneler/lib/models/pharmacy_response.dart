class PharmacyResponse {
  String? name;
  String? dist;
  String? address;
  String? phone;
  String? loc;

  PharmacyResponse({this.name, this.dist, this.address, this.phone, this.loc});

  PharmacyResponse.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    dist = json['dist'];
    address = json['address'];
    phone = json['phone'];
    loc = json['loc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['dist'] = this.dist;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['loc'] = this.loc;
    return data;
  }
}
