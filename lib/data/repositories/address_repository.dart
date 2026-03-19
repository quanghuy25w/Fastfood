import '../models/address_model.dart';

class AddressRepository {
  static final List<Address> _storage = [
    const Address(
      id: 1,
      label: 'Nha rieng',
      recipientName: 'Nguyen Van A',
      phone: '0901234567',
      fullAddress: '123 Nguyen Trai, Quan 1, TP.HCM',
    ),
    const Address(
      id: 2,
      label: 'Cong ty',
      recipientName: 'Tran Thi B',
      phone: '0912345678',
      fullAddress: '45 Le Loi, Quan 3, TP.HCM',
    ),
  ];

  static int _idCounter = 3;

  Future<List<Address>> getAllAddresses() async {
    return List<Address>.from(_storage);
  }

  Future<int> insertAddress(Address address) async {
    final newAddress = Address(
      id: address.id <= 0 ? _idCounter++ : address.id,
      label: address.label,
      recipientName: address.recipientName,
      phone: address.phone,
      fullAddress: address.fullAddress,
    );

    _storage.add(newAddress);
    return newAddress.id;
  }

  Future<int> updateAddress(Address address) async {
    final index = _storage.indexWhere((item) => item.id == address.id);
    if (index == -1) {
      return 0;
    }

    _storage[index] = address;
    return 1;
  }

  Future<int> deleteAddress(int id) async {
    final before = _storage.length;
    _storage.removeWhere((item) => item.id == id);
    return before - _storage.length;
  }
}
