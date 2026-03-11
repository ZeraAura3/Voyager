import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Voyager'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @rollNo.
  ///
  /// In en, this message translates to:
  /// **'Roll Number'**
  String get rollNo;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signupHere.
  ///
  /// In en, this message translates to:
  /// **'Sign up here'**
  String get signupHere;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @findRide.
  ///
  /// In en, this message translates to:
  /// **'Find a Ride'**
  String get findRide;

  /// No description provided for @postRide.
  ///
  /// In en, this message translates to:
  /// **'Post a Ride'**
  String get postRide;

  /// No description provided for @myRides.
  ///
  /// In en, this message translates to:
  /// **'My Rides'**
  String get myRides;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @swaps.
  ///
  /// In en, this message translates to:
  /// **'Swaps'**
  String get swaps;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @pricePerSeat.
  ///
  /// In en, this message translates to:
  /// **'Price per Seat'**
  String get pricePerSeat;

  /// No description provided for @availableSeats.
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get availableSeats;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @availableRides.
  ///
  /// In en, this message translates to:
  /// **'Available Rides'**
  String get availableRides;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @activeTrips.
  ///
  /// In en, this message translates to:
  /// **'Active Trips'**
  String get activeTrips;

  /// No description provided for @noRidesFound.
  ///
  /// In en, this message translates to:
  /// **'No rides found'**
  String get noRidesFound;

  /// No description provided for @noActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'No active trips'**
  String get noActiveTrips;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @genderPreference.
  ///
  /// In en, this message translates to:
  /// **'Gender Preference'**
  String get genderPreference;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get maxPrice;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @phoneNo.
  ///
  /// In en, this message translates to:
  /// **'Phone No.'**
  String get phoneNo;

  /// No description provided for @bookRide.
  ///
  /// In en, this message translates to:
  /// **'Book Ride'**
  String get bookRide;

  /// No description provided for @seatsToBook.
  ///
  /// In en, this message translates to:
  /// **'Seats to Book'**
  String get seatsToBook;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking Cancelled'**
  String get bookingCancelled;

  /// No description provided for @ridePosted.
  ///
  /// In en, this message translates to:
  /// **'Ride Posted Successfully'**
  String get ridePosted;

  /// No description provided for @rideDeleted.
  ///
  /// In en, this message translates to:
  /// **'Ride Deleted'**
  String get rideDeleted;

  /// No description provided for @myPostedRides.
  ///
  /// In en, this message translates to:
  /// **'My Posted Rides'**
  String get myPostedRides;

  /// No description provided for @noPostedRides.
  ///
  /// In en, this message translates to:
  /// **'No posted rides yet'**
  String get noPostedRides;

  /// No description provided for @postNewRide.
  ///
  /// In en, this message translates to:
  /// **'Post New Ride'**
  String get postNewRide;

  /// No description provided for @departure.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @departureDate.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDate;

  /// No description provided for @departureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// No description provided for @joinRequests.
  ///
  /// In en, this message translates to:
  /// **'Join Requests'**
  String get joinRequests;

  /// No description provided for @swapRequests.
  ///
  /// In en, this message translates to:
  /// **'Swap Requests'**
  String get swapRequests;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequests;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request Approved'**
  String get requestApproved;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request Rejected'**
  String get requestRejected;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @activeTickets.
  ///
  /// In en, this message translates to:
  /// **'Active Tickets'**
  String get activeTickets;

  /// No description provided for @tradeType.
  ///
  /// In en, this message translates to:
  /// **'Trade Type'**
  String get tradeType;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @journeyDate.
  ///
  /// In en, this message translates to:
  /// **'Journey Date'**
  String get journeyDate;

  /// No description provided for @journeyTime.
  ///
  /// In en, this message translates to:
  /// **'Journey Time'**
  String get journeyTime;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @postTicket.
  ///
  /// In en, this message translates to:
  /// **'Post Ticket'**
  String get postTicket;

  /// No description provided for @ticketPosted.
  ///
  /// In en, this message translates to:
  /// **'Ticket Posted Successfully'**
  String get ticketPosted;

  /// No description provided for @noTicketsFound.
  ///
  /// In en, this message translates to:
  /// **'No tickets found'**
  String get noTicketsFound;

  /// No description provided for @sendSwapRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Swap Request'**
  String get sendSwapRequest;

  /// No description provided for @swapRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Swap Request Sent'**
  String get swapRequestSent;

  /// No description provided for @myPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'My Pending Requests'**
  String get myPendingRequests;

  /// No description provided for @userHistory.
  ///
  /// In en, this message translates to:
  /// **'User History'**
  String get userHistory;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ride.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get ride;

  /// No description provided for @trade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get trade;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistoryFound;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request Cancelled'**
  String get requestCancelled;

  /// No description provided for @bookingRequest.
  ///
  /// In en, this message translates to:
  /// **'Booking Request'**
  String get bookingRequest;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @cabServices.
  ///
  /// In en, this message translates to:
  /// **'Cab Services'**
  String get cabServices;

  /// No description provided for @trades.
  ///
  /// In en, this message translates to:
  /// **'Trades'**
  String get trades;

  /// No description provided for @findRides.
  ///
  /// In en, this message translates to:
  /// **'Find Rides'**
  String get findRides;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @seatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'seats available'**
  String get seatsAvailable;

  /// No description provided for @perSeat.
  ///
  /// In en, this message translates to:
  /// **'per seat'**
  String get perSeat;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @whereHeading.
  ///
  /// In en, this message translates to:
  /// **'Where are you heading?'**
  String get whereHeading;

  /// No description provided for @fromWhere.
  ///
  /// In en, this message translates to:
  /// **'From where?'**
  String get fromWhere;

  /// No description provided for @whereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// No description provided for @searchRides.
  ///
  /// In en, this message translates to:
  /// **'Search Rides'**
  String get searchRides;

  /// No description provided for @filterRides.
  ///
  /// In en, this message translates to:
  /// **'Filter Rides'**
  String get filterRides;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @yourActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'Your Active Trips'**
  String get yourActiveTrips;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'CONFIRMED'**
  String get confirmed;

  /// No description provided for @postedBy.
  ///
  /// In en, this message translates to:
  /// **'Posted by {name}'**
  String postedBy(String name);

  /// No description provided for @beFirstToPost.
  ///
  /// In en, this message translates to:
  /// **'Be the first to post a ride!'**
  String get beFirstToPost;

  /// No description provided for @noRidesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No rides available'**
  String get noRidesAvailable;

  /// No description provided for @nSeats.
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String nSeats(int count);

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Search Results ({count})'**
  String searchResultsCount(int count);

  /// No description provided for @shareYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Share your journey with others'**
  String get shareYourJourney;

  /// No description provided for @enterPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter pickup location'**
  String get enterPickupLocation;

  /// No description provided for @enterDestination.
  ///
  /// In en, this message translates to:
  /// **'Enter destination'**
  String get enterDestination;

  /// No description provided for @pricePerSeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per Seat (₹)'**
  String get pricePerSeatLabel;

  /// No description provided for @passengerPreference.
  ///
  /// In en, this message translates to:
  /// **'Passenger Preference'**
  String get passengerPreference;

  /// No description provided for @noRidesPostedYet.
  ///
  /// In en, this message translates to:
  /// **'No rides posted yet'**
  String get noRidesPostedYet;

  /// No description provided for @ridePostedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ride posted successfully!'**
  String get ridePostedSuccess;

  /// No description provided for @enterFromToLocations.
  ///
  /// In en, this message translates to:
  /// **'Please enter From and To locations'**
  String get enterFromToLocations;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Please select date and time'**
  String get selectDateAndTime;

  /// No description provided for @enterPricePerSeat.
  ///
  /// In en, this message translates to:
  /// **'Please enter price per seat'**
  String get enterPricePerSeat;

  /// No description provided for @failedToPostRide.
  ///
  /// In en, this message translates to:
  /// **'Failed to post ride'**
  String get failedToPostRide;

  /// No description provided for @manageRequests.
  ///
  /// In en, this message translates to:
  /// **'Manage your incoming requests'**
  String get manageRequests;

  /// No description provided for @noJoinRequests.
  ///
  /// In en, this message translates to:
  /// **'No join requests'**
  String get noJoinRequests;

  /// No description provided for @bookingAppearsHere.
  ///
  /// In en, this message translates to:
  /// **'When someone books your ride, it will appear here'**
  String get bookingAppearsHere;

  /// No description provided for @noSwapRequests.
  ///
  /// In en, this message translates to:
  /// **'No swap requests'**
  String get noSwapRequests;

  /// No description provided for @swapAppearsHere.
  ///
  /// In en, this message translates to:
  /// **'When someone requests to swap a ticket, it will appear here'**
  String get swapAppearsHere;

  /// No description provided for @bookingApproved.
  ///
  /// In en, this message translates to:
  /// **'Booking approved!'**
  String get bookingApproved;

  /// No description provided for @bookingRejected.
  ///
  /// In en, this message translates to:
  /// **'Booking rejected'**
  String get bookingRejected;

  /// No description provided for @swapRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Swap request accepted!'**
  String get swapRequestAccepted;

  /// No description provided for @swapRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Swap request rejected'**
  String get swapRequestRejected;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @ticket.
  ///
  /// In en, this message translates to:
  /// **'TICKET'**
  String get ticket;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @rideShare.
  ///
  /// In en, this message translates to:
  /// **'RideShare'**
  String get rideShare;

  /// No description provided for @shareRidesSaveMoney.
  ///
  /// In en, this message translates to:
  /// **'Share rides, save money, make friends'**
  String get shareRidesSaveMoney;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterYourPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @enterRegisteredEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address and we\'ll send you a link to reset your password.'**
  String get enterRegisteredEmail;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your email.'**
  String get resetLinkSent;

  /// No description provided for @userDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'User data not found. Please sign up again.'**
  String get userDataNotFound;

  /// No description provided for @noUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email'**
  String get noUserFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountAndStart.
  ///
  /// In en, this message translates to:
  /// **'Create your account and start sharing rides'**
  String get createAccountAndStart;

  /// No description provided for @studentEmail.
  ///
  /// In en, this message translates to:
  /// **'Student Email'**
  String get studentEmail;

  /// No description provided for @studentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentId;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// No description provided for @vehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModel;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak'**
  String get passwordTooWeak;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email/phone'**
  String get accountAlreadyExists;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterYourName;

  /// No description provided for @enterStudentId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your student ID'**
  String get enterStudentId;

  /// No description provided for @enterLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your license number'**
  String get enterLicenseNumber;

  /// No description provided for @enterVehicleModel.
  ///
  /// In en, this message translates to:
  /// **'Please enter your vehicle model'**
  String get enterVehicleModel;

  /// No description provided for @enterVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your vehicle number'**
  String get enterVehicleNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @availableDrivers.
  ///
  /// In en, this message translates to:
  /// **'Available drivers in your area'**
  String get availableDrivers;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noDriversAvailable.
  ///
  /// In en, this message translates to:
  /// **'No drivers available'**
  String get noDriversAvailable;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @rides.
  ///
  /// In en, this message translates to:
  /// **'rides'**
  String get rides;

  /// No description provided for @otherRoutes.
  ///
  /// In en, this message translates to:
  /// **'Other Routes:'**
  String get otherRoutes;

  /// No description provided for @routeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Route not set'**
  String get routeNotSet;

  /// No description provided for @priceNotSet.
  ///
  /// In en, this message translates to:
  /// **'Price not set'**
  String get priceNotSet;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @browseTrades.
  ///
  /// In en, this message translates to:
  /// **'Browse Trades'**
  String get browseTrades;

  /// No description provided for @postTrade.
  ///
  /// In en, this message translates to:
  /// **'Post Trade'**
  String get postTrade;

  /// No description provided for @browseOrPostTrades.
  ///
  /// In en, this message translates to:
  /// **'Browse or post trade requests'**
  String get browseOrPostTrades;

  /// No description provided for @noTicketsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tickets available'**
  String get noTicketsAvailable;

  /// No description provided for @beFirstToPostTicket.
  ///
  /// In en, this message translates to:
  /// **'Be the first to post a ticket!'**
  String get beFirstToPostTicket;

  /// No description provided for @lookingToBuy.
  ///
  /// In en, this message translates to:
  /// **'Looking to Buy'**
  String get lookingToBuy;

  /// No description provided for @lookingToSwap.
  ///
  /// In en, this message translates to:
  /// **'Looking to Swap'**
  String get lookingToSwap;

  /// No description provided for @requestAction.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestAction;

  /// No description provided for @deleteTicket.
  ///
  /// In en, this message translates to:
  /// **'Delete Ticket'**
  String get deleteTicket;

  /// No description provided for @deleteTicketConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ticket? This action cannot be undone.'**
  String get deleteTicketConfirm;

  /// No description provided for @ticketDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket deleted successfully'**
  String get ticketDeletedSuccess;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully!'**
  String get requestSentSuccess;

  /// No description provided for @addMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a message (optional)'**
  String get addMessage;

  /// No description provided for @postYourTicket.
  ///
  /// In en, this message translates to:
  /// **'Post Your Ticket'**
  String get postYourTicket;

  /// No description provided for @fillInDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to post your ticket'**
  String get fillInDetails;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @addAdditionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Add any additional details...'**
  String get addAdditionalDetails;

  /// No description provided for @uploadTicketImage.
  ///
  /// In en, this message translates to:
  /// **'Please upload a ticket image'**
  String get uploadTicketImage;

  /// No description provided for @ticketPostedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket posted successfully!'**
  String get ticketPostedSuccess;

  /// No description provided for @failedToPostTicket.
  ///
  /// In en, this message translates to:
  /// **'Failed to post ticket'**
  String get failedToPostTicket;

  /// No description provided for @pleaseLoginToSendRequests.
  ///
  /// In en, this message translates to:
  /// **'Please login to send requests'**
  String get pleaseLoginToSendRequests;

  /// No description provided for @failedToDeleteTicket.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete ticket'**
  String get failedToDeleteTicket;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @enterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid price'**
  String get enterValidPrice;

  /// No description provided for @fixedPriceRoute.
  ///
  /// In en, this message translates to:
  /// **'Fixed price for this route'**
  String get fixedPriceRoute;

  /// No description provided for @fixedPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Price is fixed for this route and cannot be changed'**
  String get fixedPriceHint;

  /// No description provided for @customPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter custom price or select a common route for auto-fill'**
  String get customPriceHint;

  /// No description provided for @onlyIitMandiEmails.
  ///
  /// In en, this message translates to:
  /// **'Only iitmandi.ac.in emails are allowed'**
  String get onlyIitMandiEmails;

  /// No description provided for @seatCount.
  ///
  /// In en, this message translates to:
  /// **'seat(s)'**
  String get seatCount;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @vehicleInformation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformation;

  /// No description provided for @yourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Your Vehicle'**
  String get yourVehicle;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @totalRides.
  ///
  /// In en, this message translates to:
  /// **'Total Rides'**
  String get totalRides;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationSettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Notification settings updated'**
  String get notificationSettingsUpdated;

  /// No description provided for @usualRoutes.
  ///
  /// In en, this message translates to:
  /// **'Usual Routes'**
  String get usualRoutes;

  /// No description provided for @manageRoutes.
  ///
  /// In en, this message translates to:
  /// **'Manage Routes'**
  String get manageRoutes;

  /// No description provided for @addOrEditRoutes.
  ///
  /// In en, this message translates to:
  /// **'Add or edit your usual routes and pricing'**
  String get addOrEditRoutes;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @contactUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Contact updated successfully'**
  String get contactUpdatedSuccess;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @manageYourRoutes.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Routes'**
  String get manageYourRoutes;

  /// No description provided for @noRoutesAdded.
  ///
  /// In en, this message translates to:
  /// **'No routes added yet'**
  String get noRoutesAdded;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @addRoute.
  ///
  /// In en, this message translates to:
  /// **'Add Route'**
  String get addRoute;

  /// No description provided for @routeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., North Campus - Mandi'**
  String get routeHint;

  /// No description provided for @priceRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRangeLabel;

  /// No description provided for @priceRangeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., ₹900 - ₹1000'**
  String get priceRangeHint;

  /// No description provided for @routesUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Routes updated successfully'**
  String get routesUpdatedSuccess;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @viewPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'View our privacy policy'**
  String get viewPrivacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @viewTerms.
  ///
  /// In en, this message translates to:
  /// **'View terms and conditions'**
  String get viewTerms;

  /// No description provided for @failedToSaveLanguage.
  ///
  /// In en, this message translates to:
  /// **'Failed to save language preference'**
  String get failedToSaveLanguage;

  /// No description provided for @failedToUpdateNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to update notification settings'**
  String get failedToUpdateNotifications;

  /// No description provided for @vehicleManagement.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Management'**
  String get vehicleManagement;

  /// No description provided for @keepVehicleInfoUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Keep your vehicle information up to date'**
  String get keepVehicleInfoUpToDate;

  /// No description provided for @vehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// No description provided for @pleaseEnterSeats.
  ///
  /// In en, this message translates to:
  /// **'Please enter number of seats'**
  String get pleaseEnterSeats;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @vehicleInfoAccurate.
  ///
  /// In en, this message translates to:
  /// **'Make sure your vehicle information is accurate. It will be displayed to passengers.'**
  String get vehicleInfoAccurate;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @vehicleUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle information updated successfully!'**
  String get vehicleUpdatedSuccess;

  /// No description provided for @routeN.
  ///
  /// In en, this message translates to:
  /// **'Route {n}'**
  String routeN(int n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
