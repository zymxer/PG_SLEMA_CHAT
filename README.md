# Slema Chat

**Slema Chat** to projekt aplikacji czatowej opartej na architekturze mikroserwisów. Składa się z trzech głównych mikroserwisów (AuthService, ChatService, GatewayService) napisanych w Javie z użyciem Spring Boot oraz klienta mobilnego dla systemu Android, zrealizowanego we Flutterze. Celem projektu jest zapewnienie kompleksowej funkcjonalności czatu z uwierzytelnianiem użytkowników i wymianą wiadomości w czasie rzeczywistym.

---

## Struktura Projektu

Projekt jest zorganizowany w następujący sposób:

* **AuthService**: Mikroserwis odpowiadający za **uwierzytelnianie i autoryzację użytkowników** (rejestracja, logowanie, weryfikacja tokenów JWT).
* **ChatService**: Mikroserwis obsługujący **logikę czatu**, w tym zarządzanie czatami, wiadomościami oraz komunikację w czasie rzeczywistym za pomocą WebSockets.
* **GatewayService**: Mikroserwis bramy API, pełniący rolę **jednego punktu wejścia** dla klienta i routujący żądania do odpowiednich mikroserwisów.
* **SlemaForAndroid**: **Aplikacja kliencka na Androida**, rozwijana we Flutterze, która komunikuje się z backendem.
* **tools**: Katalog zawierający **skrypty pomocnicze** do budowania i wdrażania projektu.

---

## Mikroserwisy (AuthService, ChatService, GatewayService)

Wszystkie trzy mikroserwisy backendowe są napisane w **Javie** z wykorzystaniem frameworka **Spring Boot**.

### Technologie

* **Java 22**
* **Spring Boot 3.x**
* **Spring Data JPA**
* **PostgreSQL** (jako baza danych)
* **Liquibase** (do zarządzania migracjami bazy danych)
* **Lombok** (do redukcji boilerplate code)
* **WebSockets** (dla komunikacji w czasie rzeczywistym w ChatService)
* **Spring Cloud Gateway** (do routingu w GatewayService)
* **Spring Security & JWT** (do uwierzytelniania i autoryzacji)
* **Maven** (do budowania projektu)

### Konfiguracja i Uruchamianie

Do uruchomienia mikroserwisów niezbędne są **Docker** i **Docker Compose**.

1.  **Sklonuj repozytorium:**
    ```bash
    git clone https://github.com/zymxer/PG_SLEMA_CHAT
    cd pg_slema_chat
    ```

2.  **Uruchom bazę danych (PostgreSQL) za pomocą Docker Compose:**
    Z głównego katalogu projektu (tam, gdzie znajduje się `docker-compose.yml`) uruchom tylko serwis `postgres`:
    ```bash
    docker-compose up -d postgres
    ```
    Spowoduje to uruchomienie PostgreSQL na porcie **5433** Twojego hosta (przekierowanie z 5432 wewnątrz kontenera).

3.  **Budowanie i uruchamianie mikroserwisów (lokalnie z IDE - dla deweloperów):**
    Jeśli chcesz uruchamiać mikroserwisy lokalnie (np. z IntelliJ IDEA) w celach deweloperskich:
    * Upewnij się, że PostgreSQL jest uruchomiony przez Docker na `localhost:5433`.
    * Otwórz każdy projekt (AuthService, ChatService, GatewayService) w swoim IDE.
    * Upewnij się, że w plikach `src/main/resources/application.properties` (lub `application.yml`) każdego serwisu podane są prawidłowe parametry połączenia z bazą danych i innymi serwisami. Przykładowo, ChatService łączy się z PostgreSQL na `localhost:5433`.
    * **Domyślne porty:**
        * **AuthService:** Działa na porcie `8081`.
        * **ChatService:** Działa na porcie `8082`.
        * **GatewayService:** Działa na porcie `8080`.
    * Upewnij się, że GatewayService routuje żądania na `localhost:8081` dla AuthService i `localhost:8082` dla ChatService.
    * W głównym folderze każdego mikroserwisu wykonaj:
        ```bash
        mvn clean install -DskipTests
        ```
    * Uruchom główną klasę aplikacji (np. `AuthServiceApplication.java`, `ChatServiceApplication.java`, `GatewayServiceApplication.java`) w swoim IDE.

4.  **Budowanie i uruchamianie mikroserwisów (za pomocą Docker Compose - produkcyjnie):**
    Jeśli chcesz uruchomić wszystkie mikroserwisy w kontenerach Docker:
    * Upewnij się, że plik `docker-compose.yml` w głównym katalogu projektu jest poprawnie skonfigurowany.
    * Upewnij się, że porty serwisów (`8080`, `8081`, `8082`) są dostępne na Twojej maszynie hosta.
    * W głównym katalogu projektu wykonaj:
        ```bash
        docker-compose up -d --build
        ```
      Flaga `--build` spowoduje ponowne zbudowanie obrazów Docker na podstawie najnowszych zmian w kodzie.

### Główne Punkty Końcowe API (przez GatewayService na `localhost:8080`)

#### Uwierzytelnianie (AuthService)

* `POST /auth/register` - Rejestracja nowego użytkownika.
* `POST /auth/login` - Logowanie użytkownika, otrzymanie tokena JWT.
* `GET /auth/verify` - Weryfikacja tokena JWT.

#### Użytkownicy (ChatService)

* `GET /api/user/of-request` - Pobranie informacji o aktualnym użytkowniku (na podstawie JWT).
* `GET /api/user` - Pobranie listy wszystkich użytkowników.

#### Czaty (ChatService)

* `POST /api/chat` - Tworzenie nowego czatu.
* `GET /api/chat` - Pobieranie listy wszystkich czatów użytkownika.
* `GET /api/chat/{chatId}/members` - Pobieranie uczestników konkretnego czatu.
* `WS /ws/chat` - Połączenie WebSocket do wymiany wiadomości i powiadomień o aktualizacjach czatów.

---

## Aplikacja Kliencka (SlemaForAndroid - Flutter)

Aplikacja kliencka na Androida, opracowana we **Flutterze**, komunikuje się z backendem za pośrednictwem **GatewayService**.

### Technologie

* **Flutter 3.x**
* **Dart**
* **Dio** (do żądań HTTP)
* **web_socket_channel** (do połączeń WebSocket)
* **Provider** (do zarządzania stanem)
* **intl** (do formatowania dat)

### Konfiguracja i Uruchamianie

1.  **Przejdź do katalogu projektu Flutter:**
    ```bash
    cd SlemaForAndroid
    ```

2.  **Pobierz zależności:**
    ```bash
    flutter pub get
    ```

3.  **Skonfiguruj adres backendu:**
    W pliku `SlemaForAndroid/lib/main.dart` upewnij się, że zmienna `_backendBaseUrl` (lub `serverAddress`) wskazuje na Twój GatewayService.
    Dla emulatora Androida uruchomionego lokalnie, zazwyczaj jest to `http://10.0.2.2:8080`.

    ```dart
    // SlemaForAndroid/lib/main.dart
    // ...
    final String devAddress = '10.0.2.2:8080'; // Dla emulatora Androida na lokalnym hoście
    // ...
    applicationInfoRepository.setServerAddress(
        applicationInfoRepository.isDeveloperMode()? devAddress : prodAddress
    );
    ```

    Dla połączeń WebSocket w `SlemaForAndroid/lib/features/chat/chats/logic/service/chat_service.dart` upewnij się, że `wsUri` również wskazuje na:
    * `ws://10.0.2.2:8082` (bezpośrednio do ChatService, jeśli Gateway nie proxyuje WS)
    * lub `ws://10.0.2.2:8080` (jeśli Gateway proxyuje WS).

4.  **Uruchom aplikację:**
    ```bash
    flutter run
    ```

    Dla czystej instalacji lub po zmianach w kodzie Java backendu zawsze zaleca się wykonanie:
    ```bash
    flutter clean
    flutter pub get
    flutter run
    ```

---


## License

Licensed under the CC BY-NC 4.0 License https://creativecommons.org/licenses/by-nc/4.0/ 
This file may not be copied, modified, or distributed except according to those terms.
Please refer to LICENSE.md for more information.
