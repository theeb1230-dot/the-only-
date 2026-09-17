final RegExp _providerIdPattern = RegExp(r'^[a-z0-9][a-z0-9_-]{1,63}$');

bool isValidProviderId(String value) => _providerIdPattern.hasMatch(value);
