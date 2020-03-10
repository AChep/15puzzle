bool platformCheck(bool Function() block) {
  try {
    return block();
  } catch (e) {}
  return false;
}
