abstract class SearchEvent {}

class SearchRequested extends SearchEvent {
  final String query;

  SearchRequested(this.query);
}