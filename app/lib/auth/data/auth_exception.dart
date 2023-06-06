enum AuthException {
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  emailAlreadyInUse,
  weakPassword,
  unknown;

  factory AuthException.fromCode(String code) {
    switch (code) {
      case "invalid-email":
        return AuthException.invalidEmail;
      case "user-disabled":
        return AuthException.userDisabled;
      case "user-not-found":
        return AuthException.userNotFound;
      case "wrong-password":
        return AuthException.wrongPassword;
      case "email-already-in-use":
        return AuthException.emailAlreadyInUse;
      case "weak-password":
        return AuthException.weakPassword;
      default:
        return AuthException.unknown;
    }
  }

  get msg {
    switch (this) {
      case AuthException.invalidEmail:
        return "Please enter a valid Email";
      case AuthException.userDisabled:
        return "This User has been disabled";
      case AuthException.userNotFound:
      case AuthException.wrongPassword:
        return "Email or Password is wrong.";
      case AuthException.emailAlreadyInUse:
        return "Email is already in Use";
      case AuthException.weakPassword:
        return "The Password is to weak (min. 6 characters)";
      case AuthException.unknown:
      default:
        return "Something went wrong. Please try again.";
    }
  }
}
