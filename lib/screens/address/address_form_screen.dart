import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/vietnam_address.dart';
import '../../models/address.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({
    super.key,
    this.initialAddress,
    this.initialStreetFallback,
    this.onSaved,
  });

  final Address? initialAddress;
  final String? initialStreetFallback;
  final void Function(Address)? onSaved;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wardController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _roomController = TextEditingController();
  final _noteController = TextEditingController();

  String? _cityId;
  String? _districtId;
  String? _wardId;
  AddressType _addressType = AddressType.home;
  bool _saving = false;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    if (a != null) {
      _recipientController.text = a.recipientName;
      _phoneController.text = a.phone;
      _wardController.text = a.ward;
      _streetController.text = a.street;
      _buildingController.text = a.building ?? '';
      _floorController.text = a.floor ?? '';
      _roomController.text = a.room ?? '';
      _noteController.text = a.note ?? '';
      _addressType = a.type;
      _cityId = VietnamAddress.findProvinceIdByName(a.city);
      _districtId = VietnamAddress.findDistrictIdByName(_cityId, a.district);
      _wardId = VietnamAddress.findWardIdByName(_cityId, _districtId, a.ward);
    }
    if (a == null &&
        widget.initialStreetFallback != null &&
        widget.initialStreetFallback!.trim().isNotEmpty &&
        _streetController.text.isEmpty) {
      _streetController.text = widget.initialStreetFallback!.trim();
    }
    if (VietnamAddress.provinces.isNotEmpty && _cityId == null) {
      _cityId = VietnamAddress.provinces.first['id'] as String;
    }
    _syncDistrict();
    _syncWard();
  }

  void _syncDistrict() {
    if (_cityId == null) {
      _districtId = null;
      _wardId = null;
      return;
    }
    final dists = VietnamAddress.districtsFor(_cityId!);
    if (dists.isEmpty) {
      _districtId = '';
      _wardId = null;
      return;
    }
    if (_districtId == null ||
        _districtId!.isEmpty ||
        !dists.any((d) => d['id'] == _districtId)) {
      _districtId = dists.first['id'] as String;
    }
    _syncWard();
  }

  void _syncWard() {
    if (_cityId == null || _districtId == null || _districtId!.isEmpty) {
      _wardId = null;
      return;
    }
    final wards = VietnamAddress.wardsFor(_cityId!, _districtId!);
    if (wards.isEmpty) {
      _wardId = null;
      return;
    }
    if (_wardId == null ||
        !wards.any((w) => w['id'] == _wardId)) {
      _wardId = wards.first['id'] as String;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _wardController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _roomController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _validatePhone(String? v) {
    final s = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (s.length != 10) return false;
    return RegExp(r'^0[35789]\d{8}$').hasMatch(s);
  }

  void _checkPhoneRealtime() {
    final v = _phoneController.text;
    if (v.isEmpty) {
      if (_phoneError != null) setState(() => _phoneError = null);
      return;
    }
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && !_validatePhone(v)) {
      if (_phoneError == null) setState(() => _phoneError = 'SĐT phải bắt đầu 03/05/07/08/09');
    } else if (_phoneError != null) {
      setState(() => _phoneError = null);
    }
  }

  Future<void> _save() async {
    _phoneError = null;
    if (!_formKey.currentState!.validate()) return;
    if (!_validatePhone(_phoneController.text)) {
      setState(() => _phoneError = 'Số điện thoại phải có 10 số, bắt đầu 03/05/07/08/09');
      return;
    }

    if (_cityId == null || _cityId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Tỉnh/Thành phố')),
      );
      return;
    }
    if (_districtId == null || _districtId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Quận/Huyện')),
      );
      return;
    }

    final cityMatch = VietnamAddress.provinces.where((p) => p['id'] == _cityId).toList();
    final districtMatch =
        VietnamAddress.districtsFor(_cityId!).where((d) => d['id'] == _districtId).toList();
    final cityName = cityMatch.isEmpty ? '' : cityMatch.first['name'] as String;
    final districtName = districtMatch.isEmpty ? '' : districtMatch.first['name'] as String;

    String wardName;
    final wards = VietnamAddress.wardsFor(_cityId!, _districtId!);
    if (wards.isNotEmpty && _wardId != null && _wardId!.isNotEmpty) {
      final w = wards.where((x) => x['id'] == _wardId).toList();
      wardName = w.isEmpty ? _wardController.text.trim() : w.first['name'] as String;
    } else {
      wardName = _wardController.text.trim();
    }

    final address = Address(
      recipientName: _recipientController.text.trim(),
      phone: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
      city: cityName,
      district: districtName,
      ward: wardName,
      street: _streetController.text.trim(),
      building: _buildingController.text.trim().isEmpty ? null : _buildingController.text.trim(),
      floor: _floorController.text.trim().isEmpty ? null : _floorController.text.trim(),
      room: _roomController.text.trim().isEmpty ? null : _roomController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      type: _addressType,
    );

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onSaved?.call(address);
    Navigator.pop(context, address);
  }

  List<DropdownMenuItem<String>> _districtItems() {
    final list = VietnamAddress.districtsFor(_cityId ?? '');
    if (list.isEmpty) {
      return [const DropdownMenuItem(value: '', child: Text('Chưa có dữ liệu'))];
    }
    return list
        .map(
          (d) => DropdownMenuItem<String>(
            value: d['id'] as String,
            child: Text(d['name'] as String),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem<String>> _wardItems() {
    if (_cityId == null || _districtId == null || _districtId!.isEmpty) return [];
    final list = VietnamAddress.wardsFor(_cityId!, _districtId!);
    if (list.isEmpty) return [];
    return list
        .map(
          (w) => DropdownMenuItem<String>(
            value: w['id'] as String,
            child: Text(w['name'] as String),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wards = _cityId != null && _districtId != null && _districtId!.isNotEmpty
        ? VietnamAddress.wardsFor(_cityId!, _districtId!)
        : <Map<String, dynamic>>[];
    final useWardDropdown = wards.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thêm địa chỉ'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            _SectionTitle(icon: Icons.person_outline, title: 'Thông tin người nhận'),
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                children: [
                  _FormField(
                    controller: _recipientController,
                    label: 'Tên người nhận',
                    
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc nhập' : null,
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (_) {
                      if (_phoneError != null) setState(() => _phoneError = null);
                      _checkPhoneRealtime();
                    },
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Bắt buộc nhập';
                      if (!_validatePhone(v)) return 'Nhập số điện thoạithoại';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(icon: Icons.location_on_outlined, title: 'Địa chỉ chi tiết'),
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormField(
                    label: 'Tỉnh/Thành phố',
                    child: DropdownButtonFormField<String>(
                      value: _cityId,
                      decoration: _deco(context, 'Chọn Tỉnh/Thành phố'),
                      items: VietnamAddress.provinces
                          .map(
                            (p) => DropdownMenuItem<String>(
                              value: p['id'] as String,
                              child: Text(p['name'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _cityId = v;
                          _syncDistrict();
                        });
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Vui lòng chọn' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Quận/Huyện',
                    child: DropdownButtonFormField<String>(
                      value: _districtId,
                      decoration: _deco(context, 'Chọn Quận/Huyện'),
                      items: _districtItems(),
                      onChanged: (v) {
                        setState(() {
                          _districtId = v;
                          _syncWard();
                        });
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Vui lòng chọn' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (useWardDropdown)
                    _FormField(
                      label: 'Phường/Xã',
                      child: DropdownButtonFormField<String>(
                        value: _wardId,
                        decoration: _deco(context, 'Chọn Phường/Xã'),
                        items: _wardItems(),
                        onChanged: (v) => setState(() => _wardId = v),
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng chọn' : null,
                      ),
                    )
                  else
                    _FormField(
                      controller: _wardController,
                      label: 'Phường/Xã',
                      hint: 'Ví dụ: Phường Bến Nghé, Xã An Phú',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập Phường/Xã' : null,
                    ),
                  if (useWardDropdown) const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: _streetController,
                    label: 'Số nhà, tên đường',
                    hint: 'Ví dụ: 123 Nguyễn Huệ',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Bắt buộc nhập' : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tòa nhà, tầng, phòng (tùy chọn)',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _buildingController,
                    label: null,
                    hint: 'Tòa nhà (VD: Landmark 81)',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          controller: _floorController,
                          label: null,
                          hint: 'Tầng',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FormField(
                          controller: _roomController,
                          label: null,
                          hint: 'Số phòng',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(icon: Icons.home_work_outlined, title: 'Loại địa chỉ'),
            const SizedBox(height: 12),
            _SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: _AddressTypeChip(
                      icon: Icons.home_outlined,
                      label: 'Nhà riêng',
                      selected: _addressType == AddressType.home,
                      onTap: () => setState(() => _addressType = AddressType.home),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AddressTypeChip(
                      icon: Icons.business_outlined,
                      label: 'Văn phòng',
                      selected: _addressType == AddressType.office,
                      onTap: () => setState(() => _addressType = AddressType.office),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(icon: Icons.edit_note, title: 'Ghi chú cho tài xế'),
            const SizedBox(height: 12),
            _SectionCard(
              child: _FormField(
                controller: _noteController,
                label: null,
                hint: 'Gọi trước khi đến, đi cổng sau...',
                maxLines: 3,
                minLines: 2,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _StickyCta(
        saving: _saving,
        onSave: _save,
      ),
    );
  }

  InputDecoration _deco(BuildContext context, String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: cs.onSurfaceVariant.withOpacity(0.7),
        fontSize: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.child,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final decoration = InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      errorMaxLines: 2,
      labelStyle: TextStyle(
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: cs.onSurfaceVariant.withOpacity(0.7),
        fontSize: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    if (child != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          child!,
        ],
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines ?? maxLines,
      style: TextStyle(
        color: cs.onSurface,
        fontSize: 16,
        height: 1.35,
      ),
      decoration: decoration,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AddressTypeChip extends StatelessWidget {
  const _AddressTypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: selected ? cs.primary : cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? cs.primary : cs.onSurface,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyCta extends StatelessWidget {
  const _StickyCta({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 1,
          ),
          onPressed: saving ? null : onSave,
          child: saving
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onPrimary,
                  ),
                )
              : const Text('Lưu địa chỉ'),
        ),
      ),
    );
  }
}
