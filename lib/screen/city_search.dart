import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nobetci_eczaneler/models/iller_model.dart';

import 'package:nobetci_eczaneler/models/pharmacy_response.dart';
import 'package:url_launcher/url_launcher.dart';

class CitySearch extends StatefulWidget {
  const CitySearch({super.key});

  @override
  State<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  List<CityAndDistrict>? veriler; //null gelebilir ? bundan dolayı kullanıldı.
  CityAndDistrict? selectedCity;
  Ilceler? selectedDistrict;
  List<PharmacyResponse>? eczaneler = [];

  final Dio dio = Dio();

  void _loadData() async {
    final dataString = await rootBundle.loadString('assets/files/il-ilce.json');
    final List<dynamic> dataJson = jsonDecode(dataString);

    //gelen veriden model oluşturup buraya verdim
    veriler = dataJson.map((item) => CityAndDistrict.fromJson(item)).toList();
    setState(() {});
  }

  Future<void> pharmacy() async {
    if (selectedCity != null && selectedDistrict != null) {
      try {
        final response = await dio.get(
          'https://api.collectapi.com/health/dutyPharmacy',
          queryParameters: {
            'il': selectedCity!.ilAdi,
            'ilce': selectedDistrict!.ilceAdi,
          },
          options: Options(
            headers: {
              'authorization':
                  'apikey 315DWws2dJyjbyHXgTrhvn:2qzpZ5W4TJoaM88XmznNAR',
              'content-type': 'application/json',
            },
          ),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = response.data['result'];
          eczaneler =
              data.map((item) => PharmacyResponse.fromJson(item)).toList();
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Veri Alınamadı : ${response.statusMessage}')),
          );
        }
      } catch (e) {
        print('Dio error : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu : $e')),
        );
      }
    }
  }

  //google haritaları açmak için
  Future<void> launchMaps(String location) async {
    String mapsUri =
        'https://www.google.com/maps/search/?api=1&query=$location';
    print('mapUri:$mapsUri');
    if (await canLaunchUrl(Uri.parse(mapsUri))) {
      await launchUrl(Uri.parse(mapsUri));
    } else {
      print("Haritalar Açılmıyor");
      throw 'Could not open the map';
    }
  }

  Future<void> phoneCall(String tel) async {
    String? telUri = 'tel:$tel';

    print('telUri:$telUri');
    if (await canLaunchUrl(Uri.parse(telUri))) {
      await launchUrl(Uri.parse(telUri));
    } else {
      print("Telefon bulunamadı");
      throw 'Could not open the Phone';
    }
  }

  @override
  void initState() {
    _loadData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Nöbetçi Eczaneler"),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: veriler == null
              ? const CircularProgressIndicator() //veriler yüklenirken yükleme simgesi göstermek
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          DropdownButton<CityAndDistrict>(
                              hint: const Text("İl Seçiniz"),
                              value: selectedCity,
                              items: veriler!.map((city) {
                                return DropdownMenuItem<CityAndDistrict>(
                                    value: city, child: Text(city.ilAdi ?? ''));
                              }).toList(), //list verisine dönüştürmezsem hata alıyorum.
                              onChanged: (CityAndDistrict? newVlue) {
                                setState(() {
                                  selectedCity = newVlue;
                                  selectedDistrict =
                                      null; //il değiştiğinde ilçe sıfırlansın
                                });
                              }),
                          const SizedBox(height: 20),
                          DropdownButton<Ilceler>(
                              hint: const Text("İlçe Seçiniz"),
                              value: selectedDistrict,
                              items: selectedCity?.ilceler.map((district) {
                                    return DropdownMenuItem<Ilceler>(
                                      value: district,
                                      child: Text(district.ilceAdi ?? ''),
                                    );
                                  }).toList() ??
                                  [],
                              onChanged: (Ilceler? newValue) {
                                setState(() {
                                  selectedDistrict = newValue;
                                });
                              }),
                        ],
                      ),
                      //buton _listview
                      ElevatedButton(
                        onPressed: pharmacy,
                        child: const Text('ARA'),
                      ),
                      Expanded(
                        child: eczaneler!.isEmpty
                            ? const Text('Eczane Bulunamadı')
                            : ListView.builder(
                                padding: EdgeInsets.all(8),
                                itemCount: eczaneler!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eczaneler![index].name ??
                                              'Eczane Adı Yok',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                        Text(
                                          eczaneler![index].dist ?? '',
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        Text(
                                          eczaneler![index].address ?? '',
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        Text(
                                          eczaneler![index].phone ?? '',
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  launchMaps(
                                                      eczaneler![index].loc ??
                                                          '');
                                                },
                                                child: Text("Yol Tarifi")),
                                            ElevatedButton(
                                                onPressed: () {
                                                  phoneCall(
                                                      eczaneler![index].phone ??
                                                          'telefon bulunamadı');
                                                },
                                                child: Text("Eczaneyi Ara"))
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }),
                      ),
                    ]),
        ));
  }
}
