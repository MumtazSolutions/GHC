import 'package:flutter/material.dart';
import 'package:inspireui/widgets/expandable/expansion_widget.dart';
import 'package:provider/provider.dart';
import 'package:fstore/models/category/local_cat_model.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show BlogModel, Category, CategoryModel, ProductModel;
import '../../common/tree_view.dart';
import 'category_item.dart';

class CategoryMenu extends StatefulWidget {
  final Function(Category category) onFilter;
  final bool isUseBlog;

  const CategoryMenu({
    Key? key,
    required this.onFilter,
    this.isUseBlog = false,
  }) : super(key: key);

  @override
  State<CategoryMenu> createState() => _CategoryTreeState();
}

class _CategoryTreeState extends State<CategoryMenu> {
  CategoryModel get category => Provider.of<CategoryModel>(context);

  String? get categoryId => Provider.of<ProductModel>(context).categoryId;
  String _categoryId = '0';
  @override
  void initState() {
    _categoryId =
        Provider.of<ProductModel>(context, listen: false).categoryId.toString();
    if(localCategories?.isEmpty==true)
    {
      localCategories= List.from(Provider.of<CategoryModel>(context, listen: false).categories!.map((e) => LocalCatModel(name: e.name,id: e.id)).toList());
      localCategories!.removeWhere((element) => element.name == 'Hidden Items' || element.name == 'Salary Day');
    }
    localCategories?.forEach((element) {
      debugPrint("_____FILET:${element.name}");
    });
    super.initState();
  }

  bool? hasChildren(categories, id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category>? getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }

  void onTap(Category category) {
    final id = category.id.toString();
    if (id == _categoryId) {
      widget.onFilter(Category(id: kEmptyCategoryID, subCategories: []));
      setState(() => _categoryId = kEmptyCategoryID);
      return;
    }
    widget.onFilter(category);
    setState(() => _categoryId = id);
  }

  List<Widget> _getCategoryItems(
    List<Category> categories, {
    String? id,
    required Function onFilter,
    int level = 1,
  }) {
    return [
      for (var category in getSubCategories(categories, id)!) ...[
        Parent(
          parent: CategoryItem(
            category,
            hasChild: hasChildren(categories, category.id),
            isSelected: category.id == _categoryId,
            onTap: () => onTap(category),
            level: level,
          ),
          childList: ChildList(
            children: [
              if (hasChildren(categories, category.id)!)
                CategoryItem(
                  category,
                  isParent: true,
                  isSelected: category.id == _categoryId,
                  onTap: () => onTap(category),
                  level: level + 1,
                ),
              ..._getCategoryItems(
                categories,
                id: category.id,
                onFilter: widget.onFilter,
                level: level + 1,
              )
            ],
          ),
        )
      ],
    ];
  }

  Widget getTreeView({required List<Category> categories}) {

    final rootCategories =
        categories.where((item) => item.parent == '0').toList();
    rootCategories.removeWhere((element) => element.name == 'Hidden Items' || element.name == 'Salary Day');
    return TreeView(
      parentList:List.generate(rootCategories.length, (index) {
        var item=rootCategories[index];
        item.name=localCategories?.firstWhere((cat) =>  item.id==cat.id).name;
        return  Parent(
          parent: CategoryItem(
            item,
            hasChild: hasChildren(categories, item.id),
            isSelected: item.id == categoryId,
            onTap: () => onTap(item),
          ),
          childList: ChildList(
            children: [
              if (hasChildren(categories, item.id)!)
                CategoryItem(
                  item,
                  isParent: true,
                  isSelected: item.id == categoryId,
                  onTap: () => onTap(item),
                  level: 2,
                ),
              ..._getCategoryItems(
                categories,
                id: item.id,
                onFilter: widget.onFilter,
                level: 2,
              )
            ],
          ),
        );
      })
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionWidget(
      showDivider: true,
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
        bottom: 5,
      ),
      title: Text(
        S.of(context).byCategory,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: widget.isUseBlog
              ? Selector<BlogModel, List<Category>>(
                  builder: (context, categories, child) {
                    return getTreeView(
                      categories: categories,
                    );
                  },
                  selector: (_, model) => model.categories,
                )
              : Selector<CategoryModel, List<Category>>(
                  builder: (context, categories, child) => getTreeView(
                    categories: categories,
                  ),
                  selector: (_, model) => model.categories ?? [],
                ),
        ),
      ],
    );
  }
}
