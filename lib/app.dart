import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_branding.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/api_data/data/datasources/rs_api_remote_datasource.dart';
import 'features/api_data/data/repositories/rs_api_repository_impl.dart';
import 'features/api_data/domain/repositories/rs_api_repository.dart';
import 'features/api_data/presentation/cubit/rs_api_cubit.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_secure_storage.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/data/datasources/home_local_datasource.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/navigation/presentation/cubit/navigation_cubit.dart';
import 'features/splash/presentation/pages/splash_gate_page.dart';

class RsMobileApp extends StatelessWidget {
  const RsMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<AuthSecureStorage>(
          create: (_) => AuthSecureStorage(),
        ),
        RepositoryProvider<ApiClient>(
          create: (BuildContext context) =>
              ApiClient(sessionStore: context.read<AuthSecureStorage>()),
          dispose: (ApiClient apiClient) => apiClient.close(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (BuildContext context) => AuthRepositoryImpl(
            remoteDatasource: AuthRemoteDatasource(
              apiClient: context.read<ApiClient>(),
            ),
            secureStorage: context.read<AuthSecureStorage>(),
          ),
        ),
        RepositoryProvider<HomeRepository>(
          create: (_) =>
              HomeRepositoryImpl(localDatasource: HomeLocalDatasource()),
        ),
        RepositoryProvider<RsApiRepository>(
          create: (BuildContext context) => RsApiRepositoryImpl(
            remoteDatasource: RsApiRemoteDatasource(
              apiClient: context.read<ApiClient>(),
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthCubit>(
            create: (BuildContext context) =>
                AuthCubit(authRepository: context.read<AuthRepository>())
                  ..loadSession(),
          ),
          BlocProvider<HomeCubit>(
            create: (BuildContext context) =>
                HomeCubit(homeRepository: context.read<HomeRepository>())
                  ..loadInitialData(),
          ),
          BlocProvider<RsApiCubit>(
            create: (BuildContext context) =>
                RsApiCubit(repository: context.read<RsApiRepository>()),
          ),
          BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
        ],
        child: MaterialApp(
          title: AppBranding.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashGatePage(),
        ),
      ),
    );
  }
}
