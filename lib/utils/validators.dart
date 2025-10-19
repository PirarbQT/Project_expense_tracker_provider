class LangValidators {
  static String? requiredText(String? v, {String label = 'ฟิลด์'}) {
    if (v == null || v.trim().isEmpty) return '$label จำเป็น';
    return null;
  }

  static String? isoCode(String? v) {
    if (v == null || v.trim().isEmpty) return 'รหัส ISO จำเป็น';
    final t = v.trim();
    if (t.length < 2 || t.length > 3) return 'ต้องยาว 2–3 ตัวอักษร';
    if (!RegExp(r'^[A-Za-z]{2,3}$').hasMatch(t)) return 'ใช้ A–Z เท่านั้น';
    return null;
  }
}
