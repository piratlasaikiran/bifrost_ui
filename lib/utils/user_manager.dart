class UserManager {
  static final UserManager _instance = UserManager._internal();

  late String username;

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();
}
