import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fstore/screens/community_Forum/user_topics_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fstore/screens/community_Forum/categories_model.dart' as cat;

import '../../models/user_model.dart';
import 'chat_screen.dart';
import 'community_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userSlug;
  const UserProfileScreen({Key? key, required this.userSlug}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  bool isLoading = false;
  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    var user = Provider.of<UserModel>(context, listen: false).user;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isLoading = true;
      communityVm.notifyListeners();
      await communityVm
          .getProfile(id: int.parse(communityVm.userId ?? ''))
          .then((value) {
        isLoading = false;
        communityVm.notifyListeners();
      });
      await communityVm.getUserTopics(userName: widget.userSlug);
      await communityVm.getUserPosts(username: widget.userSlug);
      communityVm.updatedList();
      setState(() {});
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
                      padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                      height: 190,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_sharp,
                                  size: 18,
                                  color: Color(0xff000000),
                                ),
                              ),
                              const Text(
                                ' Profile',
                                style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Color(0xff333333)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Row(
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
                                      user?.fullName
                                              .split('')[0]
                                              .toUpperCase() ??
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
                          ),
                          const Spacer(
                            flex: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              // margin: EdgeInsets.only(top: 2),
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      controller?.animateTo(0);
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding:
                                          const EdgeInsets.only(left: 10, right: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'My Activities',
                                            style: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff333333)),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              height: 3,
                                              width: 90,
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
                                      padding:
                                          const EdgeInsets.only(left: 10, right: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                              height: 3,
                                              width: 60,
                                              color: controller?.index == 1
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
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: controller,
                          children: [
                            Tab(
                              child: activityWidget(communityVm: communityVm),
                            ),
                            Tab(
                                child: FutureBuilder<UserTopicsModel>(
                                    future: communityVm.getUserTopics(
                                        userName: widget.userSlug),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        var userTopics =
                                            communityVm.userTopicsModel;
                                        var externalQuestion =
                                            userTopics.topics!.toList();
                                        return ListView.builder(
                                            itemCount:   externalQuestion.length ?? 0,
                                            itemBuilder: (context , index){
                                              return questionWidget(
                                                  question:
                                                  externalQuestion[index]);
                                            });
                                      }
                                    })),
                          ]),
                    )
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        }),
      ),
    );
  }

  Widget activityWidget({required CommunityProvider communityVm}) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 20),
        padding: const EdgeInsets.only(top: 5, left: 12, right: 12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: communityVm.getAll.length ?? 0,
                    itemBuilder: (context, index) {
                      var isPost =
                          communityVm.getAll[index].containsKey('topic') ==
                              true;
                      log('this is post $isPost');
                      return Container(
                        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                        child: Column(
                          children: [
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
                                    communityVm.getAll[index]['user']
                                            ['icon:text'] ??
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
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Text(
                                        'You',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      // SizedBox(
                                      //   width: 5,
                                      // ),
                                      // Text(
                                      //   'wellness Expert',
                                      //   style: TextStyle(
                                      //       fontSize: 9,
                                      //       fontWeight: FontWeight.w200),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    isPost == true
                                        ? 'commented on a post'
                                        : 'you posted a question',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                formatTimeAgo(int.parse(communityVm
                                    .getAll[index]['timestamp']
                                    .toString())),
                                style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Color(0xff777777),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                            ]),
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                          ],
                        ),
                      );
                    })),
          ],
        ),
      ),
    );
  }

  Widget questionWidget({cat.Topics? question}) {
    return question?.tags?.first.value == 'questionwithima'
        ? Container(
            margin:
                const EdgeInsets.only(bottom: 8, top: 20, left: 15, right: 15),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Get.to(
                        //     UserProfileScreen(
                        //   userSlug:
                        //       question.user?.userslug ??
                        //           '',
                        // ));
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
                              offset: const Offset(
                                  0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xffD8F1E9)),
                          child: Center(
                              child: Text(
                            question?.user?.username
                                    ?.split('')[0]
                                    .toUpperCase() ??
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
                    GestureDetector(
                      onTap: () {
                        Get.to(CommentScreen(
                          internalUser: false,
                          topic: question ?? cat.Topics(),
                        ));
                      },
                      child: Text(
                        question?.user?.username ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xffD8F1E9),
                      ),
                      child: Text(
                        question?.category?.name ?? '',
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
                                Get.to(CommentScreen(
                                  internalUser: false,
                                  topic: question ?? cat.Topics(),
                                ));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  question?.titleRaw
                                          ?.split('||')
                                          .first
                                          .toString() ??
                                      '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                            question!.titleRaw!
                                        .split('||')
                                        .first
                                        .toString()
                                        .length >
                                    200
                                ? GestureDetector(
                                    onTap: () {
                                      Get.to(CommentScreen(
                                        internalUser: false,
                                        topic: question ?? cat.Topics(),
                                      ));
                                    },
                                    child: const Text(
                                      'Read More',
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
                    Image.network(
                      question?.titleRaw?.split('||').last.toString() ?? '',
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
                  color: Color(0xffEDEDED),
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(CommentScreen(
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
                          Icons.comment_outlined,
                          color: Color(0xff777777),
                          size: 16,
                        ),
                      ),
                      Text(
                        '${(int.parse(question?.postcount.toString() ?? '0') - 1).toString()} Answer',
                        style: const TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xff777777),
                            fontSize: 10,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        : Container(
      margin: const EdgeInsets
          .only(
          bottom: 8, top: 20 , left: 15 , right: 15),
      padding:
      const EdgeInsets
          .symmetric(
          horizontal: 10,
          vertical: 10),
      decoration: BoxDecoration(
          borderRadius:
          BorderRadius
              .circular(
              20),
          color:
          Colors.white),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Get.to(
                  //     ExpertProfileScreen(
                  //       userSlug:
                  //       question.user?.userslug ??
                  //           '',
                  //     ));
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
                        color:
                        Color(0xffD8F1E9)),
                    child: Center(
                        child: Text(
                          question?.user?.username?.split('')[0].toUpperCase() ??
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
              Text(
                question?.user
                    ?.username ??
                    '',
                style: const TextStyle(
                    fontSize:
                    14,
                    fontWeight:
                    FontWeight
                        .w300),
              ),
              const SizedBox(
                width: 10,
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
                  question?.category
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
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(
                0xffEDEDED),
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(

            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                          CommentScreen(
                            internalUser:
                            false,
                            topic: question ??
                                cat.Topics(),
                          ));
                    },
                    child:
                    Align(
                      alignment:
                      Alignment
                          .centerLeft,
                      child:
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question?.titleRaw ??
                                '',
                            maxLines:
                            3,
                            overflow:
                            TextOverflow.ellipsis,
                            textAlign:
                            TextAlign.justify,
                            style: const TextStyle(
                                fontSize:
                                14,
                                fontWeight:
                                FontWeight.w300),
                          ),
                          question!.title!
                              .length >
                              200
                              ? GestureDetector(
                            onTap:
                                () {
                              Get.to(CommentScreen(
                                internalUser: false,
                                topic: question ?? cat.Topics(),
                              ));
                            },
                            child:
                            const Text(
                              'Read More',
                              style:
                              TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          )
                              : const SizedBox
                              .shrink()
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Color(
                0xffEDEDED),
            thickness: 1,
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              Get.to(
                  CommentScreen(
                    internalUser:
                    false,
                    topic:
                    question,
                  ));
            },
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                      right:
                      2.0),
                  child: Icon(
                    Icons
                        .comment_outlined,
                    color: Color(
                        0xff777777),
                    size: 16,
                  ),
                ),
                Text(
                  '${(int.parse(question.postcount.toString() ?? '0') - 1).toString()} Answer',
                  style: const TextStyle(
                      fontFamily:
                      'Roboto',
                      color: Color(
                          0xff777777),
                      fontSize:
                      10,
                      fontWeight:
                      FontWeight.w400),
                )
              ],
            ),
          )
        ],
      ),
    );
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
}
