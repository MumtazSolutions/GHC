import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../models/user_model.dart';
import 'community_provider.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({Key? key}) : super(key: key);

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  int seletedIndex = 0;
  File? imgFile;
  bool isAnonymous = false;
  bool isLoading = false;
  final imgPicker = ImagePicker();
  var categories;
  List selectedCategories = [];
  void openCamera(context, {bool? isList}) async {
    var imgCamera = (await imgPicker.pickImage(
        imageQuality: 50, source: ImageSource.camera))!;
    imgFile = File(imgCamera.path);
    setState(() {});
  }

  void openGallery(context, {bool? isList}) async {
    var imgGallery = (await imgPicker.pickImage(
        imageQuality: 50, source: ImageSource.gallery));
    if (imgGallery?.path == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('image not supported')));
      return;
    }
    imgFile = File(imgGallery!.path);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    selectedCategories = List.from(communityVm.categories['categories']);

    var elementsToRemove = <Map<String, dynamic>>[];
    for (var element in communityVm.categories['categories']) {
      if (element['name'] == 'All') {
        elementsToRemove.add(element);
      }
    }

    selectedCategories
        .removeWhere((element) => elementsToRemove.contains(element));
    categories = selectedCategories;
  }

  final TextEditingController postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var communityVm = Provider.of<CommunityProvider>(context, listen: false);
    var user = Provider.of<UserModel>(context, listen: false).user;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Ask a question'),
        ),
        body: isLoading == false
            ? Container(
                color: const Color(0xffFFFFFF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
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
                              user?.firstName?[0] ?? '',
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
                          isAnonymous ? 'Anonymous' : user?.firstName ?? '',
                          style: const TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xff333333),
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    TextFormField(
                      controller: postController,
                      maxLines: imgFile == null ? 14 : 11,
                      decoration: const InputDecoration(
                        hintText: 'Write Something',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // const Spacer(),
                    const Text(
                      'Select a tag',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                    imgFile == null
                        ? Container()
                        : Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 10),
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                                        openCamera(context);
                                        Navigator.pop(context);
                                      },
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Camera'),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        openGallery(context);
                                        Navigator.pop(context);
                                      },
                                      leading: const Icon(Icons.photo),
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
                                border: Border.all(color: const Color(0xffD0D0D0)),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            child: Row(
                              children: const [Icon(Icons.add), Text('Photo')],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Transform.scale(
                            scale: 1.8,
                            child: Checkbox(
                              value: isAnonymous,
                              onChanged: (value) {
                                setState(() {
                                  isAnonymous = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 0.2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text('Hide my name')
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (postController.text.isEmpty) {
                          await Fluttertoast.showToast(
                            msg: 'Please enter valid text to post',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey[600],
                            textColor: Colors.white
                          );
                        } else {
                          isLoading = true;
                          setState(() {});
                          try {
                            if (imgFile != null) {
                              await communityVm
                                  .uploadImage(
                                path: imgFile!.path,
                              )
                                  .then((value) async {
                                await communityVm
                                    .askQuestion(
                                        cid: categories[seletedIndex]['cid'],
                                        question:
                                            '${postController.text}||$value',
                                        tags: [
                                          'questionWithImage',
                                          isAnonymous
                                              ? 'anonymous'
                                              : 'notAnonymous',
                                        ],
                                        path: imgFile!.path,
                                        file: imgFile!)
                                    .then((value) async {
                                  await communityVm.fetchQuestion();
                                  isLoading = false;
                                  setState(() {});
                                  Get.back();
                                });
                              });
                            } else {
                              await communityVm.askQuestion(
                                  cid: categories[seletedIndex]['cid'],
                                  question: postController.text,
                                  tags: [
                                    'question',
                                    isAnonymous ? 'anonymous' : 'notAnonymous'
                                  ]).then((value) async {
                                await communityVm.fetchQuestion();
                                isLoading = false;
                                setState(() {});
                                Get.back();
                              });
                            }
                          } catch (e) {
                            printLog(e);
                            throw const HttpException('Some error occured. Please try again later');
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
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Posting your question. Do not refresh'),
                    SizedBox(height: 20,),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
      ),
    );
  }
}
