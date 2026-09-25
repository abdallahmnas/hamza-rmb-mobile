class FacilityModel {
  final String id;
  final String code;
  final String name;
  final String location;
  final String country;
  final String type;
  final String status;
  final int capacityUtilization;
  final String currentVolume;
  final String maxVolume;
  final String address;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;

  const FacilityModel({
    required this.id,
    this.code = '',
    this.name = '',
    this.location = '',
    this.country = '',
    this.type = 'regional_hub',
    this.status = 'active',
    this.capacityUtilization = 0,
    this.currentVolume = '',
    this.maxVolume = '',
    this.address = '',
    this.contactName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isChina => country.toUpperCase() == 'CN';
  bool get isNigeria => country.toUpperCase() == 'NG';

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      type: json['type']?.toString() ?? 'regional_hub',
      status: json['status']?.toString() ?? 'active',
      capacityUtilization: (json['capacityUtilization'] as num?)?.toInt() ?? 0,
      currentVolume: json['currentVolume']?.toString() ?? '',
      maxVolume: json['maxVolume']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      contactName: json['contactName']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      contactEmail: json['contactEmail']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'location': location,
        'country': country,
        'type': type,
        'status': status,
        'capacityUtilization': capacityUtilization,
        'currentVolume': currentVolume,
        'maxVolume': maxVolume,
        'address': address,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'contactEmail': contactEmail,
        'imageUrl': imageUrl,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static const List<FacilityModel> defaultFacilities = [
    FacilityModel(
      id: '00363cbf-0cca-475d-99a6-6214cfe25ed1',
      code: 'CN-CAN-01',
      name: 'Guangzhou Primary Hub',
      location: 'Guangzhou, China',
      country: 'CN',
      type: 'regional_hub',
      status: 'active',
      capacityUtilization: 45,
      currentVolume: '450 packages',
      maxVolume: '1,000 pkgs/day',
      address: 'No. 88 Baiyun Cargo Road, Guangzhou, China',
      contactName: 'Chen Wei',
      contactPhone: '+86 20 8888 9999',
      contactEmail: 'guangzhou@hamzarmb.com',
      imageUrl:
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=2070&auto=format&fit=crop',
    ),
    FacilityModel(
      id: 'a26170f6-a06b-42bf-bcc0-5ba0574c4081',
      code: 'NG-ABJ-02',
      name: 'Abuja Express Station',
      location: 'Abuja, Nigeria',
      country: 'NG',
      type: 'dist_center',
      status: 'active',
      capacityUtilization: 35,
      currentVolume: '105 packages',
      maxVolume: '300 pkgs/day',
      address: 'Plot 402 Central Business District, Abuja, Nigeria',
      contactName: 'Aisha Bello',
      contactPhone: '+234 803 987 6543',
      contactEmail: 'abuja@hamzarmb.com',
      imageUrl:
          'https://images.unsplash.com/photo-1580674684081-776d3f27f292?q=80&w=2070&auto=format&fit=crop',
    ),
    FacilityModel(
      id: 'ef261cfd-9db9-4185-a2f8-baa1e308f8e2',
      code: 'NG-LOS-01',
      name: 'Lagos Central Distribution Hub',
      location: 'Lagos, Nigeria',
      country: 'NG',
      type: 'regional_hub',
      status: 'active',
      capacityUtilization: 60,
      currentVolume: '300 packages',
      maxVolume: '500 pkgs/day',
      address: '12 Commercial Avenue, Ikeja, Lagos, Nigeria',
      contactName: 'Emeka Nwosu',
      contactPhone: '+234 802 123 4567',
      contactEmail: 'lagos@hamzarmb.com',
      imageUrl:
          'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=2074&auto=format&fit=crop',
    ),
  ];
}
