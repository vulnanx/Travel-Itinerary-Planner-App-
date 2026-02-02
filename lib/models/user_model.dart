// code is taken directly from the provided sample todo list code
class Account {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? username;
  String? password;
  String? contactno;
  bool? isGoogle;
  bool? public;
  List<String>? interestsList;
  List<String>? travelStylesList;
  List<String>? friendsList;
  List<String>? friendRequests;
  List<String>? friendRequestsSent;
  List<String>? joinedPlans;
  List<String>? joinRequestSent;
  List<String>? pendingInvites;
  String? profileURL;

  // id is not a requirement as firebase will be providing its own id
  Account({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.contactno,
    this.public,
    this.interestsList,
    this.travelStylesList,
    this.friendsList,
    this.friendRequests,
    this.friendRequestsSent,
    this.joinedPlans,
    this.joinRequestSent,
    this.pendingInvites,
    this.profileURL,
    this.isGoogle,
  });

  // Factory constructor to instantiate object from json format
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      username: json['username'],
      contactno: json['contactno'],
      public: json['public'],
      interestsList: List<String>.from(json['interests'] ?? []),
      travelStylesList: List<String>.from(json['travelStyles'] ?? []),
      friendsList: List<String>.from(json['friends'] ?? []),
      friendRequests: List<String>.from(json['friend_requests'] ?? []),
      friendRequestsSent: List<String>.from(json['friend_requests_sent'] ?? []),
      joinedPlans: List<String>.from(json['joined_plans'] ?? []),
      joinRequestSent: List<String>.from(json['join_request_sent'] ?? []),
      pendingInvites: List<String>.from(json['pending_invites'] ?? []),
      profileURL: json['profileURL'],
      isGoogle: json['isGoogle'],
    );
  }

  //conversion of map object to json
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'contactno': contactno,
      'public': public,
      'interests': interestsList,
      'travelStyles': travelStylesList,
      'friends': friendsList,
      'friend_requests': friendRequests,
      'friend_requests_sent': friendRequestsSent,
      'joined_plans': joinedPlans,
      'join_request_sent': joinRequestSent,
      'pending_invites': pendingInvites,
      'profileURL': profileURL,
      'isGoogle': isGoogle ?? false,
    };
  }
}
