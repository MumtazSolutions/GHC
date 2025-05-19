import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../models/index.dart';
import '../../services/services.dart';
import '../common/expand_image.dart';
import 'categories_model.dart';
import 'chat_screen.dart';
import 'community_provider.dart';
import 'expert_profileScreen.dart';
import 'internal_user_post_screen.dart';
import 'post_screen.dart';
import 'user_profileScreen.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  var topics = <Topics>[];
  bool isLoading = false;
  bool isFirstTime = false;
  bool hasNextPage = true;
  var product;
  var categories;
  late int selectedIndex;
  late var questionData;
  final PagingController<int, Topics> _pagingController =
      PagingController(firstPageKey: 1);

  void _refreshData() {
    _pagingController.refresh();
  }

  Future<void> _loadMore(
      int pageKey, int categoryId, CommunityProvider vm) async {
    if (kDebugMode) {
      print(categoryId);
    }
    try {
      final newItems = await vm.fetchQuestion(page: pageKey);
      hasNextPage = newItems.pagination?.next?.active as bool;
      if (hasNextPage == false) {
        _pagingController.appendLastPage(newItems.topics as List<Topics>);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems.topics!, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    var user = Provider.of<UserModel>(context, listen: false).user;
    _pagingController.addPageRequestListener((pageKey) {
      _loadMore(pageKey, selectedIndex, communityVm);
    });

    communityVm.isinitialLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      categories = await communityVm.fetchCategories();
      await communityVm.getSignIn(id: user?.id ?? '');
      await communityVm.getFollowing(userName: communityVm.userSlug);
      if (kDebugMode) {
        print('From initstate');
      }
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var communityVm = Provider.of<CommunityProvider>(context, listen: true);
    var user = Provider.of<UserModel>(context, listen: false).user;
    var data = categories?['categories'];
    if (kDebugMode) {
      print('Build Triggered');
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffD8F1E9),
        body: data != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    communityVm.aboutMe != 'Internal'
                                        ? Get.to(UserProfileScreen(
                                            userSlug: communityVm.userSlug))
                                        : Get.to(ExpertProfileScreen(
                                            userSlug: communityVm.userSlug,
                                            uid: communityVm.userId,
                                          ));
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: const Offset(0,
                                              1), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xffD8F1E9)),
                                      child: Center(
                                        child: Text(
                                          user?.fullName
                                                  .split('')[0]
                                                  .toUpperCase() ??
                                              '',
                                          style: const TextStyle(
                                              fontFamily: 'Roboto',
                                              color: Color(0xff4AA588),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  user?.firstName ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                communityVm.aboutMe != 'Internal'
                                    ? Get.to(() => const AskQuestionScreen())?.then((_) {
                                      // This callback will be called when coming back to this screen
                                      _refreshData();
                                    })
                                    : Get.to(() => const InternalUserAskQuestionScreen())?.then((_) {
                                      // This callback will be called when coming back to this screen
                                      _refreshData();
                                    });
                              },
                              child: Container(
                                height: 34,
                                width: 113,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color(0xff333333)),
                                child: const Text(
                                  'Ask a question ',
                                  style: TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontFamily: 'Roboto',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              data.length ?? 0,
                              (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    // _pagingController
                                    //     .addPageRequestListener((pageKey) {
                                    //   _loadMore(pageKey, selectedIndex, communityVm);
                                    // });
                                    if (kDebugMode) {
                                      print(data[index]['name']);
                                    }
                                  });
                                },
                                child: Container(
                                  height: 37,
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 6),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: selectedIndex == index
                                          ? const Color(0xffD8F1E9)
                                          : const Color(0xffF1F2F2)),
                                  child: data[index]['name'] != 'All'
                                      ? Row(
                                          children: [
                                            Image.network(
                                              data[index]['icon'],
                                              height: 29,
                                              width: 29,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return const Icon(Icons.error);
                                              },
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              data[index]['name'],
                                              style: const TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff000000)),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0, right: 20.0),
                                              child: Text(
                                                data[index]['name'],
                                                style: const TextStyle(
                                                    fontFamily: 'Roboto',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff000000)),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'COMMUNITY',
                          style: TextStyle(
                              color: Color(0xff333333),
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RouteList.support);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0XFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.headset_mic_outlined,
                                color: Colors.black54,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Customer Support',
                                style: TextStyle(color: Color(0XFF4E8170)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: RefreshIndicator(
                        onRefresh: () => Future.sync(
                          _pagingController.refresh,
                        ),
                        child: PagedListView(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate(
                            itemBuilder: (context, item, index) {
                              var question = item as Topics;
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) async {
                                if (question.tags?.first.value == 'product' &&
                                    isFirstTime == false) {
                                  var productId =
                                      'gid://shopify/Product/${question.title?.split('-').last.toString() ?? ''}';
                                  var productID =
                                      base64.encode(utf8.encode(productId));
                                  product = await Services()
                                      .api
                                      .getProduct(productID);
                                  isFirstTime = true;
                                  var bytes =
                                      utf8.encode(product?.categoryId ?? '');
                                  var base64Str = base64.encode(bytes);
                                  product?.categoryId = base64Str;

                                  await Future.delayed(Duration.zero)
                                      .then((value) {
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  });
                                }
                              });
                              if (selectedIndex == 0) {
                                if (question.tags?.last.value == 'internal') {
                                  return ExpertPostUi(
                                      communityVm: communityVm,
                                      product: product,
                                      question: question);
                                } else {
                                  return UserTopicUi(question: question);
                                }
                              } else {
                                if (question.category?.name ==
                                    data[selectedIndex]['name']) {
                                  if (question.tags?.last.value == 'internal') {
                                    return ExpertPostUi(
                                        communityVm: communityVm,
                                        product: product,
                                        question: question);
                                  } else {
                                    return UserTopicUi(question: question);
                                  }
                                } else {
                                  return const SizedBox();
                                }
                              }
                            },
                            firstPageProgressIndicatorBuilder: ((context) =>
                                Center(
                                  child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade600,
                                    ),
                                  ),
                                )),
                            newPageProgressIndicatorBuilder: ((context) =>
                                Center(
                                  child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade600,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.grey.shade700),
                ),
              ),
      ),
    );
  }
}

