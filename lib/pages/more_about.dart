// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:les_social/services/auth_service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/firebase.dart';
import '../view_models/more_about/more_about_view_model.dart';
import '../widgets/indicators.dart';
import '../widgets/orientation_slider.dart';

class MoreAbout extends StatefulWidget {
  final UserModel? user;

  const MoreAbout({super.key, this.user});

  @override
  State<MoreAbout> createState() => _MoreAboutState();
}

class _MoreAboutState extends State<MoreAbout> {
  double _orientationValue = 0.0; // Domyślnie ustawione na bi
  double filledPercent = 0.0; // Domyślny procent wypełnienia
  late ApiService apiService;
  late AuthService _authService = AuthService();



  Future<UserModel?> currentUid() {
    return _authService.getCurrentUser();
  }

  @override
  void initState() {
    super.initState();
    if (widget.user != null && widget.user!.orientation != null) {
      _orientationValue = double.parse(widget.user!.orientation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    MoreAboutViewModel viewModel = Provider.of<MoreAboutViewModel>(context);
    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: viewModel.loading,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Więcej o mnie"),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: GestureDetector(
                  onTap: () => viewModel.moreAbout(context),
                  child: Text(
                    'ZAPISZ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => viewModel.pickImage(context: context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: new Offset(0.0, 0.0),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: viewModel.imgLink != null
                      ? Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            radius: 65.0,
                            backgroundImage: NetworkImage(viewModel.imgLink!),
                          ),
                        )
                      : viewModel.image == null
                          ? Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: CircleAvatar(
                                radius: 65.0,
                                backgroundImage:
                                    NetworkImage(widget.user!.photoUrl ?? ''),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: CircleAvatar(
                                radius: 65.0,
                                backgroundImage: FileImage(viewModel.image!),
                              ),
                            ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            buildForm(viewModel, context)
          ],
        ),
      ),
    );
  }

  buildForm(MoreAboutViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 10.0),
            Text(
              "Jestem orientacji...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            OrientationSlider(
              initialValue: _orientationValue,
              onChanged: (newValue) {
                setState(() {
                  _orientationValue = newValue;
                });
              },
            ),
            SizedBox(height: 50.0),
            Text(
              "Dzieci...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Checkbox(
                  value: viewModel.childrenCheckbox ?? false,
                  onChanged: (newValue) {
                    setState(() {
                      viewModel.setChildrenCheckbox(newValue!);
                    });
                  },
                ),
                Text('Mam'),
                SizedBox(width: 10.0),
                Checkbox(
                  value: !(viewModel.childrenCheckbox ?? false),
                  onChanged: (newValue) {
                    setState(() {
                      viewModel.setChildrenCheckbox(!(newValue ?? false));
                    });
                  },
                ),
                Text('Nie mam'),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Jaki jest Twoj stosunek do dzieci"),
              maxLines: null,
              initialValue: widget.user!.children,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setChildren(val!);
              },
              onChanged: (String val) {
                viewModel.setChildren(val);
              },
            ),
            SizedBox(height: 20.0),
            Text(
              "Marzę o...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Jakie jest Twoje najskrytsze marzenie?"),
              maxLines: null,
              initialValue: widget.user!.dreams,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setDreams(val!);
              },
              onChanged: (String val) {
                viewModel.setDreams(val);
              },
            ),
            SizedBox(height: 20.0),
            Text(
              "Żałuję...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Czego nigdy nie chciałabyś?"),
              maxLines: null,
              initialValue: widget.user!.regrets,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setRegrets(val!);
              },
              onChanged: (String val) {
                viewModel.setRegrets(val);
              },
            ),
            SizedBox(height: 20.0),
            Text(
              "Palę...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Checkbox(
                  value: viewModel.smokeCheckbox ?? false,
                  onChanged: (newValue) {
                    setState(() {
                      viewModel.setSmokeCheckbox(newValue!);
                    });
                  },
                ),
                Text('Tak'),
                SizedBox(width: 10.0),
                Checkbox(
                  value: !(viewModel.smokeCheckbox ?? false),
                  onChanged: (newValue) {
                    setState(() {
                      viewModel.setSmokeCheckbox(!(newValue ?? false));
                    });
                  },
                ),
                Text('Nie'),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Jaki jest Twój stosunek do palenia?"),
              maxLines: null,
              initialValue: widget.user!.smoke,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setSmoke(val!);
              },
              onChanged: (String val) {
                viewModel.setSmoke(val);
              },
            ),

            SizedBox(height: 20.0),
            Text(
              "Piję...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Checkbox(
                  value: viewModel.drinkCheckbox ?? false,
                  onChanged: (newValue) {
                    setState(() {
                      viewModel.setDrinkCheckbox(newValue!);
                    });
                  },
                ),
                Text('Tak'),
                SizedBox(width: 10.0),
                Checkbox(
                  value: !(viewModel.drinkCheckbox ?? false),
                  onChanged: (newValue) {
                    setState(() {
                      viewModel.setDrinkCheckbox(!(newValue ?? false));
                    });
                  },
                ),
                Text('Nie'),
              ],
            ),

            TextFormField(
              decoration: InputDecoration(hintText: "Jaki jest Twoj stosunek do alkoholu!"),
              maxLines: null,
              initialValue: widget.user!.drink,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setDrink(val!);
              },
              onChanged: (String val) {
                viewModel.setDrink(val);
              },
            ),
            SizedBox(height: 10.0),
            Text(
              "W łóżku najbardziej lubię...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Co Cię kręci?"),
              maxLines: null,
              initialValue: widget.user!.sexPref,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setSexPref(val!);
              },
              onChanged: (String val) {
                viewModel.setSexPref(val);
              },
            ),
            SizedBox(height: 10.0),
            Text(
              "W wolnym czasie najchętniej...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Jak odpoczywasz?"),
              maxLines: null,
              initialValue: widget.user!.freeTime,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setFreeTime(val!);
              },
              onChanged: (String val) {
                viewModel.setFreeTime(val);
              },
            ),
            SizedBox(height: 10.0),
            Text(
              "Lubię, kiedy kobieta...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Najbardziej..."),
              maxLines: null,
              initialValue: widget.user!.favWoman,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setFavWoman(val!);
              },
              onChanged: (String val) {
                viewModel.setFavWoman(val);
              },
            ),
            SizedBox(height: 10.0),
            Text(
              "Lubię jeść...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Mamy nadzieję ;)"),
              maxLines: null,
              initialValue: widget.user!.diet,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setDiet(val!);
              },
              onChanged: (String val) {
                viewModel.setDiet(val);
              },
            ),
            SizedBox(height: 10.0),
            Text(
              "Jedyna słuszna partia polityczna to...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Mojsze jest najmojsze!"),
              maxLines: null,
              initialValue: widget.user!.politics,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setPolitics(val!);
              },
              onChanged: (String val) {
                viewModel.setPolitics(val);
              },
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Mój stosunek do zwierząt domowych...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Checkbox(
                  value: viewModel.petsCheckbox ?? false,
                  onChanged: (newValue) {
                    setState(() {
                      viewModel.setPetsCheckbox(newValue!);
                    });
                  },
                ),
                Text('Mam'),
                SizedBox(width: 10.0),
                Checkbox(
                  value: !(viewModel.petsCheckbox ?? false),
                  onChanged: (newValue) {
                    setState(() {
                      viewModel.setPetsCheckbox(!(newValue ?? false));
                    });
                  },
                ),
                Text('Nie mam'),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Kocham, lubię, szanuję..."),
              maxLines: null,
              initialValue: widget.user!.pets,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'do 1000 znaków';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setPets(val!);
              },
              onChanged: (String val) {
                viewModel.setPets(val);
              },
            ),
            SizedBox(height: 20.0),
            Text(
              "Moja była...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "Była, nie była, kto to tam wie ;)"),
              maxLines: null,
              initialValue: widget.user!.husband,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                if (value!.length > 1000) {
                  return 'Bio musi być krótkie';
                }
                return null;
              },
              onSaved: (String? val) {
                viewModel.setHusband(val!);
              },
              onChanged: (String val) {
                viewModel.setHusband(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
