bool platformCheck(bool Function() block) {
  try {
    return block();
  } catch (e) {}
  return false;
}

bool platformCheckIsWeb() => platformCheck(() => true);
