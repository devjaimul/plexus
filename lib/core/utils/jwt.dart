import 'dart:convert';

/// User id from the token's sub claim, null if it doesn't parse.
int? jwtUserId(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;

  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final claims = jsonDecode(payload) as Map<String, dynamic>;
    final sub = claims['sub'];
    return sub is int ? sub : int.tryParse('$sub');
  } on FormatException {
    return null;
  }
}
