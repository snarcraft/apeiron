import 'package:flutter_bloc/flutter_bloc.dart';

import '../injection.dart';

import 'auth/auth_cubit.dart';

/// The global cubits — everything app-scoped lives here; feature
/// cubits attach per-route via AutoRouteWrapper.
List<BlocProvider> registerBlocs() => [
  BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
];
