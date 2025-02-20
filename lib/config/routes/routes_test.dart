import 'package:appointement/config/routes/routes.dart';
import 'package:appointement/features/appointments/views/add_apointment.dart';
import 'package:appointement/features/appointments/views/edit_appointments.dart';
import 'package:appointement/features/auth/views/edit_profile.dart';
import 'package:appointement/features/auth/views/login_email.dart';
import 'package:appointement/features/auth/views/login_view.dart';
import 'package:appointement/features/auth/views/verification_view.dart';
import 'package:appointement/features/contacts/views/add_contact.dart';
import 'package:appointement/features/contacts/views/finedContact.dart';
import 'package:appointement/features/contacts/views/friends_request.dart';
import 'package:appointement/features/landingPage/landing_page.dart';
import 'package:appointement/features/notifications/views/notification_view.dart';
import 'package:appointement/features/settings/views/settings_view.dart';
import 'package:appointement/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';


Route<dynamic> onGenerate(RouteSettings settings) {

  switch (settings.name){
    case AppRoutes.homePageRoute:
      return CupertinoPageRoute(
        builder: (_) => HomePage()
      );
    case AppRoutes.newAppointment:
      return CupertinoPageRoute(
        builder: (_) => const Appointments()
      );

    case AppRoutes.editAppointment:
      return CupertinoPageRoute(
        builder: (_) =>  EditAppointments(),
        settings: settings,
      );
    
    case AppRoutes.settings:
      return CupertinoPageRoute(
        builder: (_) =>  SettingsView(),
      );
    case AppRoutes.notificationPage:
      return CupertinoPageRoute(
        builder: (_) =>  NotificationView(),
      );

    case AppRoutes.editProfilePage:
      return CupertinoPageRoute(
        builder: (_) => EditProfile(),
      );
    
    case AppRoutes.AddContactPage:
      return CupertinoPageRoute(
        builder: (_) => AddContact(),
      );
    default:
      return CupertinoPageRoute(
        builder: (_) => LandingPage()
      );
  }
}

