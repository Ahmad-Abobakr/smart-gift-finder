import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// يُطلق عند فتح الشاشة الرئيسية لأول مرة (تحميل المنتجات + الفئات)
class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

/// يُطلق عند كتابة المستخدم في شريط البحث
class SearchProducts extends HomeEvent {
  final String query;
  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}
