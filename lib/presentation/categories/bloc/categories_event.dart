abstract class CategoriesEvent {}

class LoadCategories extends CategoriesEvent {}

class SelectCategory extends CategoriesEvent {
  final String category;

  SelectCategory(this.category);
}