import 'package:booking/models/product_model.dart';
import 'package:booking/models/user_model.dart';
import 'package:booking/repositories/auth_repositories.dart';
import 'package:booking/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../models/favorite_model.dart';
import '../repositories/booking_repositories.dart';
import '../repositories/favorite_repositories.dart';
import '../repositories/product_repositories.dart';

class AuthViewModel with ChangeNotifier {
  User? _user = FirebaseService.firebaseAuth.currentUser;

  User? get user => _user;

  UserModel? _loggedInUser;
  UserModel? get loggedInUser =>_loggedInUser;


  Future<void> login(String email, String password) async {
    try {
      var response = await AuthRepository().login(email, password);
      _user = response.user;
      _loggedInUser = await AuthRepository().getUserDetail(_user!.uid, _token);
      notifyListeners();
    } catch (err) {
      AuthRepository().logout();
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await AuthRepository().resetPassword(email);
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> register(UserModel user) async {
    try {
      var response = await AuthRepository().register(user);
      _user = response!.user;
      _loggedInUser = await AuthRepository().getUserDetail(_user!.uid, _token);
      notifyListeners();
    } catch (err) {
      AuthRepository().logout();
      rethrow;
    }
  }

  String? _token;
  String? get token =>_token;
  Future<void> checkLogin(String? token) async {
    try {
      _loggedInUser = await AuthRepository().getUserDetail(_user!.uid, token);
      _token = token;
      notifyListeners();
    } catch (err) {
      _user = null;
      AuthRepository().logout();
      rethrow;
    }
  }

  Future<void> logout() async{
    try{
      await AuthRepository().logout();
      _user = null;
      notifyListeners();
    }catch(e){
      rethrow;
    }
  }


  // Favorite Part
  FavoriteRepository _favoriteRepository = FavoriteRepository();
  List<FavoriteModel> _favorites = [];
  List<FavoriteModel> get favorites => _favorites;
  List<ProductModel>? _favoriteProduct;
  List<ProductModel>? get favoriteProduct => _favoriteProduct;

  Future<void> getFavoritesUser() async{
    try{
      var response = await _favoriteRepository.getFavoritesUser(loggedInUser!.userId!);
      _favorites=[];
      for (var element in response) {
        _favorites.add(element.data());
      }
      _favoriteProduct=[];
      if(_favorites.isNotEmpty){

        var productResponse = await ProductRepository().getProductFromList(_favorites.map((e) => e.productId).toList());
          for (var element in productResponse) {
            _favoriteProduct!.add(element.data());
          }
      }

      notifyListeners();
    }catch(e){
      print(e);
      _favorites = [];
      _favoriteProduct=null;
      notifyListeners();
    }
  }

  Future<void> favoriteAction(FavoriteModel? isFavorite, String productId) async{
    try{
      await _favoriteRepository.favorite(isFavorite, productId, loggedInUser!.userId! );
      await getFavoritesUser();
      notifyListeners();
    }catch(e){
      _favorites = [];
      notifyListeners();
    }
  }


  // Booking details part
  BookingRepository _bookingRepository = BookingRepository();
  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;
  List<ProductModel>? _bookingProduct;
  List<ProductModel>? get bookingProduct => _bookingProduct;

  Future<void> getBookingsUser() async{
    try{
      var response = await _bookingRepository.getBookingsUser(loggedInUser!.userId!);
      _bookings=[];
      for (var element in response) {
        _bookings.add(element.data());
      }
      _bookingProduct=[];
      if(_bookings.isNotEmpty){

        var productResponse = await ProductRepository().getProductFromList(_bookings.map((e) => e.productId).toList());
        for (var element in productResponse) {
          _bookingProduct!.add(element.data());
        }
      }

      notifyListeners();
    }catch(e){
      print(e);
      _bookings = [];
      _bookingProduct=null;
      notifyListeners();
    }
  }

  Future<void> addBooking(String date, String time, String productId) async{
    try{
      await _bookingRepository.booking(productId, loggedInUser!.userId!,date,time );
      await getBookingsUser();
      notifyListeners();
    }catch(e){
      _bookings = [];
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async{
    try{
      await _bookingRepository.cancelBooking(bookingId);
      await getBookingsUser();
      notifyListeners();
    }catch(e){
      print(e);
      // _bookings=[];
      notifyListeners();
    }
  }

  List<ProductModel>? _myProduct;
  List<ProductModel>? get myProduct => _myProduct;

  Future<void> getMyProducts() async{
    try{
      var productResponse = await ProductRepository().getMyProducts(loggedInUser!.userId!);
      _myProduct=[];
      for (var element in productResponse) {
        _myProduct!.add(element.data());
      }
      notifyListeners();
    }catch(e){
      print(e);
      _myProduct=null;
      notifyListeners();
    }
  }

  Future<void> addMyProduct(ProductModel product)async {
    try{
      await ProductRepository().addProducts(product: product);

      await getMyProducts();
      notifyListeners();
    }catch(e){

    }
  }


  Future<void> editMyProduct(ProductModel product, String productId)async {
    try{
      await ProductRepository().editProduct(product: product, productId: productId);
      await getMyProducts();
      notifyListeners();
    }catch(e){

    }
  }
  Future<void> deleteMyProduct(String productId) async{
    try{
      await ProductRepository().removeProduct(productId, loggedInUser!.userId!);
      await getMyProducts();
      notifyListeners();
    }catch(e){
      print(e);
      _myProduct=null;
      notifyListeners();
    }
  }

}
