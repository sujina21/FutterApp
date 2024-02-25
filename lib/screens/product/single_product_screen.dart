import 'package:booking/models/booking_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:booking/models/favorite_model.dart';
import 'package:booking/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../repositories/cart_repositories.dart';
import '../../viewmodels/global_ui_viewmodel.dart';
import '../../viewmodels/single_product_viewmodel.dart';

class SingleProductScreen extends StatefulWidget {
  const SingleProductScreen({Key? key}) : super(key: key);

  @override
  State<SingleProductScreen> createState() => _SingleProductScreenState();
}

class _SingleProductScreenState extends State<SingleProductScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SingleProductViewModel>(
        create: (_) => SingleProductViewModel(), child: SingleProductBody());
  }
}

class SingleProductBody extends StatefulWidget {
  const SingleProductBody({Key? key}) : super(key: key);

  @override
  State<SingleProductBody> createState() => _SingleProductBodyState();
}

class _SingleProductBodyState extends State<SingleProductBody> {
  late SingleProductViewModel _singleProductViewModel;
  late GlobalUIViewModel _ui;
  late AuthViewModel _authViewModel;
  String? productId;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _singleProductViewModel = Provider.of<SingleProductViewModel>(context, listen: false);
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _ui = Provider.of<GlobalUIViewModel>(context, listen: false);
      final args = ModalRoute.of(context)!.settings.arguments.toString();
      setState(() {
        productId = args;
      });
      print(args);
      getData(args);
    });
    super.initState();
  }

  Future<void> getData(String productId) async {
    _ui.loadState(true);
    try {
      await _authViewModel.getFavoritesUser();
      await _singleProductViewModel.getProducts(productId);
    } catch (e) {}
    _ui.loadState(false);
  }

  Future<void> favoritePressed(FavoriteModel? isFavorite, String productId) async {
    _ui.loadState(true);
    try {
      await _authViewModel.favoriteAction(isFavorite, productId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Favorite updated.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong. Please try again.")));
      print(e);
    }
    _ui.loadState(false);
  }

  Future<void> confirmBooking(String date, String time, String productId) async {
    _ui.loadState(true);
    try {
      await _authViewModel.addBooking(date,time, productId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Successfull.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong. Please try again.")));
      print(e);
    }
    _ui.loadState(false);
  }

  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Consumer2<SingleProductViewModel, AuthViewModel>(
        builder: (context, singleProductVM, authVm, child) {
      return singleProductVM.product == null
          ? Scaffold(
              body: Container(
                child: Text("Error"),
              ),
            )
          : singleProductVM.product!.id == null
              ? Scaffold(
                  body: Center(
                    child: Container(
                      child: Text("Please wait..."),
                    ),
                  ),
                )
              : Scaffold(
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

                  appBar: AppBar(
                    backgroundColor: Colors.black54,
                    actions: [
                      Builder(builder: (context) {
                        FavoriteModel? isFavorite;
                        try {
                          isFavorite = authVm.favorites.firstWhere(
                              (element) => element.productId == singleProductVM.product!.id);
                        } catch (e) {}

                        return IconButton(
                            onPressed: () {
                              print(singleProductVM.product!.id!);
                              favoritePressed(isFavorite, singleProductVM.product!.id!);
                            },
                            icon: Icon(
                              Icons.favorite,
                              color: isFavorite != null ? Colors.red : Colors.white,
                            ));
                      })
                    ],
                  ),
                  backgroundColor: Color(0xFFf5f5f4),
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.network(
                          singleProductVM.product!.imageUrl.toString(),
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/images/logo.png',
                              height: 400,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            decoration: BoxDecoration(color: Colors.white70),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rs. " + singleProductVM.product!.productPrice.toString(),
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  singleProductVM.product!.productName.toString(),
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  singleProductVM.product!.productDescription.toString(),
                                  style: TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                                SizedBox(height: 10,),
                                GestureDetector(onTap:()=>_selectDateTime(context, singleProductVM.product!.id!),
                                  child: Container(
                                  color: Colors.blue,
                                  height: 50.0, // Set your desired height
                                  width: double.infinity, // Stretch horizontally
                                  child: Center(
                                    child: Text(
                                      'Confirm Booking',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                );
    });
  }

  void _showDateTimePicker(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Date and Time'),
          content: Container(
            height: 75.0,
            child: Column(
              children: [
                Row(children: [
                  Text("Selected Date:",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 14.0),),
                  SizedBox(width: 10.0,),
                  Text(_formatDate(selectedDate),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green,fontSize: 14.0))
                ],),
                SizedBox(height: 10.0,),
                Row(children: [
                  Text("Selected Time:",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 14.0),),
                  SizedBox(width: 10.0,),
                  Text(formatTimeOfDay(selectedTime),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green,fontSize: 18.0))
                ],),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                confirmBooking(_formatDate(selectedDate),formatTimeOfDay(selectedTime),productId);
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                _selectDateTime(context,productId);
              },
              child: Text('Choose Again'),
            ),
          ],
        );
      },
    );
  }


  // Function to show the date-time picker
  void _selectDateTime(BuildContext context, String productId) async {
    await _selectDate(context);
    await _selectTime(context);


    // Handle the selected date and time as needed
    print('Selected Date: ${_formatDate(selectedDate)}');
    print('Selected Time: ${formatTimeOfDay(selectedTime)}');
    _showDateTimePicker(context,productId);
  }

  // Format a DateTime object to "yyyy-MM-dd" string
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    String hour = timeOfDay.hour.toString().padLeft(2, '0');
    String minute = timeOfDay.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat.Hm().format(time); // 'H' for 24-hour format, 'h' for 12-hour format
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
}
