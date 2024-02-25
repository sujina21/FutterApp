import 'package:booking/models/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_service.dart';

class BookingRepository{
  CollectionReference<BookingModel> bookingRef = FirebaseService.db.collection("bookings")
      .withConverter<BookingModel>(
    fromFirestore: (snapshot, _) {
      return BookingModel.fromFirebaseSnapshot(snapshot);
    },
    toFirestore: (model, _) => model.toJson(),
  );
  Future<List<QueryDocumentSnapshot<BookingModel>>> getBookings(String productId, String userId) async {
    try {
      var data = await bookingRef.where("user_id", isEqualTo: userId).where("product_id", isEqualTo: productId).get();
      var bookings = data.docs;
      return bookings;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot<BookingModel>>> getBookingsUser(String userId) async {
    try {
      var data = await bookingRef.where("user_id", isEqualTo: userId).get();
      var bookings = data.docs;
      return bookings;
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  Future<bool> booking(String productId, String userId,String bookingDate, String bookingTime)  async{
    try {
        await bookingRef.add(BookingModel(userId: userId, productId: productId,bookingDate: bookingDate,bookingTime: bookingTime));
      return true;
    } catch (err) {
      rethrow;
    }
  }


  Future<bool> cancelBooking(String bookingId)  async{
    try {
      await bookingRef.doc(bookingId).delete();
      var data = await bookingRef.where("product_id", isEqualTo: bookingId).get();
      var bookings = data.docs;
      for (var product in bookings){
        product.reference.delete();
      }
      return true;
    } catch (err) {
      rethrow;
    }
  }
}