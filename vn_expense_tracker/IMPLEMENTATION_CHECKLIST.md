# IMPLEMENTATION_CHECKLIST.md

## Feature Implementation Checklist

Track your progress as you build out the full application.

---

## 🏗️ Foundation (COMPLETED ✅)

### Database & Architecture
- [x] Drift database schema
- [x] All CRUD operations
- [x] Category reassignment logic
- [x] Transaction aggregation queries
- [x] Seed data utility
- [x] Clean architecture structure
- [x] Domain entities
- [x] Repository pattern

### Core Services
- [x] Voice parser service (Vietnamese NLP)
- [x] STT abstraction layer
- [x] Currency utilities
- [x] Date utilities
- [x] Lunar calendar integration

### Testing
- [x] Voice parser tests (27 tests)
- [x] Currency utils tests (12 tests)
- [x] Test structure and mocks

### UI Foundation
- [x] App theme (light + dark)
- [x] Main navigation
- [x] Screen placeholders
- [x] Basic widgets

### Documentation
- [x] README.md
- [x] SETUP.md
- [x] ARCHITECTURE.md
- [x] API.md
- [x] Getting started guide

---

## 📱 Phase 1: Core Features

### Dashboard Screen
- [ ] Connect to real wallet data
- [ ] Display current balance from database
- [ ] Calculate month-over-month percentage
- [ ] Show recent 5 transactions from DB
- [ ] Implement wallet selection dropdown
- [ ] Add pull-to-refresh
- [ ] Handle loading states
- [ ] Handle error states

**Files to modify:**
- `lib/presentation/screens/dashboard/dashboard_screen.dart`
- `lib/presentation/widgets/wallet_balance_card.dart`
- `lib/presentation/widgets/recent_transactions.dart`
- Create: `lib/presentation/providers/wallet_provider.dart`
- Create: `lib/presentation/providers/transaction_provider.dart`

### Add Transaction Screen
- [ ] Create form layout
- [ ] Amount input with number keyboard
- [ ] Thousand separator formatting
- [ ] Category selection (expense/income tabs)
- [ ] Wallet selection
- [ ] Date picker (with default = today)
- [ ] Title input (optional)
- [ ] Note input (optional)
- [ ] Validation logic
- [ ] Save to database
- [ ] Navigate back with success message
- [ ] Handle errors gracefully

**Files to create:**
- `lib/presentation/screens/add_transaction/add_transaction_form.dart`
- `lib/presentation/screens/add_transaction/category_selector.dart`
- `lib/presentation/screens/add_transaction/wallet_selector.dart`
- `lib/presentation/providers/add_transaction_provider.dart`

### Transaction List & Editing
- [ ] Load transactions from database
- [ ] Group by date
- [ ] Show daily headers with totals
- [ ] Implement tap to edit
- [ ] Edit transaction dialog
- [ ] Delete with undo snackbar
- [ ] Swipe to delete gesture (optional)
- [ ] Infinite scroll/pagination
- [ ] Search functionality
- [ ] Filter by category
- [ ] Filter by wallet

**Files to create:**
- `lib/presentation/screens/transactions/transaction_list_screen.dart`
- `lib/presentation/screens/transactions/edit_transaction_dialog.dart`
- `lib/presentation/widgets/transaction_card.dart`
- `lib/presentation/widgets/daily_transaction_header.dart`

---

## 📊 Phase 2: Advanced Features

### History Screen
- [ ] Calendar view (month grid)
- [ ] Highlight days with transactions
- [ ] Show income/expense indicators on dates
- [ ] Tap date to show transactions
- [ ] Month navigation (prev/next)
- [ ] Jump to today button
- [ ] Lunar date display (optional)
- [ ] Summary cards for selected day
- [ ] Filter: current wallet / all wallets

**Files to create:**
- `lib/presentation/screens/history/history_calendar.dart`
- `lib/presentation/screens/history/day_transactions.dart`
- `lib/presentation/widgets/calendar_day_cell.dart`
- `lib/presentation/providers/calendar_provider.dart`

### Category Management
- [ ] List all categories (expense/income tabs)
- [ ] Create new category
- [ ] Icon picker dialog
- [ ] Color picker dialog
- [ ] Edit category
- [ ] Delete category
- [ ] **Reassignment dialog if has transactions**
- [ ] Validation: must have replacement category
- [ ] Show transaction count per category
- [ ] Prevent deletion if no alternative exists

**Files to create:**
- `lib/presentation/screens/category/category_list_screen.dart`
- `lib/presentation/screens/category/category_form_dialog.dart`
- `lib/presentation/screens/category/category_reassignment_dialog.dart`
- `lib/presentation/widgets/icon_picker.dart`
- `lib/presentation/widgets/color_picker.dart`
- `lib/presentation/providers/category_provider.dart`

