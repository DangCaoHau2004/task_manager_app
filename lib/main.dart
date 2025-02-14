import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_app/screens/home.dart';
import 'package:task_manager_app/screens/login_signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(199, 192, 53, 239),
);
var dColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(198, 0, 0, 0),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ProviderScope(
        child: _MyApp(),
      ),
    );
  });
}

class _MyApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends ConsumerState<_MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: kColorScheme,
        scaffoldBackgroundColor: kColorScheme.onTertiary,
        appBarTheme: AppBarTheme(
          backgroundColor: kColorScheme.primary,
          foregroundColor: kColorScheme.onPrimary,
        ),
        cardTheme: CardTheme(
          color: kColorScheme.onTertiary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primary,
            foregroundColor: kColorScheme.onTertiary,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kColorScheme.primary,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: kColorScheme.primary,
        ),
      ),
      // darkTheme: ThemeData.dark().copyWith(
      //   colorScheme: dColorScheme,
      //   scaffoldBackgroundColor: dColorScheme.onTertiary,
      //   appBarTheme: AppBarTheme(
      //     backgroundColor: dColorScheme.primary,
      //     foregroundColor: dColorScheme.onPrimary,
      //   ),
      //   cardTheme: CardTheme(
      //     color: dColorScheme.onTertiary,
      //   ),
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: dColorScheme.primary,
      //       foregroundColor: dColorScheme.onTertiary,
      //     ),
      //   ),
      //   textButtonTheme: TextButtonThemeData(
      //     style: TextButton.styleFrom(
      //       foregroundColor: dColorScheme.primary,
      //     ),
      //   ),
      //   floatingActionButtonTheme: FloatingActionButtonThemeData(
      //     backgroundColor: dColorScheme.primary,
      //   ),
      // ),
      // themeMode: ref.watch(darkTheme) ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          // Load lại theme

          // waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Theme.of(context).colorScheme.onTertiary,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          // hasData
          else if (snapshot.hasData) {
            print("has data");
            final user = snapshot.data!;
            // truyền dữ liệu vào provider future và lấy kết quả để so sánh
            final userDataAsyncValue = ref.watch(
              userDataProvider(user.uid),
            );
            return userDataAsyncValue.when(
              // khi có data
              data: (userDataResult) {
                Future.microtask(() {
                  ref.read(userData.notifier).state = {
                    "email": userDataResult["email"],
                    "username": userDataResult["username"],
                    "uid": user.uid,
                  };
                });
                return const HomeScreen();
              },
              // nếu có lỗi khi lấy thông tin user
              error: (err, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.error,
                  child: Center(
                    child: Text(
                      "$err",
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onTertiary),
                    ),
                  ),
                );
              },

              // nếu đang loading
              loading: () {
                return Container(
                  color: Theme.of(context).colorScheme.onTertiary,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            );
          }
          print("login");

          // reset lại data user
          Future.microtask(() {
            ref.read(userData.notifier).state = {};
          });

          // nếu như ko có data cũng ko data
          return const LoginSignupScreen();
        },
      ),
    );
  }
}
