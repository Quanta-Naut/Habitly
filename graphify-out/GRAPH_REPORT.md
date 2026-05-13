# Graph Report - Habit Tracker  (2026-05-05)

## Corpus Check
- 49 files · ~22,662 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 314 nodes · 327 edges · 22 communities detected
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 13 edges
2. `../theme/app_theme.dart` - 10 edges
3. `AppDelegate` - 8 edges
4. `../models/habit.dart` - 7 edges
5. `../controllers/habit_controller.dart` - 6 edges
6. `Create()` - 6 edges
7. `Destroy()` - 6 edges
8. `MessageHandler()` - 5 edges
9. `RunnerTests` - 4 edges
10. `OnCreate()` - 4 edges

## Surprising Connections (you probably didn't know these)
- `fl_register_plugins()` --calls--> `my_application_activate()`  [INFERRED]
  linux\flutter\generated_plugin_registrant.cc → linux\runner\my_application.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux\runner\main.cc → linux\runner\my_application.cc
- `RegisterPlugins()` --calls--> `OnCreate()`  [INFERRED]
  windows\flutter\generated_plugin_registrant.cc → windows\runner\flutter_window.cpp
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  windows\runner\flutter_window.cpp → windows\runner\win32_window.cpp
- `OnCreate()` --calls--> `SetChildContent()`  [INFERRED]
  windows\runner\flutter_window.cpp → windows\runner\win32_window.cpp

## Communities

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (40): app.dart, _activeCountForHabit, _addMonths, bestStreakForHabit, buildInsightsSummary, calendarStatusOn, canEditDate, _clampEditableDate (+32 more)

### Community 1 - "Community 1"
Cohesion: 0.06
Nodes (33): build, HabitTrackerApp, MaterialApp, copyWith, Habit, AppColors, buildAppTheme, ThemeData (+25 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (27): build, Color, Column, Container, Expanded, _heatColor, _HeatmapGrid, _HeatmapLegend (+19 more)

### Community 3 - "Community 3"
Cohesion: 0.07
Nodes (26): build, _calendarBorderColor, _calendarCellColor, _CalendarSheet, _CalendarSheetState, _calendarTextColor, _canShowNextMonth, Center (+18 more)

### Community 4 - "Community 4"
Cohesion: 0.08
Nodes (21): HabitRepository, HabitStore, BoxDecoration, build, _cellColor, _cellDecoration, Color, Container (+13 more)

### Community 5 - "Community 5"
Cohesion: 0.14
Nodes (18): RegisterPlugins(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle(), GetWindowClass() (+10 more)

### Community 6 - "Community 6"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 7 - "Community 7"
Cohesion: 0.15
Nodes (12): AlertDialog, build, Container, Expanded, _HeroMetric, _InfoChip, ListView, _ManageCard (+4 more)

### Community 8 - "Community 8"
Cohesion: 0.15
Nodes (12): AddHabitSheet, _AddHabitSheetState, AnimatedContainer, build, _ChoiceTile, dispose, GestureDetector, initState (+4 more)

### Community 9 - "Community 9"
Cohesion: 0.17
Nodes (11): AddHabitSheet, AnimatedBuilder, AppShell, _AppShellState, build, dispose, initState, Scaffold (+3 more)

### Community 10 - "Community 10"
Cohesion: 0.17
Nodes (11): _ActionCard, AlertDialog, build, Container, Icon, ListView, Material, ProfileScreen (+3 more)

### Community 11 - "Community 11"
Cohesion: 0.22
Nodes (3): FlutterAppDelegate, FlutterImplicitEngineDelegate, AppDelegate

### Community 12 - "Community 12"
Cohesion: 0.22
Nodes (8): NotificationDetails, NotificationService, _schedule, package:flutter_local_notifications/flutter_local_notifications.dart, package:flutter/services.dart, package:flutter_timezone/flutter_timezone.dart, package:timezone/data/latest_all.dart, package:timezone/timezone.dart

### Community 13 - "Community 13"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 14 - "Community 14"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 15 - "Community 15"
Cohesion: 0.4
Nodes (2): RunnerTests, XCTestCase

### Community 16 - "Community 16"
Cohesion: 0.4
Nodes (1): FlutterWindow()

### Community 17 - "Community 17"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 18 - "Community 18"
Cohesion: 0.67
Nodes (1): GeneratedPluginRegistrant

### Community 19 - "Community 19"
Cohesion: 0.67
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 20 - "Community 20"
Cohesion: 0.67
Nodes (2): FlutterSceneDelegate, SceneDelegate

### Community 21 - "Community 21"
Cohesion: 1.0
Nodes (1): MainActivity

## Knowledge Gaps
- **197 isolated node(s):** `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `HabitTrackerApp`, `build` (+192 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 15`** (5 nodes): `RunnerTests.swift`, `RunnerTests.swift`, `RunnerTests`, `.testExample()`, `XCTestCase`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 16`** (5 nodes): `FlutterWindow()`, `MessageHandler()`, `OnDestroy()`, `flutter_window.cpp`, `flutter_window.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 17`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 18`** (3 nodes): `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant`, `.registerWith()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 19`** (3 nodes): `GeneratedPluginRegistrant.m`, `GeneratedPluginRegistrant`, `-registerWithRegistry`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 20`** (3 nodes): `FlutterSceneDelegate`, `SceneDelegate.swift`, `SceneDelegate`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 21`** (2 nodes): `MainActivity.kt`, `MainActivity`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `../models/habit.dart` connect `Community 4` to `Community 0`, `Community 3`, `Community 7`, `Community 8`, `Community 9`?**
  _High betweenness centrality (0.171) - this node is a cross-community bridge._
- **Why does `package:flutter/material.dart` connect `Community 1` to `Community 2`, `Community 3`, `Community 4`, `Community 7`, `Community 8`, `Community 9`, `Community 10`?**
  _High betweenness centrality (0.144) - this node is a cross-community bridge._
- **Why does `../theme/app_theme.dart` connect `Community 1` to `Community 2`, `Community 3`, `Community 4`, `Community 7`, `Community 8`, `Community 10`?**
  _High betweenness centrality (0.093) - this node is a cross-community bridge._
- **What connects `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry` to the rest of the system?**
  _197 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._