class AppValidators {
  AppValidators._();

  static String? requiredField(
    String? value, {
    String fieldName = 'Truong nay',
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }

    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, fieldName: 'email');
    if (requiredError != null) {
      return requiredError;
    }

    final input = value!.trim();
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(input)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final requiredError = requiredField(value, fieldName: 'mậ khẩu');
    if (requiredError != null) {
      return requiredError;
    }

    final input = value!;
    if (input.length < minLength) {
      return 'Mậ khẩu tối thiểu $minLength ký tự';
    }

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(input);
    final hasNumber = RegExp(r'[0-9]').hasMatch(input);
    if (!hasLetter || !hasNumber) {
      return 'Mậ khẩu cần có chữ và số';
    }

    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'giá'}) {
    final requiredError = requiredField(value, fieldName: fieldName);
    if (requiredError != null) {
      return requiredError;
    }

    final parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) {
      return '$fieldName không hợp lệ';
    }

    return null;
  }

  static String? optionalInt(String? value, {String fieldName = 'giá trị'}) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return null;
    }

    final parsed = int.tryParse(input);
    if (parsed == null || parsed < 0) {
      return '$fieldName phải là số nguyên >= 0';
    }

    return null;
  }

  static String? phone(String? value) {
    final requiredError = requiredField(value, fieldName: 'số điện thoại');
    if (requiredError != null) {
      return requiredError;
    }

    final digits = value!.replaceAll(RegExp(r'\s+'), '');
    final regex = RegExp(r'^(\+84|0)[0-9]{9,10}$');
    if (!regex.hasMatch(digits)) {
      return 'Số điện thoại không hợp lệ';
    }

    return null;
  }
}
