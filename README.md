# Autophagy

<p>
  <img src="README.assets/liveActivity.png" alt="Live Activity" width="520">
</p>

<p>
  <img src="README.assets/dynamicIsland.png" alt="Dynamic Island" width="520">
</p>

<p>
  <img src="README.assets/tracker.png" alt="Tracker screen" width="220">
  <img src="README.assets/history.png" alt="History screen" width="220">
  <img src="README.assets/settings.png" alt="Settings screen" width="220">
</p>

Autophagy is a native iOS 26.2+ fasting timer app. It lets the user select a fasting duration, start a countdown, keep the session visible through system alarm and Live Activity surfaces, and review completed sessions in history.

## Glossary

- **Fasting session:** A user-tracked fasting interval with `startedAt`, optional `endedAt`, and `plannedDurationSeconds`.
- **Active session:** A fasting session that has started and has no `endedAt` value yet.
- **Completed session:** A fasting session with an `endedAt` value, shown in History.
- **Selected duration:** The user-selected target duration while the tracker is idle.
- **Planned duration:** The countdown duration used for a started fasting session. For selected durations above 23 hours, the app subtracts 2 seconds before scheduling the system countdown.
- **Remaining duration:** The countdown time left until the planned end date.
- **Tracker status:** The current tracker state, either `idle` or `running`.
- **Alarm:** The system countdown scheduled through AlarmKit for the active session.
- **Live Activity:** The lock screen and Dynamic Island surface that displays the active countdown.
- **External stop:** A session completion caused by the tracker alarm disappearing outside the main app flow.
- **Coordinator:** The app-level navigation object that owns tabs, navigation paths, and modal presentation.

## Functional Requirements

- The user can select a fasting duration from 1 to 24 hours while the tracker is idle.
- The app persists the selected fasting duration in user preferences.
- When starting a session with a selected duration above 23 hours, the app subtracts 2 seconds before scheduling the countdown.
- The user can start a fasting session only while the tracker is idle.
- The app checks AlarmKit authorization before starting a fasting session and requests it when needed.
- If AlarmKit authorization is denied, the app does not start the timer and shows a permission alert.
- If alarm scheduling fails, the app keeps the tracker idle and does not create a new active session.
- When alarm scheduling succeeds, the app starts the countdown and creates or reuses an active session.
- The app loads any active session from SwiftData when the tracker view model is initialized and either resumes it or completes it if it already expired.
- The user can stop a running fasting session manually.
- A running fasting session completes automatically when its remaining duration reaches zero.
- A running fasting session completes as an external stop when the tracker alarm no longer exists.
- Completed sessions are persisted in SwiftData and displayed in History.
- The user can delete completed sessions from History.
- The settings screen is presented modally through the app coordinator.

## Technical Requirements

- The app targets iOS 26.2+ and uses the SwiftUI app lifecycle.
- The app uses MVVM + Coordinator for presentation, state, navigation, and modal routing.
- SwiftData stores fasting session data through `AutophagySchemaV1.Session`.
- UserDefaults stores the selected fasting duration through `Preferences`.
- AlarmKit schedules, observes, and cancels the active countdown alarm.
- ActivityKit and WidgetKit render the Live Activity extension.
- AppIntents exposes the Live Activity stop action through `TrackerStopIntent`.
- The app uses dark appearance and localized resources.

## Use Case Diagram

```mermaid
flowchart LR
    User[User]

    subgraph Autophagy[Autophagy App]
        SelectDuration((Select fasting duration))
        StartTimer((Start fasting timer))
        TrackCountdown((Track active countdown))
        StopTimer((Stop fasting timer))
        ReviewHistory((Review completed sessions))
        OpenSettings((Open settings links))
    end

    subgraph System[System Services]
        Alarm((Schedule alarm))
        LiveActivity((Show Live Activity))
        SwiftData((Persist session history))
    end

    User --> SelectDuration
    User --> StartTimer
    User --> TrackCountdown
    User --> StopTimer
    User --> ReviewHistory
    User --> OpenSettings

    StartTimer --> Alarm
    StartTimer --> LiveActivity
    StopTimer --> SwiftData
    ReviewHistory --> SwiftData
    TrackCountdown --> LiveActivity
```

## Activity Diagram

