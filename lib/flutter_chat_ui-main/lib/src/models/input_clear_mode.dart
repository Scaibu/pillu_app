/// Used to set  clear mode when message is sent.
enum InputClearMode {
  /// Always clear  regardless if message is sent or not.
  always,

  /// Never clear . You should do it manually, depending on your use case.
  /// To clear the input manually, use  (see
  /// docs how to use it properly, but TL;DR set it to
  /// imported from the library, to not lose any functionalily).
  never,
}