### Wallet Management
- [ ] List all wallets
- [ ] Create new wallet
- [ ] Set initial balance
- [ ] Select currency
- [ ] Edit wallet
- [ ] Delete wallet (only if no transactions)
- [ ] Show current balance
- [ ] Show transaction count
- [ ] Set default wallet

**Files to create:**
- `lib/presentation/screens/wallet/wallet_list_screen.dart`
- `lib/presentation/screens/wallet/wallet_form_dialog.dart`
- `lib/presentation/widgets/wallet_card.dart`

---

## 🎤 Phase 3: Voice Input

### Voice Input Flow
- [ ] Full-screen voice recorder UI
- [ ] Microphone animation
- [ ] Display example phrases
- [ ] Request microphone permission
- [ ] Start/stop recording
- [ ] Show transcription in real-time
- [ ] Parse transcription on stop
- [ ] Preview parsed transaction
- [ ] Highlight missing fields
- [ ] Allow manual editing
- [ ] Confirm and save
- [ ] Handle STT errors gracefully

**Files to create:**
- `lib/presentation/screens/voice_input/voice_input_screen.dart`
- `lib/presentation/screens/voice_input/transaction_preview.dart`
- `lib/presentation/widgets/voice_recorder_widget.dart`
- `lib/presentation/widgets/parsing_indicator.dart`
- `lib/presentation/providers/voice_input_provider.dart`

---

## 📈 Phase 4: Statistics

### Statistics Screen
- [ ] Time range selector (week/month/year/custom)
- [ ] KPI cards (income/expense/net)
- [ ] Percentage change vs previous period
- [ ] Line chart: income & expense over time
- [ ] Donut chart: expense by category
- [ ] Donut chart: income by category
- [ ] Category breakdown list
- [ ] Top categories ranking
- [ ] Wallet filter
- [ ] Export data option

**Files to create:**
- `lib/presentation/screens/statistics/statistics_charts.dart`
- `lib/presentation/screens/statistics/kpi_cards.dart`
- `lib/presentation/screens/statistics/category_breakdown.dart`
- `lib/presentation/widgets/income_expense_line_chart.dart`
- `lib/presentation/widgets/category_donut_chart.dart`
- `lib/presentation/providers/statistics_provider.dart`

---

## ⚙️ Phase 5: Settings

### Settings Screen
- [ ] Theme selection (light/dark/system)
- [ ] Language selection (Vietnamese/English)
- [ ] Currency preference
- [ ] Daily reminder toggle
- [ ] Reminder time picker
- [ ] PIN lock toggle
- [ ] Set/change PIN dialog
- [ ] Backup to Google Drive
- [ ] Restore from backup
- [ ] Export to CSV
- [ ] About app info
- [ ] Version number
- [ ] Privacy policy (if applicable)

**Files to create:**
- `lib/presentation/screens/settings/settings_list.dart`
- `lib/presentation/screens/settings/theme_selector.dart`
- `lib/presentation/screens/settings/pin_setup_dialog.dart`
- `lib/presentation/screens/settings/backup_restore.dart`
- `lib/presentation/providers/settings_provider.dart`

### Security
- [ ] PIN hash storage
- [ ] PIN verification on app start
- [ ] Biometric authentication (optional)
- [ ] Auto-lock after timeout
- [ ] Failed attempt lockout

**Files to create:**
- `lib/services/security_service.dart`
- `lib/presentation/screens/security/pin_entry_screen.dart`

### Notifications
- [ ] Daily reminder notification
- [ ] Budget alert notifications (future)
- [ ] Configure notification channels

**Files to create:**
- `lib/services/notification_service.dart`

---

## 🔄 Phase 6: Backup & Export

### Google Drive Backup
- [ ] Google Sign-In integration
- [ ] Export database to JSON
- [ ] Upload to Drive
- [ ] List available backups
- [ ] Restore from backup
- [ ] Handle conflicts
- [ ] Progress indicators

**Files to create:**
- `lib/services/google_drive_service.dart`
- `lib/presentation/screens/backup/backup_screen.dart`
- `lib/presentation/screens/backup/restore_screen.dart`

### CSV Export
- [ ] Generate CSV from transactions
- [ ] Include all fields
- [ ] Date range selection
- [ ] Save to device storage
- [ ] Share via native share sheet

**Files to create:**
- `lib/services/csv_export_service.dart`

---

## 🎨 Phase 7: UI/UX Polish

### General Improvements
- [ ] Smooth page transitions
- [ ] Loading skeletons
- [ ] Empty state illustrations
- [ ] Error state illustrations
- [ ] Success animations
- [ ] Haptic feedback
- [ ] Pull-to-refresh on all lists
- [ ] Swipe gestures
- [ ] Accessibility improvements
- [ ] Screen reader support

