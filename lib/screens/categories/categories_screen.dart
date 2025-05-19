import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../frameworks/wordpress/presentation/widgets/category_layout/side_menu.dart';
import '../../frameworks/wordpress/presentation/widgets/category_layout/sub.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Category, CategoryModel;
import '../../widgets/cardlist/index.dart';
import '../chat/smartchat.dart';
import 'layouts/card.dart';
import 'layouts/column.dart';
import 'layouts/grid.dart';
import 'layouts/side_menu_with_sub.dart';

class CategoriesScreen extends StatefulWidget {
  final String? layout;
  final bool? showChat;
  final bool? showSearch;
  var enableParallax;
  var parallaxImageRatio;

  CategoriesScreen({
    Key? key,
    this.layout,
    this.showChat,
    this.showSearch = true,
    this.enableParallax,
    this.parallaxImageRatio,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  FocusNode? _focus;
  bool isVisibleSearch = false;
  String? searchText;
  var textController = TextEditingController();

  Animation<double>? animation;
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller!);
    animation?.addListener(() {
      setState(() {});
    });

    _focus = FocusNode();
    _focus?.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus!.hasFocus && animation?.value == 0) {
      controller?.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context);
    final showChat = widget.showChat ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: showChat
          ? SmartChat(
              margin: EdgeInsets.only(
                right: Provider.of<AppModel>(context, listen: false).langCode ==
                        'ar'
                    ? 30.0
                    : 0.0,
              ),
            )
          : Container(),
      body: ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return kLoadingWidget(context);
            }

            if (value.categories == null) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(S.of(context).dataEmpty),
              );
            }

            var categories = value.categories;

            return SafeArea(
              bottom: false,
              child: [
                GridCategory.type,
                ColumnCategories.type,
                SideMenuCategories.type,
                SubCategories.type,
                SideMenuSubCategories.type
              ].contains(widget.layout)
                  ? Column(
                      children: <Widget>[
                        renderHeader(),
                        Expanded(
                          child: renderCategories(categories ?? []),
                        )
                      ],
                    )
                  : ListView(
                      children: <Widget>[
                        renderHeader(),
                        renderCategories(categories ?? [])
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget renderHeader() {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, bottom: 20, right: 10),
                child: Text(
                  S.of(context).category,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (widget.showSearch == true)
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteList.categorySearch);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderCategories(List<Category> categories) {
    switch (widget.layout) {
      case CardCategories.type:
        return CardCategories(
          categories: categories,
        );
      case ColumnCategories.type:
        return ColumnCategories(
          categories: categories,
        );
      case SubCategories.type:
        return SubCategories(
          categories: categories,
        );
      case SideMenuCategories.type:
        return SideMenuCategories(
          categories: categories,
        );
      case SideMenuSubCategories.type:
        return SideMenuSubCategories(
          categories: categories,
        );
      case HorizonMenu.type:
        return HorizonMenu(
          categories: categories,
        );
      case GridCategory.type:
        return GridCategory(
          categories: categories,
        );
      default:
        return HorizonMenu(
          categories: categories,
        );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
