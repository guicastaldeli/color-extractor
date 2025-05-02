import 'dart:js_interop';
import 'package:web/web.dart' as web;

class ColorExtractor {
  List<Map<String, Object>> extractColors(web.ImageData imageData) {
    final rgbValues = _buildRgb(imageData);
    final quantizedColors = quantization(rgbValues, 0);

    return quantizedColors.map((c) {
      final r = c['r']!;
      final g = c['g']!;
      final b = c['b']!;

      return {
        ...c,
        'hex': rgbToHex(r, g, b),
        'rgbToString': 'rgb($r, $g, $b)',
      };
    }).toList();
  }

  //Hex
    String rgbToHex(int r, int g, int b) {
      return '#${toHex(r)}${toHex(g)}${toHex(b)}';
    }

    String toHex(int colorComponent) {
      return colorComponent.toRadixString(16).padLeft(2, '0');
    }
  //

  List<Map<String, int>> _buildRgb(web.ImageData imageData) {
    final rgbValues = <Map<String, int>>[];
    final data = List<int>.from(imageData.data.toDart);

    for(var i = 0; i < data.length; i += 4) {
      rgbValues.add({
        'r': data[i],
        'g': data[i + 1],
        'b': data[i + 2]
      });
    }

    return rgbValues;
  }
}

List<Map<String, int>> quantization(List<Map<String, int>> rgbValues, int depth) {
  const maxDepth = 4;

  if(depth == maxDepth || rgbValues.isEmpty) return [_calculateAverageColor(rgbValues)];

  final componentToSortBy = findColorRange(rgbValues);
  rgbValues.sort((a, b) => a[componentToSortBy]!.compareTo(b[componentToSortBy]!));

  final mid = rgbValues.length ~/ 2;
  return [
    ...quantization(rgbValues.sublist(0, mid), depth + 1),
    ...quantization(rgbValues.sublist(mid), depth + 1)
  ];
}

Map<String, int> _calculateAverageColor(List<Map<String, int>> colors) {
  if(colors.isEmpty) return { 'r': 0, 'g': 0, 'b': 0 };

  final total = colors.fold(
    { 'r': 0, 'g': 0, 'b': 0 },
    (prev, curr) => {
      'r': prev['r']! + curr['r']!,
      'g': prev['g']! + curr['g']!,
      'b': prev['b']! + curr['b']!
    }
  );

  return {
    'r': (total['r']! / colors.length).round(),
    'g': (total['g']! / colors.length).round(),
    'b': (total['b']! / colors.length).round()
  };
}

String findColorRange(List<Map<String, int>> rgbValues) {
  var rMin = double.maxFinite.toInt();
  var gMin = double.maxFinite.toInt();
  var bMin = double.maxFinite.toInt();

  var rMax = double.minPositive.toInt();
  var gMax = double.minPositive.toInt();
  var bMax = double.minPositive.toInt();

  for(final pixel in rgbValues) {
    rMin = rMin < pixel['r']! ? rMin : pixel['r']!;
    gMin = gMin < pixel['g']! ? gMin : pixel['g']!;
    bMin = bMin < pixel['b']! ? bMin : pixel['b']!;

    rMax = rMax > pixel['r']! ? rMax : pixel['r']!;
    gMax = gMax > pixel['g']! ? gMax : pixel['g']!;
    bMax = bMax > pixel['b']! ? bMax : pixel['b']!;
  }

  final rRange = rMax - rMin;
  final gRange = gMax - gMin;
  final bRange = bMax - bMin;

  final range = [rRange, gRange, bRange].reduce((a, b) => a > b ? a : b);

  if(range == rRange) return 'r';
  if(range == gRange) return 'g';
  return 'b';
}