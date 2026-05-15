import 'base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  String _title = 'Welcome to Tailor App';

  String get title => _title;

  void updateTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }
}