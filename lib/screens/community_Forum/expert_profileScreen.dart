import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../models/entities/product.dart';
import '../../models/user_model.dart';
import '../../services/services.dart';
import 'categories_model.dart' as cat;
import 'chat_screen.dart';
import 'community_provider.dart';
import 'user_topics_model.dart';

class ExpertProfileScreen extends StatefulWidget {
  final String userSlug;
  final uid;
  const ExpertProfileScreen(
      {Key? key, required this.userSlug, required this.uid})
      : super(key: key);

  @override
  State<ExpertProfileScreen> createState() => _ExpertProfileScreenState();
}

class _ExpertProfileScreenState extends State<ExpertProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  bool isLoading = false;
  var product;

  bool isFirstTime = false;
  var topics = <cat.Topics>[];

  @override
  void initState() {
    controller = TabController(length: 5, vsync: this);
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    var user = Provider.of<UserModel>(context, listen: false).user;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isLoading = true;
      communityVm.notifyListeners();
      await communityVm
          .getProfile(id: int.parse(widget.uid.toString()))
          .then((value) {
        isLoading = false;
        communityVm.notifyListeners();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserModel>(context, listen: false).user;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffD8F1E9),
        body:
            Consumer<CommunityProvider>(builder: (context, communityVm, child) {
          return isLoading == false
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white,
                      padding:
                          const EdgeInsets.only(top: 12, left: 12, right: 12),
                      height: Get.height * 0.25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: Get.back,
                                icon: const Icon(Icons.arrow_back_ios_sharp),
                              ),
                              const Text(' Profile')
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(children: [
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
                                    offset: const Offset(
                                        0, 1), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffD8F1E9)),
                                child: Center(
                                    child: Text(
                                  user?.firstName?.split('')[0].toUpperCase() ??
                                      '',
                                  style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      color: Color(0xff4AA588),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      user?.firstName?.split(' ')[0] ?? '',
                                      style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Color(0xff333333),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      'Wellness Expert',
                                      style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Color(0xff777777),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 15,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                communityVm.getProfileModel.lastonline != null
                                    ? Text(
                                        'Last active ${formatTimeAgo(int.parse(communityVm.getProfileModel.lastonline.toString()))}',
                                        style: const TextStyle(
                                            color: Color(0xff777777),
                                            fontFamily: 'Roboto',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400),
                                      )
                                    : const Text(
                                        'Last active few seconds ago',
                                        style: TextStyle(
                                            color: Color(0xff777777),
                                            fontFamily: 'Roboto',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400),
                                      ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xff4AA588))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Followers',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff777777)),
                                  ),
                                  Text(
                                    communityVm.getProfileModel.followerCount
                                        .toString(),
                                    style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff333333)),
                                  ),
                                ],
                              ),
                            )
                          ]),
                          const Spacer(
                            flex: 2,
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(top: 2),
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        controller?.animateTo(0);
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'All',
                                              style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff333333)),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 1.7),
                                                height: 3,
                                                width: 50,
                                                color: controller?.index == 0
                                                    ? const Color(0xff4AA588)
                                                    : Colors.transparent,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        controller?.animateTo(1);
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Questions',
                                              style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff333333)),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.only(top: 1.7),
                                                height: 3,
                                                width: 90,
                                                color: controller?.index == 1
                                                    ? const Color(0xff4AA588)
                                                    : Colors.transparent,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        controller?.animateTo(2);
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Question & Image',
                                              style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff333333)),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 1.7),
                                                height: 3,
                                                width: 170,
                                                color: controller?.index == 2
                                                    ? const Color(0xff4AA588)
                                                    : Colors.transparent,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        controller?.animateTo(3);
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Product',
                                              style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff333333)),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.only(top: 1.7),
                                                height: 3,
                                                width: 80,
                                                color: controller?.index == 3
                                                    ? const Color(0xff4AA588)
                                                    : Colors.transparent,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        controller?.animateTo(4);
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'Blogs',
                                              style: TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff333333)),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.only(top: 1.7),
                                                height: 3,
                                                width: 60,
                                                color: controller?.index == 4
                                                    ? const Color(0xff4AA588)
                                                    : Colors.transparent,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: controller,
                          children: [
                            Tab(
                                child: Column(
                              children: [
                                Expanded(
                                  child: FutureBuilder<UserTopicsModel>(
                                      future: communityVm.getUserTopics(
                                          userName: widget.userSlug),
                                      builder: (context, snapshot) {
                                        var questionData =
                                            communityVm.userTopicsModel;
                                        print(
                                            'data in useropticModel ${communityVm.userTopicsModel.topics?.length ?? 0}');

                                        if (!snapshot.hasData) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else {
                                          var userTopics = snapshot.data;

                                          return SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                ListView.builder(
                                                    padding:
                                                        const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 16,
                                                            vertical: 5),
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        controller?.index == 0
                                                            ? questionData
                                                                    .topics
                                                                    ?.length ??
                                                                0
                                                            : topics.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      print(
                                                          'this is in my tags ${questionData.topics?[index].tags?.last.value}}');
                                                      cat.Topics question;
                                                      if (controller?.index ==
                                                          0) {
                                                        question = questionData
                                                            .topics![index];
                                                      } else {
                                                        question =
                                                            topics[index];
                                                      }
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (timeStamp) async {
                                                        if (question.tags?.first
                                                                    .value ==
                                                                'product' &&
                                                            isFirstTime ==
                                                                false) {
                                                          var productId =
                                                              'gid://shopify/Product/${question.titleRaw?.split('-').last.toString() ?? ''}';
                                                          print(
                                                              'this is our product id ${base64.encode(utf8.encode(productId))}');
                                                          var productID = base64
                                                              .encode(utf8.encode(
                                                                  productId));
                                                          product =
                                                              await Services()
                                                                  .api
                                                                  .getProduct(
                                                                      productID);
                                                          isFirstTime = true;
                                                          var bytes = utf8
                                                              .encode(product
                                                                      ?.categoryId ??
                                                                  '');
                                                          var base64Str = base64
                                                              .encode(bytes);
                                                          product?.categoryId =
                                                              base64Str;

                                                          await Future.delayed(
                                                                  Duration.zero)
                                                              .then((value) {
                                                            if (mounted) {
                                                              setState(() {});
                                                            }
                                                          });
                                                          // onTapProduct(context, product: product!);
                                                        }
                                                      });
                                                      print(
                                                          'tags value ${question.tags?.first.value ?? ''} ');
                                                      return question
                                                                  .tags
                                                                  ?.first
                                                                  .value ==
                                                              'blog'
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets.only(
                                                                      bottom: 8,
                                                                      top: 20),
                                                              padding: const EdgeInsets.only(
                                                                  top: 5,
                                                                  left: 12,
                                                                  right: 10,
                                                                  bottom: 12),
                                                              decoration: BoxDecoration(
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                      spreadRadius:
                                                                          1,
                                                                      blurRadius:
                                                                          2,
                                                                      offset: const Offset(
                                                                          0,
                                                                          3), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          20)),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 12,
                                                                        left:
                                                                            12,
                                                                        right:
                                                                            12),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                        children: [
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              Get.to(ExpertProfileScreen(
                                                                                userSlug: question.user?.userslug ?? '',
                                                                                uid: '',
                                                                              ));
                                                                            },
                                                                            child:
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
                                                                                    offset: const Offset(0, 1), // changes position of shadow
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Container(
                                                                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffD8F1E9)),
                                                                                child: Center(
                                                                                    child: Text(
                                                                                  user?.fullName.split('')[0].toUpperCase() ?? '',
                                                                                  style: const TextStyle(fontFamily: 'Roboto', color: Color(0xff4AA588), fontSize: 16, fontWeight: FontWeight.w500),
                                                                                )),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        question.user?.username?.split(' ')[0] ?? '',
                                                                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 5,
                                                                                      ),
                                                                                      const Text(
                                                                                        'Wellness Expert',
                                                                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w200),
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
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              color: const Color(0xffD8F1E9),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              question.category?.name ?? '',
                                                                              style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 10, color: Color(0xff333333)),
                                                                            ),
                                                                          ),
                                                                          const Spacer(),
                                                                          communityVm.aboutMe == 'Internal'
                                                                              ? const SizedBox()
                                                                              : communityVm.getFollowingModel.users!.any((element) => element.uid.toString() == question.user!.uid!.toString())
                                                                                  ? Container(
                                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                                        await communityVm.followUser(uId: int.parse(question.user?.uid.toString() ?? '0')).then((value) async {
                                                                                          await communityVm.getFollowing(userName: communityVm.userSlug);
                                                                                        });
                                                                                      },
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                        decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                      thickness:
                                                                          1,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          border:
                                                                              Border.all(color: Colors.grey.withOpacity(0.5)),
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                Get.to(CommentScreen(
                                                                                  internalUser: true,
                                                                                  topic: question,
                                                                                ));
                                                                              },
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                child: Image.network(question.titleRaw?.split('||').last ?? '', height: 200, width: Get.width, fit: BoxFit.cover),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                                                              child: Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      question.titleRaw?.split('||').first.split('-')[0].toString() ?? '',
                                                                                      textAlign: TextAlign.justify,
                                                                                      style: const TextStyle(color: Color(0xff333333), fontFamily: 'Roboto', fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.w500),
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
                                                                                              Get.to(
                                                                                                CommentScreen(
                                                                                                  internalUser: true,
                                                                                                  topic: question,
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                            child: Text(
                                                                                              question.titleRaw?.split('||').first.split('-')[1].toString() ?? '',
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              textAlign: TextAlign.justify,
                                                                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        const SizedBox(width: 5),
                                                                                        if ((question.titleRaw?.split('||').first.split('-')[1].toString().length ?? 0) > 100)
                                                                                          GestureDetector(
                                                                                            onTap: () {
                                                                                              Get.to(
                                                                                                CommentScreen(
                                                                                                  internalUser: true,
                                                                                                  topic: question,
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                            child: const Text(
                                                                                              'Read More',
                                                                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                                                                                            ),
                                                                                          ),
                                                                                        const SizedBox(width: 30),
                                                                                        Text(
                                                                                          DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(question.timestamp.toString()))),
                                                                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
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
                                                                        )),
                                                                    const SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    const Divider(
                                                                      thickness:
                                                                          1,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            await Share.share(question.titleRaw?.split('-')[1].toString() ?? '',
                                                                                subject: 'Question');
                                                                          },
                                                                          child:
                                                                              const Icon(
                                                                            Icons.share,
                                                                            size:
                                                                                10,
                                                                            color:
                                                                                Color(0xff777777),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            await Share.share(question.titleRaw!.split('||').first.toString(),
                                                                                subject: 'Question');
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            'Share',
                                                                            style: TextStyle(
                                                                                fontFamily: 'Roboto',
                                                                                color: Color(0xff777777),
                                                                                fontSize: 10,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                        const Spacer(),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            await communityVm.postVote(id: int.parse(question.mainPid.toString()));
                                                                          },
                                                                          child:
                                                                              const Icon(
                                                                            Icons.favorite_border,
                                                                            size:
                                                                                10,
                                                                            color:
                                                                                Color(0xff777777),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          question
                                                                              .upvotes
                                                                              .toString(),
                                                                          style:
                                                                              const TextStyle(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            fontSize:
                                                                                10,
                                                                            color:
                                                                                Color(0xff333333),
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        const Text(
                                                                          'Found it useful',
                                                                          style: TextStyle(
                                                                              fontFamily: 'Roboto',
                                                                              color: Color(0xff777777),
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              15,
                                                                        ),
                                                                        const Icon(
                                                                          Icons
                                                                              .message,
                                                                          size:
                                                                              10,
                                                                          color:
                                                                              Color(0xff777777),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          (int.parse(question.postcount.toString()) - 1)
                                                                              .toString(),
                                                                          style:
                                                                              const TextStyle(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            fontSize:
                                                                                10,
                                                                            color:
                                                                                Color(0xff333333),
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        const Text(
                                                                          'Comments',
                                                                          style: TextStyle(
                                                                              fontFamily: 'Roboto',
                                                                              color: Color(0xff777777),
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ))
                                                          : question.tags?.first
                                                                      .value ==
                                                                  'product'
                                                              ? Container(
                                                                  margin: const EdgeInsets.only(
                                                                      bottom: 8,
                                                                      top: 20),
                                                                  padding: const EdgeInsets.only(
                                                                      top: 5,
                                                                      left: 12,
                                                                      right: 10,
                                                                      bottom:
                                                                          12),
                                                                  decoration: BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                          spreadRadius:
                                                                              1,
                                                                          blurRadius:
                                                                              2,
                                                                          offset: const Offset(
                                                                              0,
                                                                              3), // changes position of shadow
                                                                        ),
                                                                      ],
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius: BorderRadius.circular(20)),
                                                                  child: Container(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 12,
                                                                        left:
                                                                            12,
                                                                        right:
                                                                            12),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                            children: [
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  Get.to(ExpertProfileScreen(
                                                                                    userSlug: question.user?.userslug ?? '',
                                                                                    uid: '',
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
                                                                                        offset: const Offset(0, 1), // changes position of shadow
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  child: Container(
                                                                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffD8F1E9)),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      question.user?.displayname![0].toString() ?? '',
                                                                                      style: const TextStyle(fontFamily: 'Roboto', color: Color(0xff4AA588), fontSize: 16, fontWeight: FontWeight.w500),
                                                                                    )),
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
                                                                                            question.user?.username?.split(' ')[0] ?? '',
                                                                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 5,
                                                                                          ),
                                                                                          const Text(
                                                                                            'Wellness Expert',
                                                                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w200),
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
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  color: const Color(0xffD8F1E9),
                                                                                ),
                                                                                child: Text(
                                                                                  question.category?.name ?? '',
                                                                                  style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 10, color: Color(0xff333333)),
                                                                                ),
                                                                              ),
                                                                              const Spacer(),
                                                                              communityVm.aboutMe == 'Internal'
                                                                                  ? const SizedBox()
                                                                                  : communityVm.getFollowingModel.users!.any((element) => element.uid.toString() == question.user!.uid!.toString())
                                                                                      ? Container(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                                            await communityVm.followUser(uId: int.parse(question.user?.uid.toString() ?? '0')).then((value) async {
                                                                                              await communityVm.getFollowing(userName: communityVm.userSlug);
                                                                                            });
                                                                                          },
                                                                                          child: Container(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                            decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        const Divider(
                                                                          thickness:
                                                                              1,
                                                                        ),
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Text(question.titleRaw?.split('-').first.toString() ?? ''),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              100,
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
                                                                          margin:
                                                                              const EdgeInsets.symmetric(vertical: 12),
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              Get.to(CommentScreen(
                                                                                internalUser: true,
                                                                                topic: question,
                                                                                product: product ?? Product(),
                                                                              ));
                                                                            },
                                                                            child:
                                                                                Row(
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
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                        children: [
                                                                                          const Text(
                                                                                            'RECOMENDED',
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
                                                                                                padding: EdgeInsets.only(left: 4.0),
                                                                                                child: Text(
                                                                                                  '(41 Reviews)',
                                                                                                  style: TextStyle(fontFamily: 'Roboto', color: Color(0xff000000), fontSize: 10, fontWeight: FontWeight.w400),
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
                                                                                                style: const TextStyle(color: Color(0xff000000), fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 10, decoration: TextDecoration.lineThrough),
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
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        const Divider(
                                                                          thickness:
                                                                              1,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () async {
                                                                                await Share.share(question.titleRaw?.split('-').first.toString() ?? '', subject: 'Question');
                                                                              },
                                                                              child: const Icon(
                                                                                Icons.share,
                                                                                size: 10,
                                                                                color: Color(0xff777777),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            GestureDetector(
                                                                              onTap: () async {
                                                                                await Share.share(question.titleRaw!.split('||').first.toString(), subject: 'Question');
                                                                              },
                                                                              child: const Text(
                                                                                'Share',
                                                                                style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                              ),
                                                                            ),
                                                                            const Spacer(),
                                                                            GestureDetector(
                                                                              onTap: () async {
                                                                                await communityVm.postVote(id: int.parse(question.mainPid.toString()));
                                                                              },
                                                                              child: const Icon(
                                                                                Icons.favorite_border,
                                                                                size: 10,
                                                                                color: Color(0xff777777),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              question.upvotes.toString(),
                                                                              style: const TextStyle(
                                                                                fontFamily: 'Roboto',
                                                                                fontSize: 10,
                                                                                color: Color(0xff333333),
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            const Text(
                                                                              'Found it useful',
                                                                              style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 15,
                                                                            ),
                                                                            const Icon(
                                                                              Icons.message,
                                                                              size: 10,
                                                                              color: Color(0xff777777),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Text(
                                                                              (int.parse(question.postcount.toString()) - 1).toString(),
                                                                              style: const TextStyle(
                                                                                fontFamily: 'Roboto',
                                                                                fontSize: 10,
                                                                                color: Color(0xff333333),
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            const Text(
                                                                              'Comments',
                                                                              style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ))
                                                              : question.tags?.first.value == 'questionwithima'
                                                                  ? Container(
                                                                      margin: const EdgeInsets.only(bottom: 8, top: 20),
                                                                      padding: const EdgeInsets.only(top: 5, left: 12, right: 10, bottom: 12),
                                                                      decoration: BoxDecoration(boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                          spreadRadius:
                                                                              1,
                                                                          blurRadius:
                                                                              2,
                                                                          offset: const Offset(
                                                                              0,
                                                                              3), // changes position of shadow
                                                                        ),
                                                                      ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                                                      child: Container(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12,
                                                                            left:
                                                                                12,
                                                                            right:
                                                                                12),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(children: [
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  Get.to(ExpertProfileScreen(
                                                                                    userSlug: question.user?.userslug ?? '',
                                                                                    uid: '',
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
                                                                                        offset: const Offset(0, 1), // changes position of shadow
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  child: Container(
                                                                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffD8F1E9)),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      question.user?.displayname![0].toString() ?? '',
                                                                                      style: const TextStyle(fontFamily: 'Roboto', color: Color(0xff4AA588), fontSize: 16, fontWeight: FontWeight.w500),
                                                                                    )),
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
                                                                                            question.user?.username?.split(' ')[0] ?? '',
                                                                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 5,
                                                                                          ),
                                                                                          const Text(
                                                                                            'Wellness Expert',
                                                                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w200),
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
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  color: const Color(0xffD8F1E9),
                                                                                ),
                                                                                child: Text(
                                                                                  question.category?.name ?? '',
                                                                                  style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 10, color: Color(0xff333333)),
                                                                                ),
                                                                              ),
                                                                              const Spacer(),
                                                                              communityVm.aboutMe == 'Internal'
                                                                                  ? const SizedBox()
                                                                                  : communityVm.getFollowingModel.users?.any((element) => element.uid.toString() == question.user?.uid?.toString()) == true
                                                                                      ? Container(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                                            await communityVm.followUser(uId: int.parse(question.user?.uid.toString() ?? '0')).then((value) async {
                                                                                              await communityVm.getFollowing(userName: communityVm.userSlug);
                                                                                            });
                                                                                          },
                                                                                          child: Container(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                            decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: SizedBox(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        GestureDetector(
                                                                                          onTap: () {
                                                                                            Get.to(
                                                                                              CommentScreen(
                                                                                                internalUser: false,
                                                                                                topic: question,
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                          child: Align(
                                                                                            alignment: Alignment.centerLeft,
                                                                                            child: Text(
                                                                                              question.titleRaw?.split('||').first.toString() ?? '',
                                                                                              textAlign: TextAlign.justify,
                                                                                              maxLines: 3,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        question.titleRaw!.split('||').first.toString().length > 200
                                                                                            ? GestureDetector(
                                                                                                onTap: () {
                                                                                                  Get.to(CommentScreen(
                                                                                                    internalUser: false,
                                                                                                    topic: question,
                                                                                                  ));
                                                                                                },
                                                                                                child: const Text(
                                                                                                  'Read More',
                                                                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                                                                                Image.network(
                                                                                  question.titleRaw?.split('||').last.toString() ?? '',
                                                                                  height: 50,
                                                                                  width: 50,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
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
                                                                                    await Share.share(question.titleRaw?.split('||').first.toString() ?? '', subject: 'Question');
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.share,
                                                                                    size: 10,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    await Share.share(question.titleRaw!.split('||').first.toString(), subject: 'Question');
                                                                                  },
                                                                                  child: const Text(
                                                                                    'Share',
                                                                                    style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                ),
                                                                                const Spacer(),
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    await communityVm.postVote(id: int.parse(question.mainPid.toString()));
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.favorite_border,
                                                                                    size: 10,
                                                                                    color: Color(0xff777777),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Text(
                                                                                  question.upvotes.toString(),
                                                                                  style: const TextStyle(
                                                                                    fontFamily: 'Roboto',
                                                                                    fontSize: 10,
                                                                                    color: Color(0xff333333),
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                const Text(
                                                                                  'Found it useful',
                                                                                  style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 15,
                                                                                ),
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    Get.to(
                                                                                      CommentScreen(
                                                                                        internalUser: false,
                                                                                        topic: question,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.message,
                                                                                    size: 10,
                                                                                    color: Color(0xff777777),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    Get.to(
                                                                                      CommentScreen(
                                                                                        internalUser: false,
                                                                                        topic: question,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: Text(
                                                                                    (int.parse(question.postcount.toString()) - 1).toString(),
                                                                                    style: const TextStyle(
                                                                                      fontFamily: 'Roboto',
                                                                                      fontSize: 10,
                                                                                      color: Color(0xff333333),
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    Get.to(
                                                                                      CommentScreen(
                                                                                        internalUser: false,
                                                                                        topic: question,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: const Text(
                                                                                    'Comments',
                                                                                    style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ))
                                                                  : Container(
                                                                      margin: const EdgeInsets.only(bottom: 8, top: 20),
                                                                      padding: const EdgeInsets.only(top: 5, left: 12, right: 10, bottom: 12),
                                                                      decoration: BoxDecoration(boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                          spreadRadius:
                                                                              1,
                                                                          blurRadius:
                                                                              2,
                                                                          offset: const Offset(
                                                                              0,
                                                                              3), // changes position of shadow
                                                                        ),
                                                                      ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                                                      child: Container(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12,
                                                                            left:
                                                                                12,
                                                                            right:
                                                                                12),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Row(children: [
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  Get.to(ExpertProfileScreen(
                                                                                    userSlug: question.user?.userslug ?? '',
                                                                                    uid: '',
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
                                                                                        offset: const Offset(0, 1), // changes position of shadow
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  child: Container(
                                                                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffD8F1E9)),
                                                                                    child: Center(
                                                                                        child: Text(
                                                                                      question.user?.displayname![0].toString() ?? '',
                                                                                      style: const TextStyle(fontFamily: 'Roboto', color: Color(0xff4AA588), fontSize: 16, fontWeight: FontWeight.w500),
                                                                                    )),
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
                                                                                            question.user?.username?.split(' ')[0] ?? '',
                                                                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 5,
                                                                                          ),
                                                                                          const Text(
                                                                                            'Wellness Expert',
                                                                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w200),
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
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  color: const Color(0xffD8F1E9),
                                                                                ),
                                                                                child: Text(
                                                                                  question.category?.name ?? '',
                                                                                  style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 10, color: Color(0xff333333)),
                                                                                ),
                                                                              ),
                                                                              const Spacer(),
                                                                              communityVm.aboutMe == 'Internal'
                                                                                  ? const SizedBox()
                                                                                  : communityVm.getFollowingModel.users?.any((element) => element.uid.toString() == question.user?.uid?.toString()) == true
                                                                                      ? Container(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                                            await communityVm.followUser(uId: int.parse(question.user?.uid.toString() ?? '0')).then((value) async {
                                                                                              await communityVm.getFollowing(userName: communityVm.userSlug);
                                                                                            });
                                                                                          },
                                                                                          child: Container(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                            decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                            SizedBox(
                                                                              child: Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        GestureDetector(
                                                                                          onTap: () {
                                                                                            Get.to(CommentScreen(
                                                                                              internalUser: true,
                                                                                              topic: question,
                                                                                            ));
                                                                                          },
                                                                                          child: Align(
                                                                                            alignment: Alignment.centerLeft,
                                                                                            child: Text(
                                                                                              question.titleRaw ?? '',
                                                                                              maxLines: 3,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              textAlign: TextAlign.justify,
                                                                                              style: const TextStyle(fontFamily: 'Roboto', color: Color(0xff333333), fontSize: 14, fontWeight: FontWeight.w400),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        question.titleRaw!.length > 100
                                                                                            ? GestureDetector(
                                                                                                onTap: () {
                                                                                                  Get.to(CommentScreen(internalUser: true, topic: question));
                                                                                                },
                                                                                                child: const Text(
                                                                                                  'Read More',
                                                                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                                                                              height: 5,
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
                                                                                    await Share.share(question.titleRaw ?? '', subject: 'Question');
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.share,
                                                                                    size: 10,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    await Share.share(question.titleRaw!.split('||').first.toString(), subject: 'Question');
                                                                                  },
                                                                                  child: const Text(
                                                                                    'Share',
                                                                                    style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                ),
                                                                                const Spacer(),
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    await communityVm.postVote(id: int.parse(question.mainPid.toString()));
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.favorite_border,
                                                                                    size: 15,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Text(
                                                                                  question.upvotes.toString(),
                                                                                  style: const TextStyle(
                                                                                    fontFamily: 'Roboto',
                                                                                    fontSize: 10,
                                                                                    color: Color(0xff333333),
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                const Text(
                                                                                  'Found it usefeul',
                                                                                  style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 15,
                                                                                ),
                                                                                const Icon(
                                                                                  Icons.message,
                                                                                  size: 10,
                                                                                  color: Color(0xff777777),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                Text(
                                                                                  (int.parse(question.postcount.toString()) - 1).toString(),
                                                                                  style: const TextStyle(
                                                                                    fontFamily: 'Roboto',
                                                                                    fontSize: 10,
                                                                                    color: Color(0xff333333),
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                const Text(
                                                                                  'Comments',
                                                                                  style: TextStyle(fontFamily: 'Roboto', color: Color(0xff777777), fontSize: 10, fontWeight: FontWeight.w400),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ));
                                                    }),
                                              ],
                                            ),
                                          );
                                        }
                                      }),
                                ),
                              ],
                            )),
                            Tab(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: FutureBuilder<UserTopicsModel>(
                                        future: communityVm.getUserTopics(
                                            userName: widget.userSlug),
                                        builder: (context, snapshot) {
                                          var questionData =
                                              communityVm.userTopicsModel;
                                          if (controller?.index != 0) {
                                            topics = [];

                                            questionData.topics
                                                ?.forEach((element) {
                                              if (element.tags?.first.value ==
                                                  'question') {
                                                print('is it true question');
                                                topics.add(element);
                                              }
                                            });
                                            if (mounted) {
                                              communityVm.notifyListeners();
                                            }
                                          }
                                          if (!snapshot.hasData) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else {
                                            var userTopics = snapshot.data;

                                            return SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  ListView.builder(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16,
                                                          vertical: 5),
                                                      shrinkWrap: true,
                                                      physics:
                                                          const ClampingScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount: topics.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        print(
                                                            'this is in my tags ${questionData.topics?[index].tags?.last.value}}');
                                                        cat.Topics question;
                                                        if (controller?.index ==
                                                            0) {
                                                          question =
                                                              questionData
                                                                      .topics![
                                                                  index];
                                                        } else {
                                                          question =
                                                              topics[index];
                                                        }
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback(
                                                                (timeStamp) async {
                                                          if (question
                                                                      .tags
                                                                      ?.first
                                                                      .value ==
                                                                  'product' &&
                                                              isFirstTime ==
                                                                  false) {
                                                            var productId =
                                                                'gid://shopify/Product/${question.titleRaw?.split('-').last.toString() ?? ''}';
                                                            print(
                                                                'this is our product id ${base64.encode(utf8.encode(productId))}');
                                                            var productID =
                                                                base64.encode(
                                                                    utf8.encode(
                                                                        productId));
                                                            product =
                                                                await Services()
                                                                    .api
                                                                    .getProduct(
                                                                        productID);
                                                            isFirstTime = true;
                                                            var bytes = utf8
                                                                .encode(product
                                                                        ?.categoryId ??
                                                                    '');
                                                            var base64Str =
                                                                base64.encode(
                                                                    bytes);
                                                            product?.categoryId =
                                                                base64Str;

                                                            await Future.delayed(
                                                                    Duration
                                                                        .zero)
                                                                .then((value) {
                                                              if (mounted) {
                                                                setState(() {});
                                                              }
                                                            });
                                                            // onTapProduct(context, product: product!);
                                                          }
                                                        });

                                                        return Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 8,
                                                                    top: 20),
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5,
                                                                    left: 12,
                                                                    right: 10,
                                                                    bottom: 12),
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        1,
                                                                    blurRadius:
                                                                        2,
                                                                    offset: const Offset(
                                                                        0,
                                                                        3), // changes position of shadow
                                                                  ),
                                                                ],
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 12,
                                                                      left: 12,
                                                                      right:
                                                                          12),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Get.to(ExpertProfileScreen(
                                                                              userSlug: question.user?.userslug ?? '',
                                                                              uid: '',
                                                                            ));
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                50,
                                                                            width:
                                                                                50,
                                                                            padding:
                                                                                const EdgeInsets.all(3),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.white,
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.grey.withOpacity(0.2),
                                                                                  spreadRadius: 2,
                                                                                  blurRadius: 8,
                                                                                  offset: const Offset(0, 1), // changes position of shadow
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child:
                                                                                Container(
                                                                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffD8F1E9)),
                                                                              child: Center(
                                                                                  child: Text(
                                                                                question.user?.displayname![0].toString() ?? '',
                                                                                style: const TextStyle(fontFamily: 'Roboto', color: Color(0xff4AA588), fontSize: 16, fontWeight: FontWeight.w500),
                                                                              )),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      question.user?.username?.split(' ')[0] ?? '',
                                                                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      height: 5,
                                                                                    ),
                                                                                    const Text(
                                                                                      'Wellness Expert',
                                                                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w200),
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
                                                                          width:
                                                                              15,
                                                                        ),
                                                                        Container(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 8),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            color:
                                                                                const Color(0xffD8F1E9),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            question.category?.name ??
                                                                                '',
                                                                            style: const TextStyle(
                                                                                fontFamily: 'Roboto',
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 10,
                                                                                color: Color(0xff333333)),
                                                                          ),
                                                                        ),
                                                                        const Spacer(),
                                                                        communityVm.aboutMe ==
                                                                                'Internal'
                                                                            ? const SizedBox()
                                                                            : communityVm.getFollowingModel.users?.any((element) => element.uid.toString() == question.user?.uid?.toString()) == true
                                                                                ? Container(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                    decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                                      await communityVm.followUser(uId: int.parse(question.user?.uid.toString() ?? '0')).then((value) async {
                                                                                        await communityVm.getFollowing(userName: communityVm.userSlug);
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                    thickness:
                                                                        1,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  SizedBox(
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  Get.to(CommentScreen(
                                                                                    internalUser: true,
                                                                                    topic: question,
                                                                                  ));
                                                                                },
                                                                                child: Align(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  child: Text(
                                                                                    question.titleRaw ?? '',
                                                                                    maxLines: 3,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    textAlign: TextAlign.justify,
                                                                                    style: const TextStyle(fontFamily: 'Roboto', color: Color(0xff333333), fontSize: 14, fontWeight: FontWeight.w400),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              question.titleRaw!.length > 100
                                                                                  ? GestureDetector(
                                                                                      onTap: () {
                                                                                        Get.to(CommentScreen(internalUser: true, topic: question));
                                                                                      },
                                                                                      child: const Text(
                                                                                        'Read More',
                                                                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                                                                    height: 5,
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        1,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          await Share.share(
                                                                              question.titleRaw ?? '',
                                                                              subject: 'Question');
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .share,
                                                                          size:
                                                                              10,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          await Share.share(
                                                                              question.titleRaw!.split('||').first.toString(),
                                                                              subject: 'Question');
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Share',
                                                                          style: TextStyle(
                                                                              fontFamily: 'Roboto',
                                                                              color: Color(0xff777777),
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ),
                                                                      const Spacer(),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          await communityVm.postVote(
                                                                              id: int.parse(question.mainPid.toString()));
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .favorite_border,
                                                                          size:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        question
                                                                            .upvotes
                                                                            .toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          fontSize:
                                                                              10,
                                                                          color:
                                                                              Color(0xff333333),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      const Text(
                                                                        'Found it usefeul',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            color: Color(
                                                                                0xff777777),
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      const Icon(
                                                                        Icons
                                                                            .message,
                                                                        size:
                                                                            10,
                                                                        color: Color(
                                                                            0xff777777),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        (int.parse(question.postcount.toString()) -
                                                                                1)
                                                                            .toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          fontSize:
                                                                              10,
                                                                          color:
                                                                              Color(0xff333333),
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      const Text(
                                                                        'Comments',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            color: Color(
                                                                                0xff777777),
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ));
                                                      }),
                                                ],
                                              ),
                                            );
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: FutureBuilder<UserTopicsModel>(
                                  future: communityVm.getUserTopics(
                                      userName: widget.userSlug),
                                  builder: (context, snapshot) {
                                    var questionData =
                                        communityVm.userTopicsModel;
                                    if (controller?.index != 0) {
                                      topics = [];
                                      questionData.topics?.forEach((element) {
                                        print(
                                            'tags value are ${element.tags?.first.value}');
                                        if (element.tags?.first.value ==
                                            'questionwithima') {
                                          topics.add(element);
                                        }
                                      });
                                      if (mounted) {
                                        communityVm.notifyListeners();
                                      }
                                    }
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      var userTopics = snapshot.data;

                                      return SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ListView.builder(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 5),
                                                shrinkWrap: true,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                scrollDirection: Axis.vertical,
                                                itemCount: topics.length,
                                                itemBuilder: (context, index) {
                                                  print(
                                                      'this is in my tags ${questionData.topics?[index].tags?.last.value}}');
                                                  cat.Topics question;
                                                  if (controller?.index == 0) {
                                                    question = questionData
                                                        .topics![index];
                                                  } else {
                                                    question = topics[index];
                                                  }
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (timeStamp) async {
                                                    if (question.tags?.first
                                                                .value ==
                                                            'product' &&
                                                        isFirstTime == false) {
                                                      var productId =
                                                          'gid://shopify/Product/${question.titleRaw?.split('-').last.toString() ?? ''}';
                                                      print(
                                                          'this is our product id ${base64.encode(utf8.encode(productId))}');
                                                      var productID = base64
                                                          .encode(utf8.encode(
                                                              productId));
                                                      product = await Services()
                                                          .api
                                                          .getProduct(
                                                              productID);
                                                      isFirstTime = true;
                                                      var bytes = utf8.encode(
                                                          product?.categoryId ??
                                                              '');
                                                      var base64Str =
                                                          base64.encode(bytes);
                                                      product?.categoryId =
                                                          base64Str;

                                                      await Future.delayed(
                                                              Duration.zero)
                                                          .then((value) {
                                                        if (mounted) {
                                                          setState(() {});
                                                        }
                                                      });
                                                      // onTapProduct(context, product: product!);
                                                    }
                                                  });
                                                  print(
                                                      'image URl ${question.titleRaw?.split('||').last ?? ''} ');
                                                  return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 8,
                                                              top: 20),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              left: 12,
                                                              right: 10,
                                                              bottom: 12),
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 1,
                                                              blurRadius: 2,
                                                              offset: const Offset(
                                                                  0,
                                                                  3), // changes position of shadow
                                                            ),
                                                          ],
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 12,
                                                                left: 12,
                                                                right: 12),
                                                        child: Column(
                                                          children: [
                                                            Row(children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Get.to(
                                                                      ExpertProfileScreen(
                                                                    userSlug: question
                                                                            .user
                                                                            ?.userslug ??
                                                                        '',
                                                                    uid: '',
                                                                  ));
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(3),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.2),
                                                                        spreadRadius:
                                                                            2,
                                                                        blurRadius:
                                                                            8,
                                                                        offset: const Offset(
                                                                            0,
                                                                            1), // changes position of shadow
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    decoration: const BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Color(
                                                                            0xffD8F1E9)),
                                                                    child: Center(
                                                                        child: Text(
                                                                      question.user
                                                                              ?.displayname![0]
                                                                              .toString() ??
                                                                          '',
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          color: Color(
                                                                              0xff4AA588),
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            question.user?.username?.split(' ')[0] ??
                                                                                '',
                                                                            style:
                                                                                const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          const Text(
                                                                            'Wellness Expert',
                                                                            style:
                                                                                TextStyle(fontSize: 9, fontWeight: FontWeight.w200),
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
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: const Color(
                                                                      0xffD8F1E9),
                                                                ),
                                                                child: Text(
                                                                  question.category
                                                                          ?.name ??
                                                                      '',
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          10,
                                                                      color: Color(
                                                                          0xff333333)),
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              communityVm.aboutMe ==
                                                                      'Internal'
                                                                  ? const SizedBox()
                                                                  : communityVm.getFollowingModel.users?.any((element) =>
                                                                              element.uid.toString() ==
                                                                              question.user?.uid?.toString()) ==
                                                                          true
                                                                      ? Container(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 4),
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(color: Colors.black),
                                                                              borderRadius: BorderRadius.circular(20)),
                                                                          child:
                                                                              const Text(
                                                                            'Following',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.w300,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            await communityVm.followUser(uId: int.parse(question.user?.uid.toString() ?? '0')).then((value) async {
                                                                              await communityVm.getFollowing(userName: communityVm.userSlug);
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
                                                                            child:
                                                                                Row(
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
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      SizedBox(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Get.to(
                                                                              CommentScreen(
                                                                                internalUser: false,
                                                                                topic: question,
                                                                              ),
                                                                            );
                                                                          },
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Text(
                                                                              question.titleRaw?.split('||').first.toString() ?? '',
                                                                              textAlign: TextAlign.justify,
                                                                              maxLines: 3,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        question.titleRaw!.split('||').first.toString().length >
                                                                                200
                                                                            ? GestureDetector(
                                                                                onTap: () {
                                                                                  Get.to(CommentScreen(
                                                                                    internalUser: false,
                                                                                    topic: question,
                                                                                  ));
                                                                                },
                                                                                child: const Text(
                                                                                  'Read More',
                                                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                                                                Image.network(
                                                                  question.titleRaw
                                                                          ?.split(
                                                                              '||')
                                                                          .last
                                                                          .toString() ??
                                                                      '',
                                                                  height: 50,
                                                                  width: 50,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
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
                                                                  onTap:
                                                                      () async {
                                                                    await Share.share(
                                                                        question.titleRaw?.split('||').first.toString() ??
                                                                            '',
                                                                        subject:
                                                                            'Question');
                                                                  },
                                                                  child:
                                                                      const Icon(
                                                                    Icons.share,
                                                                    size: 10,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await Share.share(
                                                                        question
                                                                            .titleRaw!
                                                                            .split(
                                                                                '||')
                                                                            .first
                                                                            .toString(),
                                                                        subject:
                                                                            'Question');
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Share',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Color(
                                                                            0xff777777),
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await communityVm.postVote(
                                                                        id: int.parse(question
                                                                            .mainPid
                                                                            .toString()));
                                                                  },
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .favorite_border,
                                                                    size: 10,
                                                                    color: Color(
                                                                        0xff777777),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  question
                                                                      .upvotes
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    fontSize:
                                                                        10,
                                                                    color: Color(
                                                                        0xff333333),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                const Text(
                                                                  'Found it useful',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      color: Color(
                                                                          0xff777777),
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                const SizedBox(
                                                                  width: 15,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Get.to(
                                                                      CommentScreen(
                                                                        internalUser:
                                                                            false,
                                                                        topic:
                                                                            question,
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .message,
                                                                    size: 10,
                                                                    color: Color(
                                                                        0xff777777),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Get.to(
                                                                      CommentScreen(
                                                                        internalUser:
                                                                            false,
                                                                        topic:
                                                                            question,
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    (int.parse(question.postcount.toString()) -
                                                                            1)
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontSize:
                                                                          10,
                                                                      color: Color(
                                                                          0xff333333),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Get.to(
                                                                      CommentScreen(
                                                                        internalUser:
                                                                            false,
                                                                        topic:
                                                                            question,
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Comments',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Color(
                                                                            0xff777777),
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ));
                                                }),
                                          ],
                                        ),
                                      );
                                    }
                                  }),
                            ),
                            Tab(
                                child: Column(
                              children: [
                                Expanded(
                                  child: FutureBuilder<UserTopicsModel>(
                                      future: communityVm.getUserTopics(
                                          userName: widget.userSlug),
                                      builder: (context, snapshot) {
                                        var questionData =
                                            communityVm.userTopicsModel.topics;
                                        if (controller?.index == 3) {
                                          questionData = communityVm
                                              .userTopicsModel.topics
                                              ?.where((element) =>
                                                  element.tags?.first.value ==
                                                  'product')
                                              .toList();
                                        }
                                        if (!snapshot.hasData) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else {
                                          var userTopics = snapshot.data;

                                          return SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                ListView.builder(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16,
                                                        vertical: 5),
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        questionData?.length ?? 0,
                                                    itemBuilder:
                                                        (context, index) {
                                                      print(
                                                          'this is in my tags ${questionData?[index].tags?.last.value}');
                                                      cat.Topics question;
                                                      if (controller?.index ==
                                                          3) {
                                                        question =
                                                            questionData![
                                                                index];
                                                      } else {
                                                        question =
                                                            topics[index];
                                                      }
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (timeStamp) async {
                                                        if (question.tags?.first
                                                                    .value ==
                                                                'product' &&
                                                            isFirstTime ==
                                                                false) {
                                                          var productId =
                                                              'gid://shopify/Product/${question.titleRaw?.split('-').last.toString() ?? ''}';
                                                          print(
                                                              'this is our product id ${base64.encode(utf8.encode(productId))}');
                                                          var productID = base64
                                                              .encode(utf8.encode(
                                                                  productId));
                                                          product =
                                                              await Services()
                                                                  .api
                                                                  .getProduct(
                                                                      productID);
                                                          isFirstTime = true;
                                                          var bytes = utf8
                                                              .encode(product
                                                                      ?.categoryId ??
                                                                  '');
                                                          var base64Str = base64
                                                              .encode(bytes);
                                                          product?.categoryId =
                                                              base64Str;

                                                          await Future.delayed(
                                                                  Duration.zero)
                                                              .then((value) {
                                                            if (mounted) {
                                                              setState(() {});
                                                            }
                                                          });
                                                          // onTapProduct(context, product: product!);
                                                        }
                                                      });
                                                      print(
                                                          'image URl ${question.titleRaw?.split('||').last ?? ''} ');
                                                      return Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 8,
                                                                  top: 20),
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 5,
                                                                  left: 12,
                                                                  right: 10,
                                                                  bottom: 12),
                                                          decoration: BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                  spreadRadius:
                                                                      1,
                                                                  blurRadius: 2,
                                                                  offset: const Offset(
                                                                      0,
                                                                      3), // changes position of shadow
                                                                ),
                                                              ],
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 12,
                                                                    left: 12,
                                                                    right: 12),
                                                            child: Column(
                                                              children: [
                                                                Row(children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.to(
                                                                          ExpertProfileScreen(
                                                                        userSlug:
                                                                            question.user?.userslug ??
                                                                                '',
                                                                        uid: '',
                                                                      ));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              3),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .white,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.2),
                                                                            spreadRadius:
                                                                                2,
                                                                            blurRadius:
                                                                                8,
                                                                            offset:
                                                                                const Offset(0, 1), // changes position of shadow
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        decoration: const BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color: Color(0xffD8F1E9)),
                                                                        child: Center(
                                                                            child: Text(
                                                                          question.user?.displayname![0].toString() ??
                                                                              '',
                                                                          style: const TextStyle(
                                                                              fontFamily: 'Roboto',
                                                                              color: Color(0xff4AA588),
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w500),
                                                                        )),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                question.user?.username?.split(' ')[0] ?? '',
                                                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              const Text(
                                                                                'Wellness Expert',
                                                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w200),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      color: const Color(
                                                                          0xffD8F1E9),
                                                                    ),
                                                                    child: Text(
                                                                      question.category
                                                                              ?.name ??
                                                                          '',
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          fontSize:
                                                                              10,
                                                                          color:
                                                                              Color(0xff333333)),
                                                                    ),
                                                                  ),
                                                                  const Spacer(),
                                                                  communityVm.aboutMe ==
                                                                          'Internal'
                                                                      ? const SizedBox()
                                                                      : communityVm
                                                                              .getFollowingModel
                                                                              .users!
                                                                              .any((element) => element.uid.toString() == question.user!.uid!.toString())
                                                                          ? Container(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                              decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                                await communityVm.followUser(uId: int.parse(question.user?.uid.toString() ?? '0')).then((value) async {
                                                                                  await communityVm.getFollowing(userName: communityVm.userSlug);
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                                decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
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
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(question
                                                                          .titleRaw
                                                                          ?.split(
                                                                              '-')
                                                                          .first
                                                                          .toString() ??
                                                                      ''),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Container(
                                                                  height: 100,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.2),
                                                                          offset: const Offset(
                                                                              4,
                                                                              4),
                                                                          blurRadius:
                                                                              10,
                                                                        )
                                                                      ]),
                                                                  margin: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          12),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      Get.to(
                                                                          CommentScreen(
                                                                        internalUser:
                                                                            true,
                                                                        topic:
                                                                            question,
                                                                        product:
                                                                            product ??
                                                                                Product(),
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
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                100,
                                                                            decoration: const BoxDecoration(
                                                                                color: Color(0xffD8F1E9),
                                                                                borderRadius: BorderRadius.only(
                                                                                  topRight: Radius.circular(20),
                                                                                  bottomRight: Radius.circular(20),
                                                                                )),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 5),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                children: [
                                                                                  const Text(
                                                                                    'RECOMENDED',
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
                                                                                        padding: EdgeInsets.only(left: 4.0),
                                                                                        child: Text(
                                                                                          '(41 Reviews)',
                                                                                          style: TextStyle(fontFamily: 'Roboto', color: Color(0xff000000), fontSize: 10, fontWeight: FontWeight.w400),
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
                                                                                        style: const TextStyle(color: Color(0xff000000), fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 10, decoration: TextDecoration.lineThrough),
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
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
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
                                                                      onTap:
                                                                          () async {
                                                                        await Share.share(
                                                                            question.titleRaw?.split('-').first.toString() ??
                                                                                '',
                                                                            subject:
                                                                                'Question');
                                                                      },
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .share,
                                                                        size:
                                                                            10,
                                                                        color: Color(
                                                                            0xff777777),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        await Share.share(
                                                                            question.titleRaw!.split('||').first.toString(),
                                                                            subject: 'Question');
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Share',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            color: Color(
                                                                                0xff777777),
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        await communityVm.postVote(
                                                                            id: int.parse(question.mainPid.toString()));
                                                                      },
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .favorite_border,
                                                                        size:
                                                                            10,
                                                                        color: Color(
                                                                            0xff777777),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      question
                                                                          .upvotes
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        fontSize:
                                                                            10,
                                                                        color: Color(
                                                                            0xff333333),
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    const Text(
                                                                      'Found it useful',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          color: Color(
                                                                              0xff777777),
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 15,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .message,
                                                                      size: 10,
                                                                      color: Color(
                                                                          0xff777777),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      (int.parse(question.postcount.toString()) -
                                                                              1)
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        fontSize:
                                                                            10,
                                                                        color: Color(
                                                                            0xff333333),
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    const Text(
                                                                      'Comments',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          color: Color(
                                                                              0xff777777),
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ));
                                                    }),
                                              ],
                                            ),
                                          );
                                        }
                                      }),
                                ),
                              ],
                            )),
                            Tab(
                              child: FutureBuilder<UserTopicsModel>(
                                  future: communityVm.getUserTopics(
                                      userName: widget.userSlug),
                                  builder: (context, snapshot) {
                                    var questionData =
                                        communityVm.userTopicsModel.topics;
                                    if (controller?.index == 4) {
                                      questionData = communityVm
                                          .userTopicsModel.topics
                                          ?.where((element) =>
                                              element.tags?.first.value ==
                                              'blog')
                                          .toList();
                                    }

                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      var userTopics = snapshot.data;

                                      return SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            ListView.builder(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 5),
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    questionData?.length ?? 0,
                                                itemBuilder: (context, index) {
                                                  print(
                                                      'this is in my tags ${questionData?[index].tags?.last.value}}');
                                                  cat.Topics question;

                                                  question =
                                                      questionData![index];

                                                  return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 8,
                                                              top: 20),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              left: 12,
                                                              right: 10,
                                                              bottom: 12),
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 1,
                                                              blurRadius: 2,
                                                              offset: const Offset(
                                                                  0,
                                                                  3), // changes position of shadow
                                                            ),
                                                          ],
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 12,
                                                                left: 12,
                                                                right: 12),
                                                        child: Column(
                                                          children: [
                                                            Row(children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Get.to(
                                                                      ExpertProfileScreen(
                                                                    userSlug: question
                                                                            .user
                                                                            ?.userslug ??
                                                                        '',
                                                                    uid: '',
                                                                  ));
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(3),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.2),
                                                                        spreadRadius:
                                                                            2,
                                                                        blurRadius:
                                                                            8,
                                                                        offset: const Offset(
                                                                            0,
                                                                            1), // changes position of shadow
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    decoration: const BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Color(
                                                                            0xffD8F1E9)),
                                                                    child: Center(
                                                                        child: Text(
                                                                      user?.fullName
                                                                              .split('')[0]
                                                                              .toUpperCase() ??
                                                                          '',
                                                                      style: const TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          color: Color(
                                                                              0xff4AA588),
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    )),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            question.user?.username?.split(' ')[0] ??
                                                                                '',
                                                                            style:
                                                                                const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          const Text(
                                                                            'Wellness Expert',
                                                                            style:
                                                                                TextStyle(fontSize: 9, fontWeight: FontWeight.w200),
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
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: const Color(
                                                                      0xffD8F1E9),
                                                                ),
                                                                child: Text(
                                                                  question.category
                                                                          ?.name ??
                                                                      '',
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          10,
                                                                      color: Color(
                                                                          0xff333333)),
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              communityVm.aboutMe ==
                                                                      'Internal'
                                                                  ? const SizedBox()
                                                                  : communityVm.getFollowingModel.users!.any((element) =>
                                                                          element
                                                                              .uid
                                                                              .toString() ==
                                                                          question
                                                                              .user!
                                                                              .uid!
                                                                              .toString())
                                                                      ? Container(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 4),
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(color: Colors.black),
                                                                              borderRadius: BorderRadius.circular(20)),
                                                                          child:
                                                                              const Text(
                                                                            'Following',
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 10,
                                                                              fontWeight: FontWeight.w300,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            await communityVm.followUser(uId: int.parse(question.user?.uid.toString() ?? '0')).then((value) async {
                                                                              await communityVm.getFollowing(userName: communityVm.userSlug);
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                            decoration:
                                                                                BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(20)),
                                                                            child:
                                                                                Row(
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
                                                            Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5)),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Get.to(
                                                                            CommentScreen(
                                                                          internalUser:
                                                                              true,
                                                                          topic:
                                                                              question,
                                                                        ));
                                                                      },
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        child: Image.network(
                                                                            question.titleRaw?.split('||').last ??
                                                                                '',
                                                                            height:
                                                                                200,
                                                                            width:
                                                                                Get.width,
                                                                            fit: BoxFit.cover),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                          vertical:
                                                                              5),
                                                                      child:
                                                                          Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              question.titleRaw?.split('||').first.split('-')[0].toString() ?? '',
                                                                              textAlign: TextAlign.justify,
                                                                              style: const TextStyle(color: Color(0xff333333), fontFamily: 'Roboto', fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.w500),
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
                                                                                      Get.to(
                                                                                        CommentScreen(
                                                                                          internalUser: true,
                                                                                          topic: question,
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                    child: Text(
                                                                                      question.titleRaw?.split('||').first.split('-')[1].toString() ?? '',
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                      textAlign: TextAlign.justify,
                                                                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(width: 5),
                                                                                if ((question.titleRaw?.split('||').first.split('-')[1].toString().length ?? 0) > 100)
                                                                                  GestureDetector(
                                                                                    onTap: () {
                                                                                      Get.to(
                                                                                        CommentScreen(
                                                                                          internalUser: true,
                                                                                          topic: question,
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                    child: const Text(
                                                                                      'Read More',
                                                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                                                                                    ),
                                                                                  ),
                                                                                const SizedBox(width: 30),
                                                                                Text(
                                                                                  DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(question.timestamp.toString()))),
                                                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
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
                                                                )),
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
                                                                  onTap:
                                                                      () async {
                                                                    await Share.share(
                                                                        question.titleRaw?.split('-')[1].toString() ??
                                                                            '',
                                                                        subject:
                                                                            'Question');
                                                                  },
                                                                  child:
                                                                      const Icon(
                                                                    Icons.share,
                                                                    size: 10,
                                                                    color: Color(
                                                                        0xff777777),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await Share.share(
                                                                        question
                                                                            .titleRaw!
                                                                            .split(
                                                                                '||')
                                                                            .first
                                                                            .toString(),
                                                                        subject:
                                                                            'Question');
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Share',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        color: Color(
                                                                            0xff777777),
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    await communityVm.postVote(
                                                                        id: int.parse(question
                                                                            .mainPid
                                                                            .toString()));
                                                                  },
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .favorite_border,
                                                                    size: 10,
                                                                    color: Color(
                                                                        0xff777777),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  question
                                                                      .upvotes
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    fontSize:
                                                                        10,
                                                                    color: Color(
                                                                        0xff333333),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                const Text(
                                                                  'Found it useful',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      color: Color(
                                                                          0xff777777),
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                const SizedBox(
                                                                  width: 15,
                                                                ),
                                                                const Icon(
                                                                  Icons.message,
                                                                  size: 10,
                                                                  color: Color(
                                                                      0xff777777),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  (int.parse(question
                                                                              .postcount
                                                                              .toString()) -
                                                                          1)
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    fontSize:
                                                                        10,
                                                                    color: Color(
                                                                        0xff333333),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                const Text(
                                                                  'Comments',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      color: Color(
                                                                          0xff777777),
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ));
                                                }),
                                          ],
                                        ),
                                      );
                                    }
                                  }),
                            )
                          ]),
                    )
                  ],
                )
              : const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}

class ExamplePolls extends StatefulWidget {
  const ExamplePolls({Key? key}) : super(key: key);

  @override
  State<ExamplePolls> createState() => _ExamplePollsState();
}

class _ExamplePollsState extends State<ExamplePolls> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: polls().length,
        itemBuilder: (BuildContext context, int index) {
          final Map<String, dynamic> poll = polls()[index];

          final int days = DateTime(
            poll['end_date'].year,
            poll['end_date'].month,
            poll['end_date'].day,
          )
              .difference(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ))
              .inDays;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Row(children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink.withOpacity(0.3)),
                      child: Center(
                          child: Text(
                        'S',
                        style: TextStyle(
                            color: Colors.pink.withOpacity(0.6),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
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
                          const Text(
                            'Ridhima',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Wellness Expert',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w200),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.pink.withOpacity(0.2),
                    ),
                    child: const Text('Hair Care'),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 15,
                        ),
                        const Text(
                          'Follow',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                FlutterPolls(
                  votedProgressColor: Colors.pink.withOpacity(0.2),
                  pollOptionsHeight: 40,
                  pollId: poll['id'].toString(),
                  // hasVoted: hasVoted.value,
                  // userVotedOptionId: userVotedOptionId.value,
                  onVoted: (PollOption pollOption, int newTotalVotes) async {
                    await Future.delayed(const Duration(seconds: 1));

                    /// If HTTP status is success, return true else false
                    return true;
                  },
                  pollEnded: days < 0,
                  pollTitle: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      poll['question'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  votedPollOptionsRadius: const Radius.circular(20),
                  pollOptions: List<PollOption>.from(
                    poll['options'].map(
                      (option) {
                        var a = PollOption(
                          id: option['id'],
                          title: Text(
                            option['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          votes: option['votes'],
                        );
                        return a;
                      },
                    ),
                  ),
                  votedPercentageTextStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  metaWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        days < 0 ? 'ended' : 'ends $days days',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String formatTimeAgo(int epochMillis) {
  DateTime now = DateTime.now();
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis);
  Duration difference = now.difference(dateTime);

  int minutes = difference.inMinutes;

  if (minutes < 1) {
    return 'just now';
  } else if (minutes == 1) {
    return '1 minute ago';
  } else if (minutes > 1 && minutes < 60) {
    return '$minutes minutes ago';
  } else if (minutes >= 60) {
    return '${(minutes / 60).toInt()} hours ago';
  } else {
    return '$minutes minutes ago';
  }
}

List polls() => [
      {
        'id': 1,
        'question':
            'Is Flutter the best framework for building cross-platform applications?',
        'end_date': DateTime(2022, 5, 21),
        'options': [
          {
            'id': 1,
            'title': 'Absolutely',
            'votes': 40,
          },
          {
            'id': 2,
            'title': 'Maybe',
            'votes': 20,
          },
          {
            'id': 3,
            'title': 'Meh!',
            'votes': 10,
          },
        ],
      },
    ];
