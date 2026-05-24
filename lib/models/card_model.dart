class CardModel {
  final String id;
  final String name;
  final String netCharge;
  final String units;
  final String duration;
  final String productId;

  CardModel({
    required this.id,
    required this.name,
    required this.netCharge,
    required this.units,
    required this.duration,
    required this.productId,
  });

  static List<CardModel> getAll() => [
    CardModel(id: '1',  name: 'فكة 2.5',  netCharge: '1.75',  units: '45 وحدة',         duration: 'يوم واحد', productId: 'Fakka_2.5_Unite'),
    CardModel(id: '2',  name: 'فكة 3',    netCharge: '2.10',  units: '125 وحدة',        duration: 'يوم واحد', productId: 'Fakka_3_Unite'),
    CardModel(id: '3',  name: 'فكة 4.25', netCharge: '2.97',  units: '190 وحدة',        duration: 'يوم واحد', productId: 'Fakka_4.25_Unite'),
    CardModel(id: '4',  name: 'فكة 5',    netCharge: '3.50',  units: '225 وحدة',        duration: 'يوم واحد', productId: 'Fakka_5_Unite'),
    CardModel(id: '5',  name: 'فكة 6',    netCharge: '4.20',  units: '270 وحدة',        duration: 'يوم واحد', productId: 'Fakka_6_Unite'),
    CardModel(id: '6',  name: 'فكة 7',    netCharge: '4.90',  units: '300 وحدة',        duration: '3 أيام',   productId: 'Fakka_7_Unite'),
    CardModel(id: '7',  name: 'فكة 8',    netCharge: '5.60',  units: '350 وحدة',        duration: '3 أيام',   productId: 'Fakka_8_Unite'),
    CardModel(id: '8',  name: 'فكة 9',    netCharge: '6.30',  units: '400 وحدة',        duration: '4 أيام',   productId: 'Fakka_9_Unite'),
    CardModel(id: '9',  name: 'فكة 10',   netCharge: '7.00',  units: '450 وحدة',        duration: '7 أيام',   productId: 'Fakka_10_Unite'),
    CardModel(id: '10', name: 'فكة 10.5', netCharge: '7.35',  units: '400 وحدة + 50MB', duration: '4 أيام',   productId: 'Fakka_10.5_Unite'),
    CardModel(id: '11', name: 'فكة 11.5', netCharge: '8.05',  units: '550 وحدة',        duration: '7 أيام',   productId: 'Fakka_11.5_Unite'),
    CardModel(id: '12', name: 'فكة 12',   netCharge: '8.40',  units: '425 وحدة',        duration: '7 أيام',   productId: 'Fakka_12_Unite'),
    CardModel(id: '13', name: 'فكة 12.5', netCharge: '8.75',  units: '500 وحدة',        duration: '7 أيام',   productId: 'Fakka_12.5_Unite'),
    CardModel(id: '14', name: 'فكة 13',   netCharge: '9.10',  units: '500 وحدة',        duration: '7 أيام',   productId: 'Fakka_13_Unite'),
    CardModel(id: '15', name: 'فكة 13.5', netCharge: '9.45',  units: '625 وحدة',        duration: '7 أيام',   productId: 'Fakka_13.5_Unite'),
    CardModel(id: '16', name: 'فكة 15',   netCharge: '10.50', units: '550 وحدة',        duration: '7 أيام',   productId: 'Fakka_15_Unite'),
    CardModel(id: '17', name: 'فكة 15.5', netCharge: '10.85', units: '300 وحدة',        duration: '7 أيام',   productId: 'Fakka_15.5_Unite'),
    CardModel(id: '18', name: 'فكة 16.5', netCharge: '11.55', units: '425 وحدة',        duration: '6 أيام',   productId: 'Fakka_16.5_Unite'),
    CardModel(id: '19', name: 'فكة 17.5', netCharge: '12.25', units: '650 وحدة',        duration: '10 أيام',  productId: 'Fakka_17.5_Unite'),
    CardModel(id: '20', name: 'فكة 19.5', netCharge: '13.65', units: '550 وحدة',        duration: '10 أيام',  productId: 'Fakka_19.5_NewUnite'),
    CardModel(id: '21', name: 'فكة 20',   netCharge: '14.00', units: '700 وحدة',        duration: '10 أيام',  productId: 'Fakka_20_Unite'),
    CardModel(id: '22', name: 'فكة 26',   netCharge: '18.20', units: '750 وحدة',        duration: '10 أيام',  productId: 'Fakka_26_Unite'),
  ];
}
