/// Used to control the enlargement behavior of the emojis in the
///
enum EmojiEnlargementBehavior {
  /// The emojis will be enlarged only if the consists of
  /// one or more emojis.
  multi,

  /// Never enlarge emojis.
  never,

  /// The emoji will be enlarged only if the consists of
  /// a single emoji.
  single,
}