### Dashboard Enhancements
- [ ] Monthly spending vs budget bar
- [ ] Quick insights card
- [ ] Streak counter (days tracked)
- [ ] Category quick add buttons

### Visual Polish
- [ ] Consistent spacing
- [ ] Proper color contrast
- [ ] Icon consistency
- [ ] Typography refinement
- [ ] Card shadows
- [ ] Button states (pressed/disabled)

---

## 🧪 Phase 8: Testing & Quality

### Unit Tests
- [ ] Database operations tests
- [ ] Provider logic tests
- [ ] Utility function tests
- [ ] Business logic tests
- [ ] Service tests

### Integration Tests
- [ ] Add transaction flow
- [ ] Edit transaction flow
- [ ] Delete transaction flow
- [ ] Category reassignment flow
- [ ] Voice input flow

### Widget Tests
- [ ] Dashboard screen
- [ ] Add transaction form
- [ ] Category management
- [ ] Settings screen
- [ ] Navigation tests

### Manual Testing
- [ ] Test on Android (various screen sizes)
- [ ] Test on iOS (various screen sizes)
- [ ] Test with real data
- [ ] Test edge cases
- [ ] Test error scenarios
- [ ] Test offline mode
- [ ] Test with slow database

---

## 🚀 Phase 9: Optimization

### Performance
- [ ] Database query optimization
- [ ] Add indexes where needed
- [ ] Implement pagination
- [ ] Lazy loading for large lists
- [ ] Image optimization
- [ ] Reduce app size
- [ ] Profile and fix jank

### Code Quality
- [ ] Remove debug prints
- [ ] Add TODO comments for future work
- [ ] Refactor duplicate code
- [ ] Improve error messages
- [ ] Add more comments
- [ ] Update documentation

---

## 📦 Phase 10: Release Preparation

### Android
- [ ] Configure app signing
- [ ] Create keystore
- [ ] Update build.gradle
- [ ] Set version code/name
- [ ] Create app icon
- [ ] Create splash screen
- [ ] Test release build
- [ ] Create Google Play listing
- [ ] Prepare screenshots
- [ ] Write app description

### iOS
- [ ] Configure Xcode project
- [ ] Set bundle identifier
- [ ] Create App Store icons
- [ ] Create launch screen
- [ ] Test on physical device
- [ ] Configure App Store listing
- [ ] Prepare screenshots
- [ ] Submit for review

### Both Platforms
- [ ] Privacy policy
- [ ] Terms of service (if applicable)
- [ ] Support contact info
- [ ] Beta testing with users
- [ ] Collect feedback
- [ ] Fix critical bugs
- [ ] Final QA pass

---

## 🎯 Optional Enhancements

### Advanced Features
- [ ] Recurring transactions
- [ ] Budget limits
- [ ] Budget alerts
- [ ] Multi-currency wallets
- [ ] Exchange rate support
- [ ] Receipt photo attachment
- [ ] Bill splitting
- [ ] Shared wallets
- [ ] Cloud sync (real-time)
- [ ] Web dashboard
- [ ] Expense predictions
- [ ] Category suggestions based on AI
- [ ] Bill reminders
- [ ] Investment tracking
- [ ] Debt tracking
- [ ] Export to PDF reports
- [ ] Customizable reports
- [ ] Widgets for home screen

---

## 📋 Daily Development Routine

### Morning
1. Pull latest changes
2. Run tests
3. Check task list
4. Pick highest priority task

### During Development
1. Write code incrementally
2. Test as you go
3. Commit often with clear messages
4. Keep tests passing

### Evening
1. Run full test suite
2. Run `flutter analyze`
3. Commit working code
4. Update this checklist
5. Plan tomorrow's tasks

---

## 🎓 Learning Goals

As you implement features:
- [ ] Master Riverpod state management
- [ ] Understand Drift database operations
- [ ] Learn Flutter animation
- [ ] Practice clean architecture
- [ ] Improve testing skills
- [ ] Build production-ready UI
- [ ] Handle edge cases gracefully

---

## ✅ Definition of Done

For each feature, ensure:
- [ ] Code is written and tested
- [ ] Unit tests are added
- [ ] UI looks good on multiple screen sizes
- [ ] Error handling is in place
- [ ] Loading states are shown
- [ ] Edge cases are handled
- [ ] Code is documented
- [ ] No TODO comments remain
- [ ] `flutter analyze` passes
- [ ] Manual testing completed
- [ ] Checkbox in this file is checked!

---

**Remember:** This is a marathon, not a sprint. Build incrementally, test often, and enjoy the process! 🚀

**Pro Tip:** Start with Phase 1, complete it fully before moving to Phase 2. A complete, working feature is better than multiple half-done features.

Good luck! 💪
