

class LocalStore{
  LocalStore._();

  static final LocalStore instance = LocalStore._();

  factory LocalStore(){
    return instance;
  }
}