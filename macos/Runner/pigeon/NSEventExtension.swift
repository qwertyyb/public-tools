import HotKey

extension NSEvent {
  public func pluginModifiers() -> [String] {
    var modifiers: [String] = []
    if (self.modifierFlags.contains(.capsLock)) {
      modifiers.append("capsLock");
    }
    if (self.modifierFlags.contains(.shift)) {
      modifiers.append("shift");
    }
    if (self.modifierFlags.contains(.control)) {
      modifiers.append("control");
    }
    if (self.modifierFlags.contains(.option)) {
      modifiers.append("alt");
    }
    if (self.modifierFlags.contains(.command)) {
      modifiers.append("meta");
    }
    if (self.modifierFlags.contains(.function)) {
      modifiers.append("fn");
    }
    return []
  }
}
