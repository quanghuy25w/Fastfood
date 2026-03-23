/// Tỉnh/Thành + Quận/Huyện + Phường/Xã (mẫu). Thiếu dữ liệu → nhập tay.
class VietnamAddress {
  VietnamAddress._();

  static const List<Map<String, dynamic>> provinces = [
    {'id': '01', 'name': 'Thành phố Hà Nội'},
    {'id': '79', 'name': 'Thành phố Hồ Chí Minh'},
    {'id': '48', 'name': 'Thành phố Đà Nẵng'},
    {'id': '31', 'name': 'Thành phố Hải Phòng'},
    {'id': '75', 'name': 'Thành phố Cần Thơ'},
    {'id': '56', 'name': 'Tỉnh Khánh Hòa'},
    {'id': '60', 'name': 'Tỉnh Ninh Thuận'},
    {'id': '51', 'name': 'Tỉnh Quảng Ngãi'},
    {'id': '49', 'name': 'Tỉnh Quảng Nam'},
    {'id': '22', 'name': 'Tỉnh Quảng Ninh'},
  ];

  static List<Map<String, dynamic>> districtsFor(String provinceId) {
    const data = <String, List<Map<String, dynamic>>>{
      '01': [
        {'id': '001', 'name': 'Quận Ba Đình'},
        {'id': '002', 'name': 'Quận Hoàn Kiếm'},
        {'id': '003', 'name': 'Quận Tây Hồ'},
        {'id': '004', 'name': 'Quận Long Biên'},
        {'id': '005', 'name': 'Quận Cầu Giấy'},
        {'id': '006', 'name': 'Quận Đống Đa'},
        {'id': '007', 'name': 'Quận Hai Bà Trưng'},
        {'id': '008', 'name': 'Quận Hoàng Mai'},
        {'id': '009', 'name': 'Quận Thanh Xuân'},
      ],
      '79': [
        {'id': '760', 'name': 'Quận 1'},
        {'id': '761', 'name': 'Quận 2'},
        {'id': '762', 'name': 'Quận 3'},
        {'id': '763', 'name': 'Quận 4'},
        {'id': '764', 'name': 'Quận 5'},
        {'id': '765', 'name': 'Quận 6'},
        {'id': '766', 'name': 'Quận 7'},
        {'id': '767', 'name': 'Quận 8'},
        {'id': '768', 'name': 'Quận 9'},
        {'id': '769', 'name': 'Quận 10'},
        {'id': '770', 'name': 'Quận 11'},
        {'id': '771', 'name': 'Quận 12'},
        {'id': '772', 'name': 'Quận Bình Thạnh'},
        {'id': '773', 'name': 'Quận Gò Vấp'},
        {'id': '774', 'name': 'Quận Phú Nhuận'},
        {'id': '775', 'name': 'Quận Tân Bình'},
        {'id': '776', 'name': 'Quận Tân Phú'},
      ],
      '48': [
        {'id': '490', 'name': 'Quận Hải Châu'},
        {'id': '491', 'name': 'Quận Thanh Khê'},
        {'id': '492', 'name': 'Quận Sơn Trà'},
        {'id': '493', 'name': 'Quận Ngũ Hành Sơn'},
        {'id': '494', 'name': 'Quận Cẩm Lệ'},
        {'id': '495', 'name': 'Huyện Hòa Vang'},
      ],
    };
    return data[provinceId] ?? [];
  }

