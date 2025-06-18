import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/login_request.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/login_status.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/register_request.dart';
import 'package:pg_slema/features/chat/auth/logic/entity/register_status.dart';
import 'package:pg_slema/features/chat/main/presentation/controller/chat_main_screen_controller.dart';
import 'package:pg_slema/features/chat/user/logic/service/user_service.dart';
import 'package:pg_slema/features/settings/logic/application_info_repository.dart';
import 'package:pg_slema/utils/token/token_service.dart';

class AuthService {
  final ApplicationInfoRepository applicationInfoRepository;
  final TokenService tokenService;
  final UserService userService;
  final ChatMainScreenController chatMainScreenController;
  final Dio dio;
  final String _baseUrl = '/auth';

  AuthService(this.applicationInfoRepository, this.dio, this.tokenService, this.userService, this.chatMainScreenController);

  Future<LoginStatus> loginUser(String username, String password) async {
    final String endpoint = "$_baseUrl/login";
    final LoginRequest request = LoginRequest(username, password);

    try {
      final response = await dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final String token = data['token'];
        await tokenService.saveToken(token);
        await userService.getCurrentUser();
        return LoginStatus(true, token);
      } else {
        throw Exception('Błąd logowania. Kod statusu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Wystąpił nieoczekiwany błąd podczas logowania.';

      if (e.response != null) {
        if (e.response?.data is String && e.response!.data.isNotEmpty) {
          errorMessage = e.response!.data;
        } else if (e.response?.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else {
          switch (e.response?.statusCode) {
            case 404:
              errorMessage = 'Użytkownik o podanej nazwie nie został znaleziony.';
              break;
            case 401:
              errorMessage = 'Nieprawidłowa nazwa użytkownika lub hasło.';
              break;
            case 400:
              errorMessage = 'Niepoprawne dane logowania.';
              break;
            case 500:
              errorMessage = 'Wewnętrzny błąd serwera. Spróbuj ponownie później.';
              break;
            default:
              errorMessage = 'Błąd logowania: ${e.response?.statusCode}.';
              break;
          }
        }
      } else {
        errorMessage = 'Brak połączenia z serwerem. Sprawdź swoje połączenie internetowe.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Wystąpił nieznany błąd podczas logowania: $e');
    }
  }

  Future<RegisterStatus> registerUser(String username, String password, String email) async {
    final String endpoint = "$_baseUrl/register";
    final RegisterRequest request = RegisterRequest(username, password, email);

    try {
      final response = await dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201) {
        return RegisterStatus(true);
      } else {
        throw Exception('Błąd rejestracji. Kod statusu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Wystąpił nieoczekiwany błąd podczas rejestracji.';

      if (e.response != null) {
        if (e.response?.data is String && e.response!.data.isNotEmpty) {
          errorMessage = e.response!.data;
        } else if (e.response?.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        } else {
          switch (e.response?.statusCode) {
            case 409:
              errorMessage = 'Nazwa użytkownika lub email są już zajęte. Proszę wybrać inne.';
              break;
            case 400:
              errorMessage = 'Niepoprawne dane. Sprawdź wprowadzone informacje.';
              break;
            case 500:
              errorMessage = 'Wewnętrzny błąd serwera. Spróbuj ponownie później.';
              break;
            default:
              errorMessage = 'Błąd rejestracji: ${e.response?.statusCode}.';
              break;
          }
        }
      } else {
        errorMessage = 'Brak połączenia z serwerem. Sprawdź swoje połączenie internetowe.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Wystąpił nieznany błąd podczas rejestracji: $e');
    }
  }

  void logOut(BuildContext context) {
    tokenService.deleteToken();
    chatMainScreenController.toDefaultState();
    Navigator.pop(context);
  }
}