
import 'package:cinetpay/cinetpay.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_url.dart';



class CinetPayCheckoutScreen extends StatefulWidget {

  static const String path = '/checkout-abonnement';

  final int? ticketsTotal;
  final String name;
  final String email;
  final String mobileNo;
  final bool isAcceptTerms;
  final int? totalAmount;

  CinetPayCheckoutScreen({super.key, this.ticketsTotal, required this.name, required this.email, required this.mobileNo, required this.isAcceptTerms, this.totalAmount});

  @override
  State<CinetPayCheckoutScreen> createState() => _CinetPayCheckoutScreenState();
}


class _CinetPayCheckoutScreenState extends State<CinetPayCheckoutScreen> {


  final String? _transactionId = DateTime.now().millisecondsSinceEpoch.toString();


  // void _processToBookEvent(dynamic paymentStatus) async {
  //   print('this is payment status: ${paymentStatus['status']}');
  //
  //
  //   if (paymentStatus['status'] == 'ACCEPTED') {
  //
  //     await AttendeeEventsViewModel().saveBookingsInEvent(attendeeBookingModel, context, []).then((v) async {
  //       showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (_) {
  //             return CustomDialog(
  //               subtitle: '${AppLocalizations.of(context)!.youHaveBookedAnOrder} ${AppLocalizations.of(context)!.forText}\n ${widget.eventModel.eventTitle}.',
  //               Title: AppLocalizations.of(context)!.allBookedForYou,
  //               image: 'images/DoneLogo.png',
  //               subtitleTwo: AppLocalizations.of(context)!.enjoyTheEvent,
  //               child: Column(
  //                 children: [
  //                   PrimaryButtonTwo(
  //                     title: AppLocalizations.of(context)!.viewETicket,
  //                     onPressed: () {
  //                       context.goNamed(
  //                         ETicketQRCodeScreen.routeName,
  //                         extra: widget.eventModel,
  //                         queryParameters: {
  //                           "eventId": attendeeBookingModel.eventId,
  //                           "attendeeName": attendeeBookingModel.attendeeName,
  //                           "bookedTickets": json.encode(widget.bookTickets),
  //                           "mobileNo": widget.mobileNo,
  //                           "totalTickets": widget.ticketsTotal.toString(),
  //                         }
  //                       );
  //                     },
  //                   ),
  //                   SizedBox(height: 10),
  //                   CustomButton(
  //                     title: AppLocalizations.of(context)!.goToHomeScreen,
  //                     onPressed: () {
  //                       context.go(AttendeeBottomNavBar.routeName);
  //                     },
  //                   )
  //                 ],
  //               ),
  //             );
  //           });
  //
  //       DocumentSnapshot snap = await FirebaseFirestore.instance.collection("attendees").doc(FirebaseAuth.instance.currentUser!.uid).get();
  //
  //       NotificationServices().sendPushNotification(userId: widget.eventModel.uId, body: "${widget.name} has booked tickets in your event: ${widget.eventModel.eventTitle}", title: widget.eventModel.eventTitle);
  //       NotificationServices().addNotificationInDB(context: context, toUserId: widget.eventModel.uId, title: "${widget.name} has booked tickets in your event: ${widget.eventModel.eventTitle}", userImage: snap["photo"]);
  //     });
  //
  //     EasyLoading.showInfo("Paiement effectuer avec success...");
  //   }
  // }


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    print("TRANSAC-ID : $_transactionId");

    return Scaffold(
      body: Container(
        child: Center(
          child: CinetPayCheckout(
              title: 'KELFILM-PAYMENT',
              titleBackgroundColor: null,
              configData: <String, Object?>{'site_id': ApiUrl.cinetPaySiteId, 'apikey': ApiUrl.cinetPayApiKey},
              paymentData: <String, Object?>{
                'transaction_id': _transactionId,
                'amount': 100,
                'currency': 'XOF',
                'channels': 'ALL',
                'description': 'Ticket pour'
              },
              waitResponse: (response) {
               //  _processToBookEvent(response);
                context.pop("success apyment;");
              },
              onError: (error) {
                print('UNE ERREUR EST SURVENUE => ${error}');
                context.pop("failed apyment;");
              }),
        ),
      ),
    );
  }
}
