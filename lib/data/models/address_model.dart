class Address {
  const Address({
    required this.id,
    this.label,
    required this.fullAddress,
    this.recipientName = '',
    this.phone = '',
  });

  final int id;
  final String? label;
  final String fullAddress;
  final String recipientName;
  final String phone;

  /// Display text for dropdown or compact address previews.
  String get displayText {
    final parts = <String>[];

    if (label != null && label!.trim().isNotEmpty) {
      parts.add(label!.trim());
    }

    if (recipientName.trim().isNotEmpty) {
      parts.add(recipientName.trim());
    }

    if (phone.trim().isNotEmpty) {
      parts.add(phone.trim());
    }

    parts.add(fullAddress);
    return parts.join(' - ');
  }

  Address copyWith({
    int? id,
    String? label,
    bool clearLabel = false,
    String? fullAddress,
    String? recipientName,
    String? phone,
  }) {
    return Address(
      id: id ?? this.id,
      label: clearLabel ? null : (label ?? this.label),
      fullAddress: fullAddress ?? this.fullAddress,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
    );
  }
}