  /// Phường/Xã phụ thuộc Quận. Trả về rỗng nếu chưa có dữ liệu → dùng ô nhập tay.
  static List<Map<String, dynamic>> wardsFor(String provinceId, String districtId) {
    const data = <String, List<Map<String, dynamic>>>{
      '01_001': [
        {'id': '00001', 'name': 'Phường Điện Biên'},
        {'id': '00002', 'name': 'Phường Đội Cấn'},
        {'id': '00003', 'name': 'Phường Điện Biên Phủ'},
        {'id': '00004', 'name': 'Phường Liễu Giai'},
        {'id': '00005', 'name': 'Phường Ngọc Hà'},
      ],
      '01_002': [
        {'id': '00010', 'name': 'Phường Cửa Đông'},
        {'id': '00011', 'name': 'Phường Cửa Nam'},
        {'id': '00012', 'name': 'Phường Hàng Bạc'},
        {'id': '00013', 'name': 'Phường Hàng Bồ'},
        {'id': '00014', 'name': 'Phường Tràng Tiền'},
      ],
      '01_005': [
        {'id': '00020', 'name': 'Phường Dịch Vọng'},
        {'id': '00021', 'name': 'Phường Dịch Vọng Hậu'},
        {'id': '00022', 'name': 'Phường Mai Dịch'},
        {'id': '00023', 'name': 'Phường Nghĩa Đô'},
        {'id': '00024', 'name': 'Phường Quan Hoa'},
        {'id': '00025', 'name': 'Phường Trung Hòa'},
      ],
      '79_760': [
        {'id': '26734', 'name': 'Phường Bến Nghé'},
        {'id': '26735', 'name': 'Phường Bến Thành'},
        {'id': '26736', 'name': 'Phường Cầu Kho'},
        {'id': '26737', 'name': 'Phường Cầu Ông Lãnh'},
        {'id': '26738', 'name': 'Phường Nguyễn Cư Trinh'},
        {'id': '26739', 'name': 'Phường Nguyễn Thái Bình'},
        {'id': '26740', 'name': 'Phường Phạm Ngũ Lão'},
        {'id': '26741', 'name': 'Phường Tân Định'},
      ],
      '79_764': [
        {'id': '26800', 'name': 'Phường 1'},
        {'id': '26801', 'name': 'Phường 2'},
        {'id': '26802', 'name': 'Phường 3'},
        {'id': '26803', 'name': 'Phường 4'},
        {'id': '26804', 'name': 'Phường 5'},
        {'id': '26805', 'name': 'Phường 6'},
        {'id': '26806', 'name': 'Phường 7'},
        {'id': '26807', 'name': 'Phường 8'},
        {'id': '26808', 'name': 'Phường 9'},
      ],
      '79_772': [
        {'id': '26850', 'name': 'Phường 1'},
        {'id': '26851', 'name': 'Phường 2'},
        {'id': '26852', 'name': 'Phường 3'},
        {'id': '26853', 'name': 'Phường 5'},
        {'id': '26854', 'name': 'Phường 6'},
        {'id': '26855', 'name': 'Phường 7'},
        {'id': '26856', 'name': 'Phường 11'},
        {'id': '26857', 'name': 'Phường 12'},
        {'id': '26858', 'name': 'Phường 13'},
        {'id': '26859', 'name': 'Phường 14'},
        {'id': '26860', 'name': 'Phường 15'},
        {'id': '26861', 'name': 'Phường 17'},
      ],
      '48_490': [
        {'id': '20194', 'name': 'Phường Bình Hiên'},
        {'id': '20195', 'name': 'Phường Bình Thuận'},
        {'id': '20196', 'name': 'Phường Hải Châu I'},
        {'id': '20197', 'name': 'Phường Hải Châu II'},
        {'id': '20198', 'name': 'Phường Hòa Cường Bắc'},
        {'id': '20199', 'name': 'Phường Hòa Thuận'},
        {'id': '20200', 'name': 'Phường Thanh Bình'},
        {'id': '20201', 'name': 'Phường Thuận Phước'},
      ],
    };
    return data['${provinceId}_$districtId'] ?? [];
  }

  static String? findProvinceIdByName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final n = name.trim();
    for (final p in provinces) {
      final pn = p['name'] as String;
      if (pn == n || pn.contains(n) || n.contains(pn)) return p['id'] as String;
    }
    return null;
  }

  static String? findDistrictIdByName(String? provinceId, String? name) {
    if (provinceId == null || name == null || name.trim().isEmpty) return null;
    final n = name.trim();
    for (final d in districtsFor(provinceId)) {
      final dn = d['name'] as String;
      if (dn == n || dn.contains(n) || n.contains(dn)) return d['id'] as String;
    }
    return null;
  }

  static String? findWardIdByName(String? provinceId, String? districtId, String? name) {
    if (provinceId == null || districtId == null || name == null || name.trim().isEmpty) return null;
    final n = name.trim();
    for (final w in wardsFor(provinceId, districtId)) {
      final wn = w['name'] as String;
      if (wn == n || wn.contains(n) || n.contains(wn)) return w['id'] as String;
    }
    return null;
  }
}
