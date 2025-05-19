import 'package:flutter/material.dart';
import 'user_topics_model.dart';

Widget activityWidget({Topics? userTopics}){
  return  Align(
    alignment: Alignment.topCenter,
    child: Container(
        margin: const EdgeInsets.only( top: 20),
        padding: const EdgeInsets.only(top: 5, left: 12, right: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Container(
          margin: const EdgeInsets.only( left: 12, right: 12, bottom: 12,top: 20),
          padding: const EdgeInsets.only(top: 5, left: 12, right: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          ),

          child: Column(
            children: [
              Row(
                  children: [
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
                            shape: BoxShape.circle  ,
                            color: Colors.pink.withOpacity(0.3)
                        ),
                        child: Center(child: Text(userTopics?.user?.username?.split('')[0].toUpperCase()??'', style: TextStyle(
                            color: Colors.pink.withOpacity(0.6),
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),)),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(userTopics?.user?.username??'', style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        const Text('Wellness Expert', style: TextStyle(
                            fontSize: 10 ,
                            fontWeight: FontWeight.w200
                        ),),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.pink.withOpacity(0.2),
                      ),
                      child: Text(userTopics?.category?.name??''),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add , color: Colors.black, size: 15,),
                          Text('Follow', style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400
                          ),)
                        ],
                      ),
                    ),
                  ]
              ),
              const SizedBox(height: 5,),
              const Divider(thickness: 1,),
              const SizedBox(height: 10,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(userTopics?.title??'',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400
                ),),
              ),
              // Spacer(),
              // Image.asset('assets/images/alarmClock.png', scale: 4,),
              const SizedBox(height: 5,),
              const Divider(thickness: 1,),
              const SizedBox(height: 5,),
              Row(
                children: [
                  const Icon(Icons.share, size: 15,),
                  const SizedBox(width: 5,),
                  const Text('Share'),
                  const Spacer(),
                  const Icon(Icons.favorite_border, size: 15,),
                  const SizedBox(width: 10,),
                  Text(userTopics?.thumbs?.length.toString()??'', style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                  const SizedBox(width: 5,),
                  const Text('Found it usefeul', style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 12
                  ),),
                  const SizedBox(width: 15,),
                  const Icon(Icons.message, size: 15,),
                  const SizedBox(width: 5,),
                  Text(userTopics?.postcount.toString()??'', style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                  const SizedBox(width: 5,),
                  const Text('Comments', style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 12
                  ),),


                ],
              )


            ],
          ),
        )

    ),
  );
}

Widget questionWidget(){
  return  Container(
      margin: const EdgeInsets.only(  bottom: 8,top: 20),
      padding: const EdgeInsets.only(top: 5, left: 12, right: 10, bottom: 12),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
        child: Column(
          children: [
            Row(
                children: [
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
                          shape: BoxShape.circle  ,
                          color: Colors.pink.withOpacity(0.3)
                      ),
                      child: Center(child: Text('S', style: TextStyle(
                          color: Colors.pink.withOpacity(0.6),
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),)),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: const [
                              Text('Siddharth', style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300
                              ),),
                              SizedBox(height: 5,),
                              Text('wellness Expert', style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w200
                              ),),
                            ],
                          ),

                        ],
                      ),
                      const SizedBox(height: 5,),
                    ],
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: const Text('Hair Care', style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.add, size: 15,),
                        Text('Follow', style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),),
                      ],
                    ),
                  ),


                ]
            ),
            const SizedBox(height: 5,),
            const Divider(thickness: 1,),
            const SizedBox(height: 5,),
            const Text('sadsasadasdjijkssd sdskdls sd sld  sadas sad asdas dsasdjad sad sad assadlksad sad sakd  sadlas d saldk sas..'),
            const SizedBox(height: 5,),
            Image.asset('assets/images/appOnlyDiscount.jpg', scale: 2,),
            const SizedBox(height: 10,),
            const Divider(thickness: 1,),
            const SizedBox(height: 5,),
            Row(
              children: const [
                Icon(Icons.share, size: 15,),
                SizedBox(width: 5,),
                Text('Share'),
                Spacer(),
                Icon(Icons.favorite_border, size: 15,),
                SizedBox(width: 10,),
                Text('7', style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),),
                SizedBox(width: 5,),
                Text('Found it usefeul', style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 12
                ),),
                SizedBox(width: 15,),
                Icon(Icons.message, size: 15,),
                SizedBox(width: 5,),
                Text('7', style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),),
                SizedBox(width: 5,),
                Text('Comments', style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 12
                ),),


              ],
            )
          ],
        ),
      )

  );
}