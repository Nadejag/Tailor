import 'base_viewmodel.dart';
import '../models/user_model.dart';

class AuthViewModel extends BaseViewModel {
  User? _currentUser;
  String _errorMessage = '';
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    setBusy(true);
    try {
      // Simulating API call
      await Future.delayed(Duration(seconds: 2));

      _currentUser = User(
        id: '1',
        name: 'John Doe',
        email: email,
        password: password,
        role: 'customer',
      );
      _isLoggedIn = true;
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    setBusy(true);
    try {
      // Simulating API call
      await Future.delayed(Duration(seconds: 2));

      _currentUser = User(
        id: '1',
        name: name,
        email: email,
        password: password,
        role: 'customer',
      );
      _isLoggedIn = true;
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
