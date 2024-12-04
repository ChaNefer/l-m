class Validations {
  static String? validateName(String? value) {
    if (value!.isEmpty) return 'Username is Required.';
    final RegExp nameExp = new RegExp(r'^[A-za-zğüşöçİĞÜŞÖÇąłćżóńęśŻ ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
  }

  static String? validateEmail(String? value, [bool isRequried = true]) {
    if (value!.isEmpty && isRequried) return 'Email is required.';
    final RegExp nameExp = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!nameExp.hasMatch(value) && isRequried)
      return 'Niepoprawny adres email';
  }

  static String? validatePassword(String? value) {
    if (value!.isEmpty || value.length < 6)
      return 'Podaj poprawne hasło';
  }

  static String? validateAge(String? value) {
    if (value!.isEmpty) return 'Wiek jest wymagany.';
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 99) return 'Podaj poprawny wiek od 1 do 99.';
  }

}

