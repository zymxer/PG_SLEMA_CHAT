import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart';
import 'package:pg_slema/features/chat/auth/logic/service/auth_service.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_in_controller.dart';
import 'package:pg_slema/features/chat/auth/presentation/controller/sign_up_controller.dart';
import 'package:pg_slema/features/chat/chats/logic/service/chat_service.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/add_chat_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/chat_controller.dart';
import 'package:pg_slema/features/chat/chats/presentation/controller/chats_controller.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/features/chat/user/logic/entity/user.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/features/exercises/logic/converter/exercise_to_dto_converter.dart';
import 'package:pg_slema/features/exercises/logic/repository/shared_preferences_exercise_repository.dart';
import 'package:pg_slema/features/exercises/logic/service/exercise_service.dart';
import 'package:pg_slema/features/gallery/logic/repository/stored_image_metadata_repository.dart';
import 'package:pg_slema/features/gallery/logic/repository/shared_preferences_stored_image_metadata_repository.dart';
import 'package:pg_slema/features/gallery/logic/service/image_service.dart';
import 'package:pg_slema/features/gallery/logic/service/image_service_chat_impl.dart';
import 'package:pg_slema/features/gallery/logic/service/image_service_impl.dart';
import 'package:pg_slema/features/motivation/presentation/controller/motivation_screen_controller.dart';
import 'package:pg_slema/features/settings/logic/application_info_repository.dart';
import 'package:pg_slema/features/settings/logic/application_info_repository_impl.dart';
import 'package:pg_slema/features/settings/logic/application_info_service.dart';
import 'package:pg_slema/features/settings/logic/application_info_service_impl.dart';
import 'package:pg_slema/features/well_being/logic/entity/assessment_factory.dart';
import 'package:pg_slema/features/well_being/logic/entity/enum/assessment_factory_impl.dart';
import 'package:pg_slema/features/well_being/logic/repository/assessments_repository.dart';
import 'package:pg_slema/features/well_being/logic/repository/shared_preferences_assessments_repository.dart';
import 'package:pg_slema/features/well_being/logic/service/assessments_service.dart';
import 'package:pg_slema/features/well_being/logic/service/assessments_service_impl.dart';
import 'package:pg_slema/initializers/global_initializer.dart';
import 'package:pg_slema/main/presentation/controller/main_screen_controller.dart';
import 'package:pg_slema/main/presentation/screen/main_screen.dart';
import 'package:pg_slema/theme/theme_constants.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';
import 'package:pg_slema/utils/log/logger_printer.dart';
import 'package:pg_slema/utils/token/token_service.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:loggy/loggy.dart';

Future<void> main() async {

  Loggy.initLoggy(
    logPrinter: const LoggerPrinter(),
  );
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Poland'));
  WidgetsFlutterBinding.ensureInitialized();
  GlobalInitializer().initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final imageMetadataRepository =
      await SharedPreferencesStoredImageMetadataRepository.create();
  final imageService = ImageServiceImpl(repository: imageMetadataRepository);

  final assessmentsRepository =
      await SharedPreferencesAssessmentsRepository.create();
  final assessmentsService =
      AssessmentsServiceImpl(repository: assessmentsRepository);
  final assessmentFactory =
      AssessmentFactoryImpl(repository: assessmentsRepository);

  var exercisesConverter = ExerciseToDtoConverter();
  final exerciseRepository =
      SharedPreferencesExerciseRepository(exercisesConverter);
  final exerciseService = ExerciseService(exerciseRepository);

  final applicationInfoRepository =
      await ApplicationInfoRepositoryImpl.create();
  final applicationInfoService = ApplicationInfoServiceImpl(
    applicationInfoRepository: applicationInfoRepository,
  );


  final String devAddress = "10.0.2.2:8080";
  final String prodAddress = "10.0.2.2:8080"; // TODO replace production address
  final String chatServiceAddress = "10.0.2.2:8082"; // Todo remove when WebSocket works via gateway

  final logger = Loggy<Logger>("main");
  final dio = Dio();
  applicationInfoRepository.setDeveloperMode(true);

  if(applicationInfoRepository.getServerAddress().isEmpty) {
    applicationInfoRepository.setServerAddress(
        applicationInfoRepository.isDeveloperMode()? devAddress : prodAddress
    );
  }
  if(applicationInfoRepository.getChatServiceAddress().isEmpty) {
    applicationInfoRepository.setChatServiceAddress(chatServiceAddress);
  }
  final address = applicationInfoRepository.getServerAddress();
  final httpAddress = "http://$address";
  try {
    //Todo server address is only set once and doesn't refresh on change
    dio.options.baseUrl = httpAddress;
    logger.debug("Correctly set base URL to $httpAddress");
  } catch (ex) {
    logger.error("Invalid base URL: \"$httpAddress\"\n$ex");
  }
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);

  final chatImageMetadataRepository =
  await SharedPreferencesStoredImageMetadataRepository.create();
  final chatImageService = ImageServiceChatImpl(repository: chatImageMetadataRepository);
  final chatMainScreenController = ChatMainScreenController();
  // CHAT SERVICES
  final tokenService = TokenService();
  final userService = UserService(dio, tokenService);
  final authService = AuthService(applicationInfoRepository, dio, tokenService, userService, chatMainScreenController);
  final chatService = ChatService(dio, tokenService, chatImageService, applicationInfoRepository);

  // CHAT CONTROLLERS
  final signInController = SignInController(authService, chatMainScreenController);
  final signUpController = SignUpController(authService, chatMainScreenController);
  final addChatController = AddChatController(chatService, userService);
  final allChatsController = AllChatsController(chatService, userService);
  final chatController = ChatController(chatService, userService, chatImageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MainScreenController()),

        ChangeNotifierProvider(
          create: (context) => MotivationScreenController(),
        ),
        Provider<AssessmentsRepository>(create: (_) => assessmentsRepository),
        Provider<AssessmentsService>(create: (_) => assessmentsService),
        Provider<AssessmentFactory>(create: (_) => assessmentFactory),
        Provider<ExerciseService>(create: (_) => exerciseService),
        Provider<ApplicationInfoRepository>(
            create: (_) => applicationInfoRepository),
        Provider<StoredImageMetadataRepository>(
            create: (_) => imageMetadataRepository),
        Provider<ImageService>(create: (_) => imageService),
        Provider<ApplicationInfoService>(create: (_) => applicationInfoService),

        // CHAT SERVICES
        Provider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider<UserService>(create: (_) => userService),
        Provider<TokenService>(create: (_) => tokenService),
        ChangeNotifierProvider<ChatService>(create: (_) => chatService),

        // CHAT CONTROLLERS
        ChangeNotifierProvider(create: (context) => chatMainScreenController),
        ChangeNotifierProvider(create: (context) => signInController),
        ChangeNotifierProvider(create: (context) => signUpController),
        ChangeNotifierProvider(create: (context) => addChatController),
        ChangeNotifierProvider(create: (context) => allChatsController),
        ChangeNotifierProvider(create: (context) => chatController),

      ],
      child: MaterialApp(
        theme: lightTheme,
        // TODO: Dark theme has been disabled as of SLEMA-172. It is to be enabled once dark theme is ready to be used.
        darkTheme: lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pl', 'PL'),
        ],
        home: const MainScreen(),
      ),
    ),
  );
}
