import '../security/url_policy.dart';
import 'models.dart';

class StreamValidator {
  const StreamValidator(this.policy);
  final UrlPolicy policy;

  bool isValid(StreamSource source) {
    if (source.providerId.trim().isEmpty) return false;
    if (!policy.allows(source.uri)) return false;
    return source.uri.host.isNotEmpty;
  }
}
