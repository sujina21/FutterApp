import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:booking/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../viewmodels/global_ui_viewmodel.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late GlobalUIViewModel _ui;
  late AuthViewModel _authViewModel;
  String? productId;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _ui = Provider.of<GlobalUIViewModel>(context, listen: false);
    });
    super.initState();
  }

  Future<void> getInit() async {
    _ui.loadState(true);
    try{
      await _authViewModel.getBookingsUser();
    }catch(e){

    }
    _ui.loadState(false);
  }

  Future<void> cancelBooking(String bookingId) async {
    _ui.loadState(true);
    try {
      await _authViewModel.cancelBooking(bookingId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Cancelled Successful.")));
    //TODO: Cancel Booking Continues here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong. Please try again.")));
      print(e);
    }
    _ui.loadState(false);
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(builder: (context, authVM, child) {
      return Container(
        color:Colors.brown,
        child: RefreshIndicator(
          onRefresh: getInit,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child:
            authVM.bookingProduct == null ?
            Column(
              children: [
                Center(child: Text("Something went wrong")),
              ],
            ) :
            authVM.bookingProduct!.length == 0
                ? Column(
                    children: [
                      Center(child: Text("Please add to booking")),
                    ],
                  )
                : Column(children: [
                  SizedBox(height: 10,),
                    ...authVM.bookingProduct!.map(
                      (e) => InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("/single-product", arguments: e.id!);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            child: ListTile(
                              trailing: IconButton(
                                iconSize: 25,
                                onPressed: (){
                                    cancelBooking(e.id!);
                                },
                                  icon: Icon(Icons.delete_outlined, color: Colors.red,),
                              ),
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    e.imageUrl.toString(),
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context,
                                        Object exception, StackTrace? stackTrace) {
                                      return Image.asset(
                                        'assets/images/logo.png',
                                        width: 100,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )),
                              title: Text(e.productName.toString()),
                              subtitle: Text(e.productPrice.toString()),
                            ),
                          ),
                        ),
                      ),
                    )
                  ]),
          ),
        ),
      );
    });
  }
}
