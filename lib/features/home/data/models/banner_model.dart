class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? linkUrl;
  final String? targetScreen;
  final int displayOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.linkUrl,
    this.targetScreen,
    this.displayOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  static const List<BannerModel> defaultBanners = [
    BannerModel(
      id: '7608883d-383f-4f84-a302-1fa71cdac314',
      title: 'Fast Air Cargo Special',
      subtitle: 'Guangzhou to Lagos in 3-5 days @ ₦12,500/kg',
      imageUrl:
          'https://images.unsplash.com/photo-1570710891163-6d3b5c47248b?w=1000&auto=format&fit=crop&q=80',
      targetScreen: 'air_freight',
      displayOrder: 1,
      isActive: true,
    ),
    BannerModel(
      id: '1a9b978e-7e94-4ece-871e-8bf2b186e6ed',
      title: 'Instant RMB Supplier Payments',
      subtitle: 'Zero delay Alipay & WeChat transfers at live market rates',
      imageUrl:
          'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=1000&auto=format&fit=crop&q=80',
      targetScreen: 'exchange',
      displayOrder: 2,
      isActive: true,
    ),
    BannerModel(
      id: 'fb216a5c-492f-4e10-95e6-7efb1dac3bc4',
      title: 'Save up to 40% on Consolidation',
      subtitle: 'Combine multiple package shipments into one single cargo batch',
      imageUrl:
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=1000&auto=format&fit=crop&q=80',
      targetScreen: 'consolidation',
      displayOrder: 3,
      isActive: true,
    ),
  ];

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
      linkUrl: json['linkUrl']?.toString(),
      targetScreen: json['targetScreen']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] != false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'linkUrl': linkUrl,
        'targetScreen': targetScreen,
        'displayOrder': displayOrder,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