class UserTopicUi extends StatelessWidget {
  final question;
  const UserTopicUi({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    var content = question.titleRaw;
    var category = question.category;
    var topicType = question.tags!.first.value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset:
                          const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xffD8F1E9)),
                  child: Center(
                    child: Text(
                      question.user?.username?.split('')[0].toUpperCase() ??
                          '',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xff4AA588),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() =>
                    CommentScreen(
                      internalUser: false,
                      topic: question,
                    ),
                  );
                },
                child: question.tags?.last.value == 'notanonymous'
                    ? Text(
                        question.user?.username?.split(' ')[0] ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300),
                      )
                    : const Text(
                        'Anonymous',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300),
                      ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xffD8F1E9),
                ),
                child: Text(
                  category?.name ?? '',
                  style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: Color(0xff333333)),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(0xffEDEDED),
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          topicType == 'questionwithima'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() =>
                                  CommentScreen(
                                    internalUser: false,
                                    topic: question,
                                  ),
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Text(
                                    content?.split('||').first.toString() ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ),
                            ),
                            content!.split('||').first.toString().length > 100
                                ? GestureDetector(
                                    onTap: () {
                                      Get.to(() => CommentScreen(
                                        internalUser: false,
                                        topic: question,
                                      ));
                                    },
                                    child: const Text(
                                      '...Read More',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, bottom: 8.0, right: 15.0),
                      child: GestureDetector(
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (_) => ImageDialog(
                                    path:
                                        content?.split('||').last.toString() ??
                                            '',
                                  ));
                        },
                        child: Image.network(
                          content?.split('||').last.toString() ?? '',
                          height: 63,
                          width: 63,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => CommentScreen(
                                  internalUser: false,
                                  topic: question,
                                ));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Text(
                                    content ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ),
                            ),
                            content!.length > 100
                                ? GestureDetector(
                                    onTap: () {
                                      Get.to(() => CommentScreen(
                                        internalUser: false,
                                        topic: question,
                                      ));
                                    },
                                    child: const Text(
                                      '...Read More',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                      ),
                      // question.titleRaw!
                      //             .length >
                      //         200
                      //     ? GestureDetector(
                      //         onTap:
                      //             () {
                      //           Get.to(
                      //               CommentScreen(
                      //             internalUser:
                      //                 false,
                      //             topic:
                      //                 question ?? Topics(),
                      //           ));
                      //         },
                      //         child:
                      //             const Text(
                      //           'Read More',
                      //           style: TextStyle(
                      //               fontSize: 12,
                      //               fontWeight: FontWeight.bold),
                      //         ),
                      //       )
                      //     : const SizedBox
                      //         .shrink()
                    ],
                  ),
                ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(0xffEDEDED),
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => CommentScreen(
                internalUser: false,
                topic: question,
              ));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 2.0),
                  child: Icon(
                    Icons.message,
                    color: Color(0xff777777),
                    size: 12,
                  ),
                ),
                Text(
                  '${(int.parse(question.postcount.toString()) - 1).toString()} Answer',
                  style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xff777777),
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ExpertPostUi extends StatelessWidget {
  final CommunityProvider communityVm;
  final Topics question;
  final product;
  const ExpertPostUi(
      {super.key,
      required this.communityVm,
      this.product,
      required this.question});

  @override
  Widget build(BuildContext context) {
    var topicType = question.tags!.first.value;
    var category = question.category!.name;
    var content = question.titleRaw;
    var user = question.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 20),
      padding: const EdgeInsets.only(top: 5, left: 12, right: 10, bottom: 12),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 3), // changes position of shadow
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
        child: Column(
          children: [
            Row(children: [
              GestureDetector(
                onTap: () {
                  Get.to(() =>
                    ExpertProfileScreen(
                        userSlug: user?.userslug ?? '', uid: user?.uid ?? ''),
                  );
                },
                child: Container(
                  height: 50,
                  width: 50,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xffD8F1E9)),
                    child: Center(
                      child: Text(
                        user?.displayname?[0].toString() ?? '',
                        style: const TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xff4AA588),
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username?.split(' ')[0] ?? '',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w300),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Wellness Expert',
                            style: TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xffD8F1E9),
                ),
                child: Text(
                  category ?? '',
                  style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: Color(0xff333333)),
                ),
              ),
              const Spacer(),
              communityVm.aboutMe == 'Internal'
                  ? const SizedBox()
                  : communityVm.getFollowingModel.users?.any((element) =>
                              element.uid.toString() ==
                              user?.uid?.toString()) ==
                          true
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text(
                            'Following',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () async {
                            await communityVm
                                .followUser(
                                    uId: int.parse(user?.uid.toString() ?? ''))
                                .then((value) async {
                              await communityVm.getFollowing(
                                  userName: communityVm.userSlug);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.add,
                                  size: 15,
                                ),
                                Text(
                                  'Follow',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ]),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              thickness: 1,
            ),
            const SizedBox(
              height: 5,
            ),
            topicType == 'blog'
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => CommentScreen(
                              internalUser: true,
                              topic: question,
                            ));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                                content?.split('||').last ?? '',
                                height: 200,
                                width: Get.width,
                                fit: BoxFit.cover),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content
                                          ?.split('||')
                                          .first
                                          .split('-')[0]
                                          .toString() ??
                                      '',
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                      color: Color(0xff333333),
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Get.to(() =>
                                            CommentScreen(
                                              internalUser: true,
                                              topic: question,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          content
                                                  ?.split('||')
                                                  .first
                                                  .split('-')[1]
                                                  .toString() ??
                                              '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.justify,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    if ((content
                                                ?.split('||')
                                                .first
                                                .split('-')[1]
                                                .toString()
                                                .length ??
                                            0) >
                                        100)
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() =>
                                            CommentScreen(
                                              internalUser: true,
                                              topic: question,
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Read More',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                      ),
                                    const SizedBox(width: 30),
                                    Text(
                                      DateFormat('dd MMM yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(
                                              question.timestamp.toString()),
                                        ),
                                      ),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  )
                : topicType == 'product'
                    ? Container(
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(4, 4),
                                blurRadius: 10,
                              )
                            ]),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => CommentScreen(
                              internalUser: true,
                              topic: question,
                              product: product ?? Product(),
                            ));
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    child: Image.network(
                                      product.imageFeature ?? '',
                                      scale: 4,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 100,
                                  decoration: const BoxDecoration(
                                      color: Color(0xffD8F1E9),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      )),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        const Text(
                                          'RECOMMENDED',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff4AA588),
                                            fontSize: 10,
                                          ),
                                        ),
                                        SizedBox(
                                          width: Get.width * .4,
                                          child: Text(
                                            product.name ?? '',
                                            style: const TextStyle(
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons.star,
                                                  color: Color(0xff4AA588),
                                                  size: 12,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: Color(0xff4AA588),
                                                  size: 12,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: Color(0xff4AA588),
                                                  size: 12,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  color: Color(0xff4AA588),
                                                  size: 12,
                                                ),
                                                Icon(
                                                  Icons.star_half,
                                                  color: Color(0xff4AA588),
                                                  size: 12,
                                                ),
                                              ],
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 4.0),
                                              child: Text(
                                                '(41 Reviews)',
                                                style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    color: Color(0xff000000),
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              product.salePrice ?? '',
                                              style: const TextStyle(
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff4AA588),
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: Get.width * .02,
                                            ),
                                            Text(
                                              product.regularPrice ?? '',
                                              style: const TextStyle(
                                                  color: Color(0xff000000),
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 10,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : topicType == 'questionwithima'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() =>
                                            CommentScreen(
                                              internalUser: false,
                                              topic: question,
                                            ),
                                          );
                                        },
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            content
                                                    ?.split('||')
                                                    .first
                                                    .toString() ??
                                                '',
                                            textAlign: TextAlign.justify,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                      ),
                                      content!
                                                  .split('||')
                                                  .first
                                                  .toString()
                                                  .length >
                                              200
                                          ? GestureDetector(
                                              onTap: () {
                                                Get.to(() => CommentScreen(
                                                  internalUser: false,
                                                  topic: question,
                                                ));
                                              },
                                              child: const Text(
                                                'Read More',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : const SizedBox.shrink()
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (_) => ImageDialog(
                                      path: content.split('||').last.toString(),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  content.split('||').last.toString(),
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => CommentScreen(
                                            internalUser: true,
                                            topic: question,
                                          ));
                                        },
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            content ?? '',
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.justify,
                                            style: const TextStyle(
                                                fontFamily: 'Roboto',
                                                color: Color(0xff333333),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ),
                                      content!.length > 100
                                          ? GestureDetector(
                                              onTap: () {
                                                Get.to(()=> CommentScreen(
                                                  internalUser: true,
                                                  topic: question,
                                                ));
                                              },
                                              child: const Text(
                                                'Read More',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : const SizedBox.shrink()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
            const SizedBox(
              height: 15,
            ),
            const Divider(
              thickness: 1,
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await Share.share(content?.split('-')[1].toString() ?? '',
                        subject: 'Question');
                  },
                  child: const Icon(
                    Icons.share,
                    size: 12,
                    color: Color(0xff777777),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () async {
                    await Share.share(
                        content?.split('||').first.toString() ?? '',
                        subject: 'Question');
                  },
                  child: const Text(
                    'Share',
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xff777777),
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                const Spacer(),
                // GestureDetector(
                //   onTap:
                //       () async {
                //     await communityVm.postVote(
                //         id: int.parse(question.mainPid.toString() ??
                //             '0'));
                //   },
                //   child:
                //       const Icon(
                //     Icons
                //         .favorite_border,
                //     size: 12,
                //     color: Color(
                //         0xff777777),
                //   ),
                // ),
                // const SizedBox(
                //   width: 10,
                // ),
                // Text(
                //   question.upvotes
                //           .toString() ??
                //       '',
                //   style:
                //       const TextStyle(
                //     fontFamily:
                //         'Roboto',
                //     fontSize:
                //         12,
                //     color: Color(
                //         0xff333333),
                //     fontWeight:
                //         FontWeight
                //             .w600,
                //   ),
                // ),
                // const SizedBox(
                //   width: 5,
                // ),
                // const Text(
                //   'Found it useful',
                //   style: TextStyle(
                //       fontFamily:
                //           'Roboto',
                //       color: Color(
                //           0xff777777),
                //       fontSize:
                //           12,
                //       fontWeight:
                //           FontWeight
                //               .w400),
                // ),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(()=>
                      CommentScreen(
                        internalUser: false,
                        topic: question,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 2.0),
                        child: Icon(
                          Icons.message,
                          size: 10,
                          color: Color(0xff777777),
                        ),
                      ),
                      Text(
                        (int.parse(question.postcount.toString()) - 1)
                            .toString(),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Color(0xff333333),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Comments',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xff777777),
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


class ScreenAController extends GetxController {
  // Method to make the API call
  Future<CategoriesModel> makeApiCall() async {
    // Your API call logic goes here
    try {
      var questionModel = CategoriesModel();
      var url =
          Uri.parse('${Configurations.baseUrl}/api/recent?lang=en-GB&page=1');

      var response = await http.get(url);
      questionModel = CategoriesModel.fromJson(jsonDecode(response.body));
      return questionModel;
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  @override
  void onClose() {
    // Call makeApiCall when Screen B is popped
    makeApiCall();
    super.onClose();
  }
}