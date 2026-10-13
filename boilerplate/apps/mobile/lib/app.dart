import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'config/application.dart';
import 'injection.dart';
import 'router.dart';
import 'store/auth/auth_cubit.dart';
import 'store/auth/auth_state.dart';
import 'views/loading.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>();
    final application = getIt<Application>();

    Intl.defaultLocale = application.language;
    initializeDateFormatting(application.language);

    return BlocProvider<AuthCubit>.value(
      value: getIt<AuthCubit>(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: application.name,
            theme: application.theme.value,
            supportedLocales: [application.locale],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router.config(
              navigatorObservers: () => [BotToastNavigatorObserver()],
            ),
            builder: (context, child) {
              final bootstrapping = state is AuthInitial;

              return BotToastInit()(
                context,
                bootstrapping ? const LoadingView() : child,
              );
            },
          );
        },
      ),
    );
  }
}
