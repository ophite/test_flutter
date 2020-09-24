import 'package:flutter/cupertino.dart';
import 'package:my_first_flutter_1/screens/placePicker/others/autocomplete_search.dart';

class SearchBarController extends ChangeNotifier {
  AutoCompleteSearchState _autoCompleteSearch;

  attach(AutoCompleteSearchState searchWidget) {
    _autoCompleteSearch = searchWidget;
  }

  /// Just clears text.
  clear() {
    _autoCompleteSearch.clearText();
  }

  /// Clear and remove focus (Dismiss keyboard)
  reset() {
    _autoCompleteSearch.resetSearchBar();
  }

  clearOverlay() {
    _autoCompleteSearch.clearOverlay();
  }
}
