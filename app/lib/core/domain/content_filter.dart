class ContentVisibilityPolicy {
  const ContentVisibilityPolicy({required this.optionalSectionEnabled});
  final bool optionalSectionEnabled;

  bool allows({required bool optionalContent}) => !optionalContent || optionalSectionEnabled;
}
