import 'package:cloud_firestore/cloud_firestore.dart';

getDate(int postDate) {
  int currDate = Timestamp.now().millisecondsSinceEpoch;
  // differences
  int milliseconds = currDate - postDate;
  int seconds = milliseconds ~/ 1000;
  int minutes = seconds ~/ 60;
  int hours = minutes ~/ 60;
  int days = hours ~/ 24;
  int weeks = days ~/ 7;
  int months = weeks ~/ 4;
  int years = months ~/ 12;
  if (seconds > 0 && seconds <= 60) {
    return "$seconds sec";
  } else if (minutes > 0 && minutes <= 60) {
    return "$minutes min";
  } else if (hours > 0 && hours <= 24) {
    return "$hours hrs";
  } else if (days > 0 && days <= 7) {
    return "$days days";
  } else if (weeks > 0 && weeks <= 4) {
    return "$weeks weeks";
  } else if (months > 0 && months <= 12) {
    return "$months months";
  } else {
    return "$years years";
  }
}