enum ColorType { rgb, hex }

class TypeDetector {
  static ColorType detectType(String colorText) {
    final text = colorText.trim();

    if(RegExp(r'^rgb\((\d{1,3}%?,\s*){2}\d{1,3}%?\)$').hasMatch(text)) return ColorType.rgb;
    if(RegExp(r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$').hasMatch(text)) return ColorType.hex;

    throw FormatException('Invalid color format: $colorText');
  }

  static String getTypeName(ColorType type) {
    return type.toString().split('.').last.toUpperCase();
  }
}