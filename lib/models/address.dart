import 'dart:convert';

/// Địa chỉ giao hàng (Phường/Xã nhập tay).
class Address {
  final String recipientName;
  final String phone;
  final String city;
  final String district;
  final String ward;
  final String street;
  final String? building;
  final String? floor;
  final String? room;
  final String? note;
  final AddressType type;

  const Address({
    required this.recipientName,
    required this.phone,
    required this.city,
    required this.district,
    required this.ward,
    required this.street,
    this.building,
    this.floor,
    this.room,
    this.note,
    this.type = AddressType.home,
  });

  String get displayString {
    final parts = <String>[
      street,
      ward,
      district,
      city,
    ];
    if (building != null && building!.trim().isNotEmpty) {
      parts.insert(0, 'Tòa $building');
      if (floor != null && floor!.trim().isNotEmpty) {
        parts.insert(1, 'Tầng $floor');
      }
      if (room != null && room!.trim().isNotEmpty) {
        parts.insert(2, 'Phòng $room');
      }
    }
    return parts.where((e) => e.trim().isNotEmpty).join(', ');
  }

  String get shortDisplay => '$recipientName · $phone\n$displayString';

  String toJson() => jsonEncode({
        'r': recipientName,
        'p': phone,
        'c': city,
        'd': district,
        'w': ward,
        's': street,
        'b': building ?? '',
        'f': floor ?? '',
        'rm': room ?? '',
        'n': note ?? '',
        't': type.name,
      });

  static Address? fromJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return Address(
        recipientName: map['r'] as String? ?? '',
        phone: map['p'] as String? ?? '',
        city: map['c'] as String? ?? '',
        district: map['d'] as String? ?? '',
        ward: map['w'] as String? ?? '',
        street: map['s'] as String? ?? '',
        building: _opt(map['b']),
        floor: _opt(map['f']),
        room: _opt(map['rm']),
        note: _opt(map['n']),
        type: map['t'] == 'office' ? AddressType.office : AddressType.home,
      );
    } catch (_) {
      return null;
    }
  }

  static String? _opt(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}

enum AddressType { home, office }
