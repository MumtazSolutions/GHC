
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' show parse;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants.dart';
import '../../models/entities/product.dart';
import '../../models/user_model.dart';
import '../../widgets/overlay/overlay_loader.dart';
import '../../widgets/product/action_button_mixin.dart';
import '../common/expand_image.dart';
import 'answers_model.dart';
import 'answers_model.dart' as answer_models;
import 'categories_model.dart';
import 'community_provider.dart';

class CommentScreen extends StatefulWidget {
  Topics? topic;
  final bool internalUser;
  int? topicIndex;
  Product? product;
  CommentScreen(
      {Key? key,
      this.topic,
      required this.internalUser,
      this.product,
      this.topicIndex})
      : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> with ActionButtonMixin {
  TextEditingController answerController = TextEditingController();
  bool isUpvoted = false;
  bool isLoading = false;
  bool hasNextPage = true;
  FocusNode myFocusNode = FocusNode();
  final PagingController<int, Posts> _pagingController =
      PagingController(firstPageKey: 1);
  List<Posts> tempPosts = [];
  var answerUser = answer_models.User();
  Future<void> _loadMore(int pageKey, CommunityProvider vm) async {
    try {
      final newItems =
          await vm.getAnswers(id: widget.topic?.tid! as int, page: pageKey);
      hasNextPage = newItems.pagination?.next?.active as bool;
      if (hasNextPage == false) {
        _pagingController.appendLastPage(newItems.posts ?? []);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems.posts ?? [], nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();
    // staticPost = Posts();
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    _pagingController.addPageRequestListener((pageKey) {
      _loadMore(pageKey, communityVm);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('this is topic id ${widget.topic?.tid}');
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffD8F1E9),
        body: Consumer<CommunityProvider>(builder: (context, communityVm, _) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.topic?.tags?.first.value == 'blog'
                                ? chatPostBlogWidget(topic: widget.topic!)
                                : widget.topic?.tags?.first.value == 'product'
                                    ? chatPostProductWidget(
                                        product: widget.product!,
                                        topic: widget.topic!)
                                    : widget.topic?.tags?.first.value ==
                                            'questionwithima'
                                        ? chatPostQuestionWithImageWidget(
                                            topic: widget.topic!)
                                        : chatPostQuestionWidget(
                                            topic: widget.topic!),
                            GestureDetector(
                              onTap: () async {
                                await communityVm
                                    .postVote(
                                        id: communityVm.answersModel.posts
                                                ?.first.pid as int? ??
                                            0)
                                    .then((value) {
                                  isUpvoted = true;
                                  setState(() {});
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                height: 40,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      communityVm.answersModel.upvotes !=
                                                  null &&
                                              communityVm.answersModel.upvotes
                                                      as int >
                                                  0
                                          ? '${communityVm.answersModel.upvotes} found it useful'
                                          : 'Did you find it useful?',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.withOpacity(0.9)),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      isUpvoted == false
                                          ? Icons.favorite_border
                                          : Icons.favorite,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: PagedListView(
                                  pagingController: _pagingController,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  builderDelegate: PagedChildBuilderDelegate(
                                    itemBuilder: (context, item, index) {
                                      var data = item as Posts;
                                      if (data.content.toString().contains(
                                              'Content not required') ||
                                          data.content.toString().contains(
                                              'content not required')) {
                                        return const SizedBox();
                                      }
                                      if (communityVm.userId
                                              .toString()
                                              .contains(
                                                  data.user?.uid.toString() ??
                                                      '') ==
                                          true) {
                                        // staticPost.user = data.user;
                                        answerUser = data.user!;
                                        return chatBubbleWidgetMe(
                                          post: data,
                                        );
                                      } else {
                                        return chatBubbleWidget(
                                          post: data,
                                        );
                                      }
                                    },
                                    firstPageProgressIndicatorBuilder:
                                        ((context) => const OverlayLoader()),
                                    newPageProgressIndicatorBuilder:
                                        ((context) => Center(
                                              child: CircularProgressIndicator
                                                  .adaptive(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.grey.shade600,
                                                ),
                                              ),
                                            )),
                                  ),
                                ),
                              ),
                            ),
                            for(int i = 0; i < tempPosts.length; ++i)
                              tempPosts[i].content != null ? chatBubbleWidgetMe(post: tempPosts[i],newPost: i == tempPosts.length - 1) : const SizedBox(),
                            const Padding(padding: EdgeInsets.only(bottom: 10)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(
                                0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextField(
                        focusNode: myFocusNode,
                        controller: answerController,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.withOpacity(0.1),
                          filled: true,
                          hintText: 'Comment/Answer here..',
                          suffixIcon: GestureDetector(
                              onTap: () async {
                                if (answerController.text.isEmpty) {
                                  await Fluttertoast.showToast(
                                    msg: 'Please enter valid text to post a comment',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey[600],
                                    textColor: Colors.white
                                  );
                                } else {
                                    var tempPost = Posts();
                                    setState(() {
                                      isLoading = true;
                                    });
                                    try {
                                      tempPost.timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
                                      var comment = answerController.text;
                                      // ignore: unnecessary_string_escapes
                                      tempPost.content = '<p dir=\"auto\">$comment</p>';
                                      tempPost.user = answerUser;
                                      tempPosts.add(tempPost);
                                      answerController.clear();
                                      await communityVm.postAnswer(
                                        id: int.parse(widget.topic?.tid.toString() ?? ''),
                                        answer: comment
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                        tempPost.content = null;
                                      });
                                      await Fluttertoast.showToast(
                                        msg: 'You can post a new comment after 60 seconds',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey[600],
                                        textColor: Colors.white
                                      );
                                      if (kDebugMode) {
                                        print(e);
                                      }
                                    }
                                }
                              },
                              child: const Icon(
                                Icons.send,
                                color: Colors.black,
                              )),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                );
              })
      ),
    );
  }

  Widget chatPostQuestionWidget({required Topics topic}) {
    var user = Provider.of<UserModel>(context, listen: false).user;
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.only(top: 5, right: 12, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(
                  Icons.arrow_back_ios_sharp,
                  size: 15,
                  color: Color(0xff000000),
                ),
              ),
              const Text(
                'Post',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xff333333)),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            width: Get.width,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 25),
            child: Column(
              children: [
                Row(children: [
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
                              offset: const Offset(
                                  0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffD8F1E9),
                          ),
                          child: Center(
                              child: Text(
                            widget.topic?.user?.icontext ?? '',
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
                        ((widget.topic?.tags?.last.value == 'notanonymous') ||
                                (widget.topic?.tags?.last.value != 'Internal' &&
                                    widget.topic?.tags?.last.value !=
                                        'anonymous'))
                            ? widget.topic?.user?.username?.split(' ')[0] ?? ''
                            : 'Anonymous',
                        style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Color(0xff333333),
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      // Row(
                      //   children: [
                      //     Text(
                      //       topic.user?.displayname ?? '',
                      //       style: const TextStyle(
                      //           fontSize: 17, fontWeight: FontWeight.bold),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      // Text(
                      //   'Wellness Expert',
                      //   style: TextStyle(
                      //       fontSize: 10, fontWeight: FontWeight.w200),
                      // ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 7, bottom: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xffD8F1E9),
                    ),
                    child: Text(
                      topic.category?.name ?? '',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Color(0xff333333)),
                    ),
                  ),
                  const Spacer(),
                ]),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xffEDEDED),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.topic?.titleRaw
                                  ?.split('||')
                                  .first
                                  .toString() ??
                              '',
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xff333333),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xffEDEDED),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.message_outlined,
                      size: 12,
                      color: Color(0xff777777),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      ((communityVm.answersModel.posts?.length ?? 1) - 1)
                          .toString(),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      'Answers',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff777777)),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget chatPostProductWidget(
      {required Topics topic, required Product product}) {
    var user = Provider.of<UserModel>(context, listen: false).user;
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.only(top: 5, right: 12, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(
                  Icons.arrow_back_ios_sharp,
                  size: 15,
                  color: Color(0xff000000),
                ),
              ),
              const Text(
                'Post',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xff333333)),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            width: Get.width,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 25),
            child: Column(
              children: [
                Row(children: [
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
                              offset: const Offset(
                                  0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffD8F1E9),
                          ),
                          child: Center(
                              child: Text(
                            user?.fullName.split('')[0].toUpperCase() ?? '',
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
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      // Row(
                      //   children: [
                      //     Text(
                      //       topic.user?.displayname ?? '',
                      //       style: const TextStyle(
                      //           fontSize: 17, fontWeight: FontWeight.bold),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      // Text(
                      //   'Wellness Expert',
                      //   style: TextStyle(
                      //       fontSize: 10, fontWeight: FontWeight.w200),
                      // ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 7, bottom: 7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xffD8F1E9)),
                    child: Text(
                      topic.category?.name ?? '',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Color(0xff333333)),
                    ),
                  ),
                  const Spacer(),
                ]),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xffEDEDED),
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      widget.topic?.title?.split('-').first.toString() ?? ''),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    onTapProduct(context, product: product);
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
                          height: 105,
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
                                      padding: EdgeInsets.only(left: 4.0),
                                      child: Text(
                                        '(41 Reviews)',
                                        style: TextStyle(
                                            fontFamily: 'Roboto',
                                            color: Color(0xff000000),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400),
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
                                          decoration:
                                              TextDecoration.lineThrough),
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
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xffEDEDED),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.message_outlined,
                      size: 12,
                      color: Color(0xff777777),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      ((communityVm.answersModel.posts?.length ?? 1) - 1)
                          .toString(),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      'Answers',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff777777)),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget chatPostQuestionWithImageWidget({required Topics topic}) {
    var user = Provider.of<UserModel>(context, listen: false).user;
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.only(top: 5, right: 12, bottom: 15, left: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(
                  Icons.arrow_back_ios_sharp,
                  size: 15,
                  color: Color(0xff000000),
                ),
              ),
              const Text(
                'Post',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xff333333)),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            width: Get.width,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Get.to(
                  //     UserProfileScreen(
                  //   userSlug: question
                  //           .user
                  //           ?.userslug ??
                  //       '',
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
                      topic.user?.username?.split('')[0].toUpperCase() ?? '',
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
              Text(
                ((widget.topic?.tags?.last.value == 'notanonymous') ||
                        (widget.topic?.tags?.last.value != 'Internal' &&
                            widget.topic?.tags?.last.value != 'anonymous'))
                    ? widget.topic?.user?.username?.split(' ')[0] ?? ''
                    : 'Anonymous',
                style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xff333333),
                    fontWeight: FontWeight.w500),
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
                  topic.category?.name ?? '',
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: Text(
                            topic.titleRaw?.split('||').first.toString() ?? '',
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
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
                          path: topic.titleRaw?.split('||').last.toString() ??
                              ''),
                    );
                  },
                  child: Image.network(
                    topic.titleRaw?.split('||').last.toString() ?? '',
                    height: 63,
                    width: 63,
                    fit: BoxFit.cover,
                  ),
                ),
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
                topic: topic,
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
                  '${(int.parse(communityVm.answersModel.posts?.length.toString() ?? '0') - 1)} Answer',
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
    );
  }

  Widget chatPostBlogWidget({required Topics topic}) {
    var user = Provider.of<UserModel>(context, listen: false).user;
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.only(top: 5, right: 12, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(
                  Icons.arrow_back_ios_sharp,
                  size: 15,
                  color: Color(0xff000000),
                ),
              ),
              const Text(
                'Post',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xff333333)),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            width: Get.width,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 25),
            child: Column(
              children: [
                Row(children: [
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
                            user?.fullName.split('')[0].toUpperCase() ?? '',
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
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      // Row(
                      //   children: [
                      //     Text(
                      //       topic.user?.displayname ?? '',
                      //       style: const TextStyle(
                      //           fontSize: 17, fontWeight: FontWeight.bold),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      // Text(
                      //   'Wellness Expert',
                      //   style: TextStyle(
                      //       fontSize: 10, fontWeight: FontWeight.w200),
                      // ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 7, bottom: 7),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xffD8F1E9)),
                    child: Text(
                      topic.category?.name ?? '',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Color(0xff333333)),
                    ),
                  ),
                  const Spacer(),
                ]),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xffEDEDED),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse(topic.titleRaw
                            ?.split('||')
                            .first
                            .split('-')[2]
                            .toString() ??
                        ''));
                  },
                  child: Image.network(topic.titleRaw?.split('||').last ?? '',
                      height: 200, width: Get.width, fit: BoxFit.cover),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.titleRaw
                                ?.split('||')
                                .first
                                .split('-')[0]
                                .toString() ??
                            '',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        topic.titleRaw
                                ?.split('||')
                                .first
                                .split('-')[1]
                                .toString() ??
                            '',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                  color: Color(0xffEDEDED),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.message_outlined,
                      size: 12,
                      color: Color(0xff777777),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      ((communityVm.answersModel.posts?.length ?? 1) - 1)
                          .toString(),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      'Answers',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff777777)),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget chatBubbleWidget({required Posts post}) {
    var document = parse(post.content);
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffD8F1E9),
                  ),
                  child: Center(
                      child: Text(
                    post.user?.username?.split('')[0].toUpperCase() ?? '',
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
                post.user?.username?.split(' ').sublist(0, 2).join(' ') ?? '',
                style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xff333333),
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    document.getElementsByTagName('p')[0].innerHtml,
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff333333)),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      formatTimeAgo(int.parse(post.timestamp.toString())),
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xff777777),
                          fontSize: 10,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget chatBubbleWidgetMe({required Posts post, bool newPost = false}) {
    var document = parse(post.content);
    var user = Provider.of<UserModel>(context,listen: false).user;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Me',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xff333333),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                width: 10,
              ),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffD8F1E9),
                  ),
                  child: Center(
                    child: Text(
                      post.user?.username?.split('')[0].toUpperCase() ?? user?.firstName?[0] ?? '',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xff4AA588),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  document.getElementsByTagName('p')[0].innerHtml,
                  style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff333333)),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    (isLoading && newPost) ? const Icon(Icons.schedule) :
                    Text(
                      formatTimeAgo(int.parse(post.timestamp.toString())),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xff777777),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
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