```mermaid
flowchart TD
    Idle([Tracker is idle]) --> SelectDuration[User selects fasting duration]
    SelectDuration --> PersistPreference[TrackerViewModel saves selected duration in Preferences]
    PersistPreference --> Start[User taps start]
    Start --> IsIdle{Tracker status is idle?}
    IsIdle -- No --> EndNoChange([No state change])
    IsIdle -- Yes --> PrepareDuration[TrackerViewModel clamps duration and subtracts 2 seconds if above 23 hours]
    PrepareDuration --> RequestAlarm[AlarmCoordinator checks or requests alarm authorization]
    RequestAlarm --> Authorized{Authorization granted?}
    Authorized -- No --> ShowPermissionAlert[TrackerViewModel shows alarm permission alert]
    ShowPermissionAlert --> EndNoChange
    Authorized -- Yes --> ScheduleAlarm[AlarmCoordinator schedules countdown alarm]
    ScheduleAlarm --> Scheduled{Alarm scheduled?}
    Scheduled -- No --> EndNoChange
    Scheduled -- Yes --> SetRunningState[TrackerViewModel sets running state]
    SetRunningState --> StartSession[SessionStore creates or reuses active session]
    StartSession --> Running([Tracker running state is ready])
    Running --> Refresh[TrackerViewModel refreshes timer state]
    Refresh --> TimeExpired{Remaining duration <= 0?}
    TimeExpired -- Yes --> CompleteExpired[Complete session as expired]
    TimeExpired -- No --> AlarmExists{Tracker alarm still exists?}
    AlarmExists -- No --> CompleteExternal[Complete session as external stop]
    AlarmExists -- Yes --> Running
    Running --> ManualStop[User taps stop]
    ManualStop --> CancelAlarm[AlarmCoordinator cancels tracker alarm]
    CancelAlarm --> CompleteManual[Complete session as manual stop]
    CompleteExpired --> SaveHistory[SessionStore saves endedAt]
    CompleteExternal --> SaveHistory
    CompleteManual --> SaveHistory
    SaveHistory --> ReloadHistory[HistoryViewModel reloads completed sessions]
    ReloadHistory --> ResetState([Tracker returns to idle])
```

## Tracker State Diagram

```mermaid
stateDiagram-v2
    [*] --> Idle: no active session
    [*] --> Running: active session restored

    state Idle {
        [*] --> Ready
        Ready: User can change duration
    }

    state Running {
        [*] --> Countdown
        Countdown: Timer is active
    }

    Idle --> Running: start succeeds
    Idle --> Idle: start fails or permission denied
    Running --> Idle: user stops timer
    Running --> Idle: timer expires
    Running --> Idle: restored session already expired
    Running --> Idle: alarm is stopped outside app
    Running --> Running: timer refreshes
```

## Start Timer Sequence Diagram

```mermaid
sequenceDiagram
    actor User
    participant Panel as PanelView
    participant ViewModel as TrackerViewModel
    participant AlarmCoordinator
    participant AlarmKit as AlarmManager
    participant Store as SessionStore
    participant SwiftData as ModelContext

    User->>Panel: Tap start
    Panel->>ViewModel: start()

    alt status is not idle
        ViewModel-->>Panel: Return without changes
    else status is idle
        ViewModel->>ViewModel: Capture startDate and adjusted plannedDuration
        ViewModel->>AlarmCoordinator: scheduleCountdown(duration, plannedDuration)
        AlarmCoordinator->>AlarmKit: requestAuthorization() if needed

        alt authorization denied
            AlarmCoordinator-->>ViewModel: authorizationDenied
            ViewModel->>ViewModel: isAlarmPermissionAlertPresented = true
            ViewModel-->>Panel: Return without starting
        else authorization granted
            AlarmCoordinator->>AlarmKit: schedule(id, configuration)

            alt schedule failed after retry
                AlarmCoordinator-->>ViewModel: failed
                ViewModel-->>Panel: Return without starting
            else scheduled
                AlarmCoordinator-->>ViewModel: scheduled
                ViewModel->>ViewModel: Set startedAt, endsAt, remainingDuration, status = running
                ViewModel->>Store: startSessionIfNeeded(durationSeconds, startedAt)
                Store->>SwiftData: Fetch active sessions

                alt active session exists
                    Store-->>ViewModel: Existing SessionModel
                else no active session
                    Store->>SwiftData: Insert SessionModel
                    Store->>SwiftData: save()
                    Store-->>ViewModel: New SessionModel
                end

                ViewModel-->>Panel: Running state published
            end
        end
    end
```

