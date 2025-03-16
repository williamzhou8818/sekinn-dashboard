class Property {
  final String id;
  // 基本信息
  final String name; // 房源名称
  final String type; // 房源类型
  final String address; // 地址
  final String description; // 描述
  final List<String> images; // 图片列表
  // 设施
  final List<String> facilities; // 设施
  // 状态
  final String status; // 使用枚举表示状态
  final Map<String, bool> availableFrom; // 日历可用性
  // 价格
  final double basePrice; // 基础价格
  final double holidayPrice; // 节假日价格
  final double additionalFees; // 附加费用
  // 房间信息
  final int availableRooms; // 可用房间数
  // 入住规则
  final String minStayDays; // 最小入住天数
  final String checkInTime; // 入住时间
  final String checkOutTime; // 退房时间
  final String cancellationPolicy; // 取消政策
  // 评论
  final List<Reviews> reviews; // 评论列表

  Property({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.description,
    required this.images,
    required this.facilities,
    required this.status,
    required this.availableFrom,
    required this.basePrice,
    required this.holidayPrice,
    required this.additionalFees,
    required this.availableRooms,
    required this.minStayDays,
    required this.checkInTime,
    required this.checkOutTime,
    required this.cancellationPolicy,
    required this.reviews,
  });

  // 将对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'description': description,
      'images': images,
      'facilities': facilities,
      'status': status,
      'available_from': availableFrom,
      'base_price': basePrice,
      'holiday_price': holidayPrice,
      'additional_fees': additionalFees,
      'available_rooms': availableRooms,
      'min_stay_days': minStayDays,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'cancellation_policy': cancellationPolicy,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }

  // 从 JSON 创建对象
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      description: json['description'],
      images: List<String>.from(json['images'] ?? []), // 处理空值
      facilities: List<String>.from(json['facilities'] ?? []), // 处理空值
      status: json['status'],
      availableFrom:
          Map<String, bool>.from(json['available_from'] ?? {}), // 处理空值
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0, // 处理空值
      holidayPrice: (json['holiday_price'] as num?)?.toDouble() ?? 0.0, // 处理空值
      additionalFees:
          (json['additional_fees'] as num?)?.toDouble() ?? 0.0, // 处理空值
      availableRooms: (json['available_rooms'] as num?)?.toInt() ?? 0, // 处理空值
      minStayDays: json['min_stay_days'] ?? '', // 处理空值
      checkInTime: json['check_in_time'] ?? '', // 处理空值
      checkOutTime: json['check_out_time'] ?? '', // 处理空值
      cancellationPolicy: json['cancellation_policy'] ?? '', // 处理空值
      reviews: (json['reviews'] as List<dynamic>?) // 处理空值
              ?.map((review) => Reviews.fromJson(review))
              .toList() ??
          [], // 如果 reviews 为空，则返回空列表
    );
  }
}

class Reviews {
  final int id;
  final String propertyId;
  final String user;
  final double rating;
  final String comment;
  final String reply;
  final String createdAt;
  final String updatedAt;

  Reviews({
    required this.id,
    required this.propertyId,
    required this.user,
    required this.rating,
    required this.comment,
    required this.reply,
    required this.createdAt,
    required this.updatedAt,
  });

  // 将对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'user': user,
      'rating': rating,
      'comment': comment,
      'reply': reply,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // 从 JSON 创建对象
  factory Reviews.fromJson(Map<String, dynamic> json) {
    return Reviews(
      id: json['id'],
      propertyId: json['property_id'],
      user: json['user'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      reply: json['reply'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
