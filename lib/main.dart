import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
final FlutterAppAuth appAuth = FlutterAppAuth();
const FlutterSecureStorage secureStorage = FlutterSecureStorage();
const String FUSION_AUTH_CLIENT_ID = 'a1le7qceg23vta5gg5r7qe62d';
const String FUSION_AUTH_REDIRECT_URI =
    'net.openid.appauthdemo:/oauth2redirect';
const String FUSION_AUTH_ISSUER =
    'https://demoapp1.auth.us-west-1.amazoncognito.com/oauth2/authorize';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage;
  String name;
  String picture;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppAuth Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AppAuth with Flutter Demo'),
        ),
        body: Center(
            child: isBusy
                ? const CircularProgressIndicator()
                : isLoggedIn
                    ? LoginScreen()
                    : Login(loginAction, errorMessage)
            ),
      ),
    );
  }

  // Future<Map<String, Object>> getUserDetails(String accessToken) async {
  //   const String url = 'https://$FUSION_AUTH_DOMAIN/oauth2/userinfo';
  //   final http.Response response = await http.get(
  //     url,
  //     headers: <String, String>{'Authorization': 'Bearer $accessToken'},
  //   );
  //
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to get user details');
  //   }
  // }

  Future<void> loginAction() async {
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
            FUSION_AUTH_CLIENT_ID, FUSION_AUTH_REDIRECT_URI,
            serviceConfiguration: AuthorizationServiceConfiguration(
                'https://demoapp1.auth.us-west-1.amazoncognito.com/oauth2/authorize',
                'https://demoapp1.auth.us-west-1.amazoncognito.com/oauth2/token'),
            scopes: <String>[
              'openid',
              'aws.cognito.signin.user.admin',
              'email'
            ]),
      );

      log('data: $result');

      setState(() {
        isBusy = false;
        isLoggedIn = true;
      });

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoginScreen()));

    } on Exception catch (e, s) {
      debugPrint('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }

  // Future<void> initAction() async {
  //   final String storedRefreshToken =
  //       await secureStorage.read(key: 'refresh_token');
  //   if (storedRefreshToken == null) return;
  //
  //   setState(() {
  //     isBusy = true;
  //   });
  //
  //   try {
  //     final TokenResponse response = await appAuth.token(TokenRequest(
  //       FUSION_AUTH_CLIENT_ID,
  //       FUSION_AUTH_REDIRECT_URI,
  //       issuer: FUSION_AUTH_ISSUER,
  //       refreshToken: storedRefreshToken,
  //     ));
  //
  //     // final Map<String, Object> idToken = parseIdToken(response.idToken);
  //     final Map<String, Object> profile =
  //         await getUserDetails(response.accessToken);
  //
  //     await secureStorage.write(
  //         key: 'refresh_token', value: response.refreshToken);
  //     var gravatar = Gravatar(profile['email']);
  //     var url = gravatar.imageUrl(
  //       size: 100,
  //       defaultImage: GravatarImage.retro,
  //       rating: GravatarRating.pg,
  //       fileExtension: true,
  //     );
  //     setState(() {
  //       isBusy = false;
  //       isLoggedIn = true;
  //       name = profile['given_name'];
  //       picture = url;
  //     });
  //   } on Exception catch (e, s) {
  //     debugPrint('error on refresh token: $e - stack: $s');
  //     await logoutAction();
  //   }
  // }
  //
  // Future<void> logoutAction() async {
  //   await secureStorage.delete(key: 'refresh_token');
  //   setState(() {
  //     isLoggedIn = false;
  //     isBusy = false;
  //   });
  // }

}

class Login extends StatelessWidget {
  final Future<void> Function() loginAction;
  final String loginError;

  const Login(this.loginAction, this.loginError, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            await loginAction();
          },
          child: const Text('Login'),
        ),
        Text(loginError ?? ''),
      ],
    );
  }
}

class Profile extends StatelessWidget {
  final Future<void> Function() logoutAction;
  final String name;
  final String picture;

  const Profile(this.logoutAction, this.name, this.picture, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 4),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(picture ?? ''),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Name: $name'),
        const SizedBox(height: 48),
        RaisedButton(
          onPressed: () async {
            await logoutAction();
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'USER LOGGED IN',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