## Data Flow Diagram

```mermaid
flowchart LR
    User[User]

    subgraph UI[SwiftUI UI]
        TrackerView[TrackerView]
        TrackerPanel[PanelView]
        HistoryView[HistoryView]
        LiveActivity[LiveActivity]
    end

    subgraph State[Observable State]
        TrackerVM[TrackerViewModel]
        HistoryVM[HistoryViewModel]
        Coordinator[AppCoordinator]
    end

    subgraph Services[Services]
        Preferences[Preferences]
        Store[SessionStore]
        AlarmCoordinator[AlarmCoordinator]
    end

    subgraph Storage[Persistence]
        UserDefaults[UserDefaults]
        SwiftData[SwiftData ModelContext]
        Session[SessionModel]
    end

    subgraph System[System Surfaces]
        AlarmKit[AlarmKit AlarmManager]
        ActivityKit[ActivityKit and WidgetKit]
    end

    User --> TrackerView
    User --> HistoryView
    User --> LiveActivity

    TrackerView --> Coordinator
    TrackerView --> TrackerVM
    TrackerPanel --> TrackerVM
    HistoryView --> HistoryVM

    Coordinator --> TrackerView
    Coordinator --> HistoryView

    TrackerVM --> Preferences
    Preferences --> UserDefaults
    UserDefaults --> Preferences
    Preferences --> TrackerVM

    TrackerVM --> AlarmCoordinator
    AlarmCoordinator --> AlarmKit
    AlarmKit --> AlarmCoordinator
    AlarmCoordinator --> TrackerVM

    TrackerVM --> Store
    HistoryVM --> Store
    Store --> SwiftData
    SwiftData --> Session
    Session --> Store
    Store --> TrackerVM
    Store --> HistoryVM

    AlarmKit --> ActivityKit
    ActivityKit --> LiveActivity
    LiveActivity --> AlarmKit
```

## Architecture

Autophagy uses MVVM + Coordinator. Feature views render SwiftUI state, view models own screen behavior and service coordination, and `AppCoordinator` owns tabs, navigation paths, and modal presentation.

## Class Diagram

```mermaid
classDiagram
    class AutophagyApp {
        -ApplicationContainer container
    }

    class ApplicationContainer {
        +ModelContainer modelContainer
        +AppCoordinator appCoordinator
        +TrackerViewModel trackerViewModel
        +HistoryViewModel historyViewModel
    }

    class AppCoordinator {
        +Tab selectedTab
        +NavigationPath trackerPath
        +NavigationPath historyPath
        +Sheet? presentedSheet
        +presentSettings()
        +dismissSheet()
    }

    class AppCoordinatorView {
        -AppCoordinator coordinator
    }

    class TrackerView {
        -AppCoordinator coordinator
        -TrackerViewModel trackerViewModel
    }

    class HistoryView {
        -HistoryViewModel historyViewModel
    }

    class SettingsView

    class TrackerViewModel {
        +TimeInterval plannedDuration
        +TimeInterval remainingDuration
        +Status status
        +Date? startedAt
        +Date? endsAt
        +Bool isAlarmPermissionAlertPresented
        +updateDuration(hours: Int)
        +updateDuration(seconds: Int)
        +start() async
        +stop()
        +refreshSessionState()
        +refreshTimer(now: Date?)
        +remainingDuration(at: Date) TimeInterval
        +elapsedDuration(at: Date) TimeInterval
    }

    class HistoryViewModel {
        +Record[] records
        +TimeInterval totalDuration
        +String fastCountText
        +String dateRangeText
        +String summaryText
        +reloadRecords()
        +deleteRecord(Record)
    }

    class SessionStore {
        +loadActiveSession() SessionModel?
        +startSessionIfNeeded(durationSeconds: Int, startedAt: Date) SessionModel
        +completeSession(SessionModel, endedAt: Date)
        +fetchCompletedSessions() SessionModel[]
        +deleteSession(id: UUID)
    }

    class Preferences {
        +Int selectedDurationSeconds
        +reset()
    }

    class AlarmCoordinating {
        <<protocol>>
        +AsyncStream~Void~ alarmUpdates
        +scheduleCountdown(duration: TimeInterval, plannedDuration: TimeInterval) async AlarmScheduleResult
        +cancel()
        +hasActiveAlarm() Bool
    }

    class AlarmCoordinator
    class Record
    class SessionModel
    class ModelContainer

    AutophagyApp *-- ApplicationContainer
    AutophagyApp --> AppCoordinatorView
    ApplicationContainer *-- AppCoordinator
    ApplicationContainer *-- TrackerViewModel
    ApplicationContainer *-- HistoryViewModel
    ApplicationContainer *-- ModelContainer
    ApplicationContainer ..> SessionStore
    ApplicationContainer ..> Preferences
    ApplicationContainer ..> AlarmCoordinator

    AppCoordinatorView --> AppCoordinator
    AppCoordinatorView --> TrackerView
    AppCoordinatorView --> HistoryView
    AppCoordinatorView --> SettingsView

    TrackerView --> AppCoordinator
    TrackerView --> TrackerViewModel
    HistoryView --> HistoryViewModel

    TrackerViewModel --> SessionStore
    TrackerViewModel --> Preferences
    TrackerViewModel --> AlarmCoordinating
    HistoryViewModel --> SessionStore
    HistoryViewModel --> Record
    SessionStore --> SessionModel
    Record ..> SessionModel
    AlarmCoordinator ..|> AlarmCoordinating
```

