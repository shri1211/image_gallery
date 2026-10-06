abstract final class Formatters {
  Formatters._();

  static String compactNumber(num value) {
    if (value >= 1000000) {
      return '${_trim(value / 1000000)}M';
    }
    if (value >= 1000) {
      return '${_trim(value / 1000)}K';
    }
    return value.toString();
  }

  static String _trim(double value) {
    final String text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  static String titleCase(String input) {
    if (input.isEmpty) return input;
    final String value = input.trim();
    return value
        .split(' ')
        .map(
          (String word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
