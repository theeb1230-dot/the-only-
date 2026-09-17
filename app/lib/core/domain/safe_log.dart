String safeUriForLog(Uri uri) => uri.replace(query: null, fragment: null).toString();
