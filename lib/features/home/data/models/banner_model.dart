class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? linkUrl;
  final String? targetScreen;
  final int displayOrder;
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.linkUrl,
    this.targetScreen,
    this.displayOrder = 0,
    this.isActive = true,
  });

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
      };
}
