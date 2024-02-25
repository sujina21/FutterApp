import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class CategoryRepository{
  CollectionReference<CategoryModel> categoryRef = FirebaseService.db.collection("categories")
      .withConverter<CategoryModel>(
    fromFirestore: (snapshot, _) {
      return CategoryModel.fromFirebaseSnapshot(snapshot);
    },
    toFirestore: (model, _) => model.toJson(),
  );
    Future<List<QueryDocumentSnapshot<CategoryModel>>> getCategories() async {
    try {
      var data = await categoryRef.get();
      bool hasData = data.docs.isNotEmpty;
      if(!hasData){
        makeCategory().forEach((element) async {
          await categoryRef.add(element);
        });
      }
      final response = await categoryRef.get();
      var category = response.docs;
      return category;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  Future<DocumentSnapshot<CategoryModel>>  getCategory(String categoryId) async {
      try{
        print(categoryId);
        final response = await categoryRef.doc(categoryId).get();
        return response;
      }catch(e){
        rethrow;
      }
  }

  List<CategoryModel> makeCategory(){
      return [
        CategoryModel(categoryName: "Mobile Phones and Accessories", status: "active", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrR4BTrZVg7NOJuWct_GNDFF2IiRaAtE-pCsk34yTpLQ&s"),
        CategoryModel(categoryName: "Automobile", status: "active", imageUrl: "https://i2-prod.dailyrecord.co.uk/incoming/article25217715.ece/ALTERNATES/s615/0_Daily-Record-Road-Record.jpg"),
        CategoryModel(categoryName: "Apparel", status: "active", imageUrl: "https://www.techprevue.com/wp-content/uploads/2016/05/online-apparel-business.jpg"),
        CategoryModel(categoryName: "Beauty", status: "active", imageUrl: ""),
        CategoryModel(categoryName: "Music Instruments", status: "active", imageUrl: "https://img.texasmonthly.com/2013/04/ESSENTIALS_680X382.jpg"),
      ];
  }



}