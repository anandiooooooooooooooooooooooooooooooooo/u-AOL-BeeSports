# 🐝 BeeSports

**BeeSports** is a sports matchmaking mobile application built exclusively for **BINUS University** students. It allows students to create and join sports lobbies, find opponents, manage in-app credits, chat in real-time, track match results with ELO-based rankings, and connect with friends — all within a single platform.

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart SDK ^3.5.3) |
| **State Management** | flutter_bloc + equatable |
| **Dependency Injection** | get_it |
| **Navigation** | go_router |
| **Backend / Database** | Supabase (Auth, Database, Realtime) |
| **HTTP Client** | dio |
| **Config** | flutter_dotenv (`.env`) |
| **Typography** | google_fonts (Inter) |
| **UI** | Material Design 3, Dark Theme |

## 📐 Architecture

The project follows **feature-driven Clean Architecture** with three distinct layers per feature:

```
Feature/
├── data/          → Concrete implementations (API/DB calls via Supabase)
│   └── repositories/
├── domain/        → Business rules & contracts (entities, abstract repos)
│   ├── entities/
│   └── repositories/
└── presentation/  → UI & state management (BLoC pattern, screens)
    ├── bloc/
    └── screens/
```

---

## 📂 Project Structure

### 📄 `lib/main.dart`
The application entry point. It runs an async boot sequence that loads environment variables from the `.env` file, initializes the Supabase backend client, registers all app dependencies into the service locator, and then launches the root `BeeSportsApp` widget. The root widget wraps the entire application in `MultiBlocProvider` to provide `AuthBloc` (with an immediate auth check) and `NotificationBloc` globally, then configures a `MaterialApp.router` with the dark theme and `go_router` navigation.

---

### 📂 `lib/core/` — Application Foundation

Core contains app-wide infrastructure that all features depend on. Nothing here is specific to a single feature.

#### `core/config/`
| File | Purpose |
|---|---|
| `env.dart` | A simple utility class that reads `SUPABASE_URL` and `SUPABASE_ANON_KEY` from `flutter_dotenv`. It centralizes all environment variable access so that no feature ever directly reads from `.env`. |
| `supabase_config.dart` | Responsible for booting the Supabase SDK using the credentials from `env.dart`. It also exposes a static `client` getter so any part of the app can retrieve the initialized `SupabaseClient` instance without re-initializing it. |

#### `core/di/`
| File | Purpose |
|---|---|
| `injection_container.dart` | The dependency injection setup file. It uses `get_it` to define a global service locator (`sl`). All 9 repositories are registered as **lazy singletons** (created once, shared everywhere), while all 10 BLoCs are registered as **factories** (a fresh instance is created each time a widget requests one). Each repository receives the `SupabaseClient`, and each BLoC receives its corresponding repository — ensuring clean separation of concerns. |

#### `core/router/`
| File | Purpose |
|---|---|
| `app_router.dart` | Defines the full navigation structure of the app using `GoRouter`. It contains auth-aware redirect logic that automatically sends users to the correct screen based on their auth state — unauthenticated users go to `/login`, users pending email verification go to `/otp`, and first-time users go to `/onboarding`. The routes are organized into two groups: **standalone routes** (login, register, OTP, onboarding, profile) that appear without a bottom nav bar, and **shell routes** (home, lobbies, wallet, leaderboard, chat, notifications, friends, match) that are wrapped inside `MainScaffold` which provides the bottom navigation bar. It also includes a `_AuthNotifier` helper that listens to auth state changes and triggers route re-evaluation automatically. |

#### `core/theme/`
| File | Purpose |
|---|---|
| `app_colors.dart` | The single source of truth for every color used in the app. Defines the primary cyan palette (`#00B4D8`, `#90E0EF`, `#0077B6`), dark mode surfaces (pure black background, dark grey cards), light mode surfaces (reserved for future use), text colors, semantic colors (green for success, red for error, orange for warning), and unique colors assigned to each sport type (green for futsal, red for basketball, cyan for badminton, purple for volleyball, etc.). |
| `app_theme.dart` | Builds the global `ThemeData` for the entire app's dark mode. It applies **Google Fonts Inter** as the default typeface, configures Material 3 color schemes from `AppColors`, and styles every major widget — app bars (centered, no elevation), cards (16px rounded corners), buttons (12px rounded, semibold text), text inputs (filled dark background, cyan focus border), chips, bottom nav bar, and snack bars (floating, rounded). This ensures visual consistency across all screens without per-widget styling. |

---

### 📂 `lib/features/` — Feature Modules

Each feature is a self-contained module with its own data, domain, and presentation layers. Features do not directly depend on each other.

---

#### 🔐 `features/auth/` — Authentication
Handles the entire authentication lifecycle for BINUS students. The system enforces that only `@binus.ac.id` email addresses can register. The auth flow goes: **Register → OTP email verification → Onboarding (first-time profile setup) → Authenticated**.

| File | Purpose |
|---|---|
| `data/repositories/auth_repository_impl.dart` | The concrete implementation that talks to Supabase Auth for sign-up, sign-in, OTP verification, and sign-out. It also reads/writes user profiles from the Supabase `profiles` table and validates that the email domain is `binus.ac.id` before allowing any auth action. It provides a reactive stream of auth state changes so the app can respond to login/logout events in real-time. |
| `domain/entities/user_entity.dart` | An immutable data class representing a user in the system. It holds the user's id, email, full name, NIM (student ID number), campus, role (defaults to "player"), avatar URL, onboarding status, and account creation date. Includes serialization methods for converting to/from Supabase JSON. |
| `domain/entities/campus.dart` | An enum listing all BINUS University campuses (Kemanggisan, Alam Sutera, Bekasi, Bandung, Malang, Semarang, BINUS Online). Each campus has a display label and city. It also includes a smart utility that can automatically determine which campus a student belongs to based on the first 4 digits of their NIM number. |
| `domain/repositories/auth_repository.dart` | The abstract interface (contract) that defines what authentication operations must exist — sign up, verify OTP, sign in, sign out, get current user, save profile, and listen to auth changes. The data layer implements this contract. |
| `presentation/bloc/auth_bloc.dart` | The BLoC (Business Logic Component) that manages the authentication state machine. It receives events like sign-in requested or OTP submitted, processes them through the repository, and emits states like `Authenticated`, `Unauthenticated`, `NeedsOtpVerification`, `NeedsOnboarding`, or `AuthError`. It also converts raw error messages into user-friendly text (e.g., "Only @binus.ac.id emails are allowed"). |
| `presentation/screens/login_screen.dart` | The login screen UI with email and password input fields and a link to navigate to the registration page. |
| `presentation/screens/register_screen.dart` | The registration screen UI that collects email, password, and full name from new users. |
| `presentation/screens/otp_screen.dart` | The OTP verification screen where users enter the 6-digit code sent to their BINUS email after registration. |
| `presentation/screens/onboarding_screen.dart` | The first-time profile setup screen shown to newly verified users so they can complete their profile before entering the app. |

---

#### 💬 `features/chat/` — Lobby Chat
Provides real-time messaging within lobbies so players can coordinate before, during, and after a match.

| File | Purpose |
|---|---|
| `data/repositories/chat_repository_impl.dart` | Implements message operations using Supabase — fetching message history, inserting new messages, and subscribing to a **Supabase Realtime channel** to receive new messages as they are sent by other users, enabling a live chat experience. |
| `domain/entities/chat_message_entity.dart` | Data model representing a single chat message, including the sender, message content, timestamp, and which lobby it belongs to. |
| `domain/repositories/chat_repository.dart` | Abstract interface defining the chat contract — get existing messages, send a new message, subscribe to a real-time stream of incoming messages for a lobby, and unsubscribe to clean up the connection. |
| `presentation/bloc/chat_bloc.dart` | Manages the chat state — holds the current message list, handles sending new messages, and keeps the UI in sync with real-time messages arriving from the Supabase subscription. |
| `presentation/screens/lobby_chat_screen.dart` | The chat UI for a specific lobby where users can view message history and send new messages in real-time. |

---

#### 🏠 `features/home/` — Dashboard

| File | Purpose |
|---|---|
| `presentation/screens/home_screen.dart` | The main landing screen shown after login. It serves as the app's dashboard, displaying highlights like upcoming matches, active lobbies, and quick-access buttons to navigate to key features. Designed with a premium dark aesthetic consistent with the app's theme. |

---

#### 🏆 `features/leaderboard/` — Rankings
Displays sport-specific player rankings based on ELO rating, with optional campus filtering to compare within a specific BINUS location.

| File | Purpose |
|---|---|
| `data/repositories/leaderboard_repository_impl.dart` | Fetches ranked player data from Supabase, joining leaderboard entries with profile data to display player names and avatars alongside their rankings. |
| `domain/entities/leaderboard_entry_entity.dart` | Data model for a single row in the leaderboard — contains the player's profile info, ELO rating, rank position, and win/loss statistics. |
| `domain/repositories/leaderboard_repository.dart` | Abstract interface for retrieving leaderboard data filtered by sport type and optionally by campus, as well as looking up a specific player's ranking. |
| `presentation/bloc/leaderboard_bloc.dart` | Manages the leaderboard state — handles loading ranked data, applying sport and campus filters, and refreshing the list. |
| `presentation/screens/leaderboard_screen.dart` | The leaderboard UI showing a ranked list of players with tabs or filters to switch between different sports. |

---

#### 🏟️ `features/lobby/` — Matchmaking Lobbies
The core feature of the app. Lobbies are rooms that a player (host) creates for a specific sport, date/time, and player count. Other players can browse, filter, and join open lobbies. Lobbies support ELO range restrictions, deposit requirements, and geolocation.

| File | Purpose |
|---|---|
| `data/repositories/lobby_repository_impl.dart` | Implements lobby operations against Supabase — creating lobbies, fetching lobby lists with filters, loading individual lobby details (joining with host profile data for the host's name), managing participants, and updating lobby status through its lifecycle. |
| `domain/entities/lobby_entity.dart` | A rich data model representing a lobby with 25+ fields: host info, title, sport type, description, scheduled date/time, duration, player limits (min/max), current player count, ELO range restrictions, deposit amounts, lobby status, GPS coordinates for the venue, and lifecycle timestamps (confirmed, finished, settled, cancelled). Also includes computed properties like whether the lobby is full, has enough players, or requires a deposit. |
| `domain/entities/lobby_participant_entity.dart` | Data model for a player who has joined a lobby — tracks their user ID, team assignment, participation status (joined, waitlisted, confirmed, etc.), and when they joined. |
| `domain/repositories/lobby_repository.dart` | Abstract interface defining lobby operations — list lobbies with sport/status filters, get a specific lobby, get participants, create a lobby, join/leave a lobby, update lobby status, and get lobbies the current user is part of. |
| `presentation/bloc/create_lobby_bloc.dart` | Manages the state for the lobby creation form — handles form validation and submission to create a new lobby. |
| `presentation/bloc/lobby_detail_bloc.dart` | Manages the state for viewing a single lobby — loads the lobby details and its participant list, and handles join/leave actions. |
| `presentation/bloc/lobby_list_bloc.dart` | Manages the state for the lobby browser — loads all available lobbies and applies sport/status filters. |
| `presentation/screens/create_lobby_screen.dart` | The lobby creation form where hosts specify sport, date/time, player limits, ELO range, deposit amount, and description. |
| `presentation/screens/lobby_list_screen.dart` | The browsable list of all available lobbies with sport and status filter options. |
| `presentation/screens/lobby_detail_screen.dart` | The detailed view of a single lobby showing all information, the list of participants, and action buttons (join, leave, open chat, start match). |

---

#### ⚔️ `features/match/` — Match Results & History
Handles recording and viewing the results of completed sports matches. After a lobby's match is played, the host submits scores, and the system calculates ELO changes. Matches can be "settled" to finalize ELO adjustments and process deposit returns/forfeitures.

| File | Purpose |
|---|---|
| `data/repositories/match_repository_impl.dart` | Implements match operations against Supabase — submitting match results with scores, retrieving match data by lobby, loading a user's match history, and settling matches. |
| `domain/entities/match_entity.dart` | Data model for a completed match — contains the linked lobby ID, sport type, play date, duration, team A and team B scores, a map of ELO changes per player, whether the match has been settled, and a computed result label ("Team A Wins", "Team B Wins", or "Draw"). |
| `domain/entities/match_participant_entity.dart` | Data model for an individual player's involvement in a match — their team assignment and personal ELO change from that game. |
| `domain/repositories/match_repository.dart` | Abstract interface for match operations — submit a result with scores, get a match by its lobby, get participants of a match, retrieve the user's match history, and settle a match to finalize ELO and deposits. |
| `presentation/bloc/match_bloc.dart` | Manages match state — handles result submission, loading match details, and settlement processing. |
| `presentation/screens/match_result_screen.dart` | The UI for submitting or viewing the score of a match tied to a specific lobby. |
| `presentation/screens/match_history_screen.dart` | A scrollable list showing the user's past matches with scores, results, and ELO changes. |

---

#### 🔔 `features/notifications/` — In-App Alerts
Delivers in-app notifications to keep users informed about lobby invites, match results, friend requests, and other events.

| File | Purpose |
|---|---|
| `data/repositories/notification_repository_impl.dart` | Implements notification operations against Supabase — fetching the user's notifications, marking individual notifications or all notifications as read, and counting unread items for the badge. |
| `domain/entities/notification_entity.dart` | Data model for a notification — contains a title, body, notification type, read/unread status, and creation timestamp. |
| `domain/repositories/notification_repository.dart` | Abstract interface for notification operations — get all notifications, mark as read (single or all), and get the unread count. |
| `presentation/bloc/notification_bloc.dart` | Manages notification state — holds the notification list and unread count for driving the UI badge indicator. This BLoC is provided globally from `main.dart` so the unread count is accessible from any screen. |
| `presentation/screens/notification_screen.dart` | The notification center UI displaying all alerts in a scrollable list with read/unread indicators. |

---

#### 👤 `features/profile/` — User Profile
Allows users to view and edit their personal profile including name, NIM, campus, avatar, and stats.

| File | Purpose |
|---|---|
| `data/repositories/profile_repository_impl.dart` | Implements profile read/write operations against the Supabase `profiles` table. |
| `domain/entities/profile_entity.dart` | Extended profile data model that goes beyond the basic `UserEntity` to include additional details like sports statistics, ELO ratings, and user preferences. |
| `domain/repositories/profile_repository.dart` | Abstract interface defining profile operations — load a profile by user ID and update profile fields. |
| `presentation/bloc/profile_bloc.dart` | Manages profile state — handles loading a user's profile data and processing profile update submissions. |
| `presentation/screens/profile_screen.dart` | The read-only profile view displaying the user's avatar, name, NIM, campus, and stats. Displayed without the bottom navigation bar. |
| `presentation/screens/profile_edit_screen.dart` | The editable profile form where users can update their personal information. Also displayed without the bottom nav bar. |

---

#### 👥 `features/social/` — Friends & Networking
Enables social connections between BINUS students — sending/accepting friend requests, browsing friend lists, and searching for other users.

| File | Purpose |
|---|---|
| `data/repositories/social_repository_impl.dart` | Implements friendship operations against Supabase, including joining with profile data to resolve names and avatar URLs for both the requester and addressee sides of each friendship. |
| `domain/entities/friendship_entity.dart` | Data model representing a friendship connection between two users — contains both user IDs, the friendship status (pending or accepted), display names and avatar URLs for both sides, and the creation date. |
| `domain/repositories/social_repository.dart` | Abstract interface for social operations — send a friend request, accept or reject a request, list accepted friends, list pending requests, search for users by name, and remove a friend. |
| `presentation/bloc/social_bloc.dart` | Manages social state — holds the friend list, pending request list, and user search results, and processes friend actions. |
| `presentation/screens/friends_screen.dart` | The friends list UI showing accepted friends and any pending incoming friend requests. |
| `presentation/screens/user_search_screen.dart` | The user search UI where students can find other BINUS users by name and send friend requests. |

---

#### 💳 `features/wallet/` — In-App Credits
A virtual currency system that lets users manage credits used for lobby deposits. When joining a lobby with a deposit requirement, the funds are held (locked) from the user's wallet and are either returned after a successful match or forfeited as a penalty for no-shows.

| File | Purpose |
|---|---|
| `data/repositories/wallet_repository_impl.dart` | Implements all wallet operations against Supabase — reading balances, recording transactions, processing top-ups, managing deposit holds/releases/forfeitures, and handling withdrawals. |
| `domain/entities/wallet_entity.dart` | Data model for a user's wallet — tracks `balance` (total credits), `held` (credits locked in active lobby deposits), and computes `available` (balance minus held) to show the actual spendable amount. |
| `domain/entities/credit_transaction_entity.dart` | Data model for a single transaction record — contains the transaction type, amount, balance after the transaction, a reference ID (linking to a lobby if deposit-related), a description, and timestamp. It also knows whether the transaction is a credit (adds funds) or debit (removes funds). |
| `domain/repositories/wallet_repository.dart` | Abstract interface for wallet operations — get wallet balance, get transaction history, top up credits, hold a deposit when joining a lobby, release a deposit after a match, forfeit a deposit for no-show penalties, and withdraw credits. |
| `presentation/bloc/wallet_bloc.dart` | Manages wallet state — holds the current balance and transaction history, and processes top-up, withdrawal, and deposit actions. |
| `presentation/screens/wallet_screen.dart` | The main wallet dashboard showing the user's balance, available funds, held deposits, and a scrollable transaction history. |
| `presentation/screens/top_up_screen.dart` | The form for adding new credits to the wallet. |
| `presentation/screens/withdraw_screen.dart` | The form for withdrawing credits from the wallet. |

---

### 📂 `lib/shared/` — Cross-Feature Code

Contains shared models and widgets used by multiple features to prevent code duplication.

#### `shared/models/` — Enums & Value Types
| File | Purpose |
|---|---|
| `sport_type.dart` | Enum defining the six supported sports: **Futsal**, **Basketball**, **Badminton**, **Volleyball**, **Tennis**, and **Table Tennis**. Each sport carries a display label, a Material icon, and a unique color used across lobby cards, leaderboards, and match screens. |
| `lobby_status.dart` | Enum defining the six lifecycle states of a lobby: **Open** (accepting players), **Confirmed** (minimum players met), **In Progress** (match underway), **Finished** (match completed), **Settled** (ELO and deposits processed), and **Cancelled**. Each status has a display label and a color for UI status badges. |
| `participant_status.dart` | Enum defining a player's state within a lobby: **Joined**, **Waitlisted** (lobby full, in queue), **Confirmed** (ready to play), **Removed** (kicked by host), **Left** (voluntarily departed), and **No Show** (didn't attend). |
| `skill_level.dart` | Enum for self-reported player skill: **Beginner** 🟢 ("Just starting out"), **Intermediate** 🟡 ("Play regularly"), and **Advanced** 🔴 ("Competitive level"). Used for player profiles and filtering. |
| `transaction_type.dart` | Enum for wallet transaction categories: **Top Up** (adding credits), **Deposit Hold** (locking funds for a lobby), **Deposit Release** (returning funds after a match), **Deposit Forfeit** (penalty for no-show), and **Refund**. Each type has an icon, color, and knows whether it's a credit (inflow) or debit (outflow) transaction. |

#### `shared/presentation/widgets/`
| File | Purpose |
|---|---|
| `main_scaffold.dart` | The shell layout widget that wraps all main app screens inside a `Scaffold` with a styled `BottomNavigationBar`. The nav bar has 4 tabs — **Home**, **Lobbies**, **Wallet**, and **Profile** — and automatically highlights the correct tab based on the current route. Tapping Profile uses `push` instead of `go`, which means the profile screen appears on top of the navigation stack without the bottom bar, giving it a fullscreen feel. |

---

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/anandiooooooooooooooooooooooooooooooooooooooooooooooooo/u-AOL-BeeSports.git
   cd u-AOL-BeeSports
   ```

2. **Set up environment variables** — create a `.env` file in the project root:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```
