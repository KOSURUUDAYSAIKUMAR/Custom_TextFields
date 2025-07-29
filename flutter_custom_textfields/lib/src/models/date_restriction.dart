/// Enum for date restriction types
enum DateRestriction {
  /// No restrictions
  none,

  /// Only past dates allowed
  pastOnly,

  /// Only current date allowed
  currentOnly,

  /// Only future dates allowed
  futureOnly,

  /// Past and current dates allowed
  pastAndCurrent,

  /// Current and future dates allowed
  currentAndFuture,
}
