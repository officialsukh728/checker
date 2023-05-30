part of 'http_service.dart';

class ApisEndpoints {
  // http://192.168.11.72:8027/api/registerWithIDProof

  // static String baseUrl = "http://192.168.11.72:8027/api/";
  static String baseUrl = "http://communitywatcher.csdevhub.com/api/";
  static String fcmSendNotification = "https://fcm.googleapis.com/fcm/send";

  static String registerWithIDProof = "register";
  static String login = "login";
  static String planCheck = "planCheck";
  static String userSubscriptionPlan = "userSubscriptionPlan";
  static String logout = "logout";
  static String getNotification = "getNotification";
  static String editProfile = "editProfile";
  static String getProfileData = "getProfileData";
  static String sendNotification = "sendNotification";
  static String setRadius = "setRadius";
  static String sosUsers = "sosUsers";
  static String getUserContacts = "getUserContacts";
  static String addContacts = "addContacts";
  static String sendOTPEmail = "sendOTPEmail";
  static String resetPassword = "resetPassword";

}
