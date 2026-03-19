import 'package:flutter/material.dart';

import '../data/models/address_model.dart';
import '../data/repositories/address_repository.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({AddressRepository? addressRepository})
    : _addressRepository = addressRepository ?? AddressRepository();

  final AddressRepository _addressRepository;

  // CRUD địa chỉ + update state tự động.
  List<Address> addresses = [];
  bool isLoading = false;
  String? errorMessage;

  // selectedAddress cho CheckoutScreen.
  Address? selectedAddress;

  /// Load địa chỉ từ DB và rebuild UI.
  Future<void> fetchAddresses({int? preferredSelectedId}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _addressRepository.getAllAddresses();
      addresses = data;

      if (addresses.isEmpty) {
        selectedAddress = null;
      } else {
        if (preferredSelectedId != null) {
          final preferred = _findAddressById(preferredSelectedId);
          if (preferred != null) {
            selectedAddress = preferred;
          }
        }

        if (selectedAddress == null) {
          selectedAddress = addresses.first;
        } else {
          final exists = addresses.any(
            (item) => item.id == selectedAddress!.id,
          );
          if (!exists) {
            selectedAddress = addresses.first;
          }
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Address?> addAddress(Address address) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final insertedId = await _addressRepository.insertAddress(address);
      await fetchAddresses(preferredSelectedId: insertedId);
      return _findAddressById(insertedId);
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateAddress(Address address) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final affectedRows = await _addressRepository.updateAddress(address);
      if (affectedRows == 0) {
        throw Exception('Khong tim thay dia chi de cap nhat');
      }

      final preferredId = selectedAddress?.id == address.id
          ? address.id
          : selectedAddress?.id;

      await fetchAddresses(preferredSelectedId: preferredId);
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final preferredId = selectedAddress?.id == id
          ? null
          : selectedAddress?.id;
      await _addressRepository.deleteAddress(id);

      if (selectedAddress?.id == id) {
        selectedAddress = null;
      }

      await fetchAddresses(preferredSelectedId: preferredId);
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectAddress(Address address) {
    selectedAddress = address;
    notifyListeners();
  }

  Address? _findAddressById(int id) {
    for (final address in addresses) {
      if (address.id == id) {
        return address;
      }
    }

    return null;
  }
}
