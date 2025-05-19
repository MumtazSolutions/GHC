import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fstore/screens/community_Forum/community_provider.dart';
import 'package:get/get.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';

class InternalUserAskQuestionScreen extends StatefulWidget {
  const InternalUserAskQuestionScreen({Key? key}) : super(key: key);

  @override
  State<InternalUserAskQuestionScreen> createState() =>
      _InternalUserAskQuestionScreenState();
}

class _InternalUserAskQuestionScreenState
    extends State<InternalUserAskQuestionScreen> {
  int seletedIndex = 0;
  File? imgFile;
  bool isPoll = false;
  bool isQuestion = true;
  bool isImage = false;
  bool isBlog = false;
  bool isProduct = false;
  bool isLoading = false;
  int postIndex = 0;
  int pollTypeQuestionIndex = 0;
  var categories;
  List selectedCategories = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    selectedCategories = List.from(communityVm.categories['categories']);

    List<Map<String, dynamic>> elementsToRemove = [];
    for (var element in communityVm.categories['categories']) {
      if (element['name'] == 'All') {
        elementsToRemove.add(element);
      }
    }

    selectedCategories
        .removeWhere((element) => elementsToRemove.contains(element));
    categories = selectedCategories;
  }

  void openCamera() async {
    var imgCamera = await ImagePicker()
        .pickImage(imageQuality: 50, source: ImageSource.camera);

    imgFile = File(imgCamera?.path ?? '');
    setState(() {});
  }

  List<String> postType = [
    'Question',
    'Question & image',
    // 'Poll',
    'Blogs',
    'Product Recommendation'
  ];

  List<IconData> postTypeIcon = [
    Icons.question_mark_outlined,
    Icons.image,
    Icons.poll,
    Icons.article,
    Icons.shopping_bag
  ];

  void openGallery() async {
    var imgGallery = (await ImagePicker()
        .pickImage(imageQuality: 50, source: ImageSource.gallery));
    if (imgGallery?.path == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('image not supported')));
      return;
    }
    imgFile = File(imgGallery!.path);
    setState(() {});
  }

  final TextEditingController postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    var user = Provider.of<UserModel>(context, listen: false).user;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffFFFFFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: Color(0xff000000),
              ),
            ),
          ),
          title: const Text(
            'Add New Post',
            style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xff333333),
                fontWeight: FontWeight.w500),
          ),
        ),
        body: isLoading == false
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.firstName ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w500),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 2.0),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Wellness Expert',
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  color: Color(0xff777777)),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Select post type',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff333333)),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(postType.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                postIndex = index;
                                if (index == 0) {
                                  isQuestion = true;
                                  isImage = false;
                                  isPoll = false;
                                  isBlog = false;
                                  isProduct = false;
                                } else if (index == 1) {
                                  isQuestion = false;
                                  isImage = true;
                                  isPoll = false;
                                  isBlog = false;
                                  isProduct = false;
                                }
                                // else if (index == 2) {
                                //   isQuestion = false;
                                //   isImage = false;
                                //   isPoll = true;
                                //   isBlog = false;
                                //   isProduct = false;
                                // }
                                else if (index == 2) {
                                  isQuestion = false;
                                  isImage = false;
                                  isPoll = false;
                                  isBlog = true;
                                  isProduct = false;
                                } else if (index == 3) {
                                  isQuestion = false;
                                  isImage = false;
                                  isPoll = false;
                                  isBlog = false;
                                  isProduct = true;
                                }
                              });
                            },
                            child: Container(
                              height: 37,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: postIndex == index
                                      ? const Color(0xffD8F1E9)
                                      : const Color(0xffF1F2F2)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black),
                                    child: Icon(
                                      postTypeIcon[index],
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    postType[index],
                                    style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xff000000),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    isImage
                        ? TextFormField(
                            controller: postController,
                            maxLines: imgFile == null ? 14 : 11,
                            decoration: const InputDecoration(
                              hintText: 'Write your question here..',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                            ),
                          )
                        : isPoll
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: postController,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      hintText: 'Write your question here..',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  pollTypeQuestionIndex > 0
                                      ? Column(
                                          children: List.generate(
                                              pollTypeQuestionIndex, (index) {
                                            return Container(
                                              width: Get.width * 0.9,
                                              margin:
                                                  const EdgeInsets.only(bottom: 10),
                                              child: TextFormField(
                                                controller: postController,
                                                maxLines: 1,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Write your Option 1',
                                                  hintStyle: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      borderSide: const BorderSide(
                                                          color: Colors.black)),
                                                  suffixIcon: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          pollTypeQuestionIndex--;
                                                        });
                                                      },
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.black,
                                                      )),
                                                ),
                                              ),
                                            );
                                          }),
                                        )
                                      : Container(),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (pollTypeQuestionIndex < 3) {
                                          pollTypeQuestionIndex++;
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 120,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.add),
                                          Text('Add a Option')
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : isBlog
                                ? TextFormField(
                                    controller: postController,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      hintText: 'Post your blog',
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  )
                                : isProduct
                                    ? Column(
                                        children: [
                                          TextFormField(
                                            controller: postController,
                                            maxLines: 5,
                                            decoration: const InputDecoration(
                                              hintText:
                                                  'Write your product description',
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )
                                    : TextFormField(
                                        controller: postController,
                                        maxLines: 14,
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Write your question here..',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                    const Spacer(),
                    const Text(
                      'Select a tag',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff333333)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(categories.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                seletedIndex = index;
                              });
                            },
                            child: Container(
                              height: 37,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 6),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: seletedIndex == index
                                      ? const Color(0xffD8F1E9)
                                      : const Color(0xffF1F2F2)),
                              child: Row(
                                children: [
                                  Image.network(
                                    categories[index]['icon'],
                                    height: 29,
                                    width: 29,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    categories[index]['name'],
                                    style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xff000000),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    isImage || isBlog
                        ? SizedBox(
                            height: imgFile != null ? 150 : 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                imgFile == null
                                    ? Container()
                                    : Stack(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            margin: const EdgeInsets.only(
                                                bottom: 10),
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                    image: FileImage(imgFile!),
                                                    fit: BoxFit.cover)),
                                          ),
                                          Positioned(
                                            right: -5,
                                            top: -5,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  imgFile = null;
                                                });
                                              },
                                              child: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white),
                                                child: const Center(
                                                    child: Icon(
                                                  Icons.close,
                                                  size: 15,
                                                )),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return SizedBox(
                                            height: 120,
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  onTap: () {
                                                    openCamera();
                                                    Navigator.pop(context);
                                                  },
                                                  leading: const Icon(
                                                      Icons.camera_alt),
                                                  title: const Text('Camera'),
                                                ),
                                                ListTile(
                                                  onTap: () {
                                                    openGallery();
                                                    Navigator.pop(context);
                                                  },
                                                  leading:
                                                      const Icon(Icons.photo),
                                                  title: const Text('Gallery'),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 4),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.add),
                                            Text('Photo')
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                imgFile == null
                                    ? const Spacer()
                                    : const SizedBox(
                                        height: 20,
                                      ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    GestureDetector(
                      onTap: () async {
                        if (postController.text.isEmpty) {
                        } else {
                          isLoading = true;
                          setState(() {});

                          if (postType[postIndex] == 'Question & image') {
                            await communityVm
                                .uploadImage(path: imgFile?.path ?? '')
                                .then((value) async {
                              await communityVm
                                  .askQuestion(
                                cid: categories[seletedIndex]['cid'],
                                question: '${postController.text}||$value',
                                tags: [
                                  'questionWithImage',
                                  'internal',
                                ],
                                path: imgFile!.path,
                                file: imgFile,
                              )
                                  .then((value) {
                                isLoading = false;
                                setState(() {});
                                Get.back();
                              });
                            });
                          } else if (postType[postIndex] == 'Question') {
                            await communityVm.askQuestion(
                                cid: categories[seletedIndex]['cid'],
                                question: postController.text,
                                tags: [
                                  'question',
                                  'internal',
                                ]).then((value) {
                              isLoading = false;
                              setState(() {});
                              Get.back();
                            });
                          } else if (postType[postIndex] ==
                              'Product Recommendation') {
                            await communityVm.askQuestionProduct(
                              cid: categories[seletedIndex]['cid'],
                              question: postController.text,
                              tags: [
                                'product',
                                'internal',
                              ],
                            ).then((value) {
                              isLoading = false;
                              setState(() {});
                              Get.back();
                            });
                          } else if (postType[postIndex] == 'Blogs') {
                            await communityVm
                                .uploadImage(path: imgFile?.path ?? '')
                                .then((value) async {
                              await communityVm.askQuestion(
                                  cid: categories[seletedIndex]['cid'],
                                  question: '${postController.text}||$value',
                                  tags: [
                                    'blog',
                                    'internal',
                                  ]).then((value) {
                                isLoading = false;
                                setState(() {});
                                Get.back();
                              });
                            });
                          }
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black),
                            child: const Center(
                                child: Text(
                              'Post',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )),
                          )),
                    )
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