## Component Diagram

```mermaid
flowchart TB
    subgraph AppTarget[Autophagy iOS App]
        App[AutophagyApp]
        Container[ApplicationContainer]
        Coordinator[AppCoordinator and AppCoordinatorView]

        subgraph Modules[Feature Modules]
            Tracker[Tracker Module]
            History[History Module]
            Settings[Settings Module]
        end

        subgraph Services[Services]
            Store[SessionStore]
            Preferences[Preferences]
            AlarmService[AlarmCoordinator]
        end

        Schema[AutophagySchemaV1]
        Resources[Resources and Localized Strings]
    end

    subgraph ExtensionTarget[LiveActivity Extension]
        LiveActivity[LiveActivity Widget]
        StopIntent[TrackerStopIntent]
        ActivityMetadata[TrackerActivityMetadata]
    end

    subgraph AppleFrameworks[Apple Frameworks]
        SwiftUI[SwiftUI]
        SwiftData[SwiftData]
        AlarmKit[AlarmKit]
        ActivityKit[ActivityKit]
        WidgetKit[WidgetKit]
        AppIntents[AppIntents]
    end

    App --> Container
    App --> Coordinator
    Container --> Coordinator
    Container --> Tracker
    Container --> History
    Container --> Services
    Coordinator --> Tracker
    Coordinator --> History
    Coordinator --> Settings

    Tracker --> Store
    Tracker --> Preferences
    Tracker --> AlarmService
    History --> Store
    Store --> Schema
    Store --> SwiftData
    AlarmService --> AlarmKit
    AlarmService --> StopIntent

    LiveActivity --> ActivityMetadata
    LiveActivity --> StopIntent
    LiveActivity --> ActivityKit
    LiveActivity --> WidgetKit
    StopIntent --> AppIntents
    StopIntent --> AlarmKit

    AppTarget --> SwiftUI
    ExtensionTarget --> SwiftUI
    AppTarget --> Resources
```

## ERD

```mermaid
erDiagram
    SESSION {
        UUID id
        Int plannedDurationSeconds
        Date startedAt
        Date endedAt "nullable"
    }
```

## Project Structure

```text
Autophagy/
  Source/
    iOS/
      Extension/       Shared Swift extensions
      LiveActivity/    Widget extension, ActivityKit layout, AppIntent stop action
      Model/           SwiftData schema and migration plan
      Module/          User-facing features: tracker, history, settings
      Resource/        Assets, strings, constants, colors, fonts, layout values
      Service/
        Alarm/         Alarm scheduling, observation, and protocol contract
        Persistence/   SessionStore over SwiftData
        Preferences/   Preferences over UserDefaults
      AppCoordinator.swift
      AppCoordinatorView.swift
      ApplicationContainer.swift
      AutophagyApp.swift
    Test/              Swift Testing unit tests
  Frameworks/          Referenced Apple framework headers
  Products/            Built app, extension, and test products
```

## Main Modules

- **Tracker:** duration selection, countdown state, start/stop actions, timer refresh, and alarm scheduling.
- **History:** completed fasting sessions loaded from SwiftData and displayed as records.
- **Live Activity:** lock screen and Dynamic Island presentation for the active timer, including a stop intent.
- **Settings:** links to source code, support, and privacy policy.
