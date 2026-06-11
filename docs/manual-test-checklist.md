# Manual Test Checklist

Use this checklist after task 1 builds to verify the Flutter shell before implementing deeper flows.

## Startup

- [ ] App installs and starts on an Android emulator or phone.
- [ ] First screen is the home page.
- [ ] No debug counter/demo Flutter content is visible.
- [ ] Portrait phone layout has no obvious overflow.

## Home

- [ ] Top background shows a soft blue-purple-pink gradient only in the upper quarter of the screen.
- [ ] Lower three quarters of the page remain white or near-white.
- [ ] Header, three white cards, card shadows, rounded corners, and bottom input bar are visually close to the Pencil home page.
- [ ] Empty course, todo, and DDL states are shown instead of fake business data.
- [ ] Tapping the settings icon opens Settings and back returns Home.
- [ ] Tapping the next-class card opens Schedule placeholder and back returns Home.
- [ ] Tapping the next-thing card opens Todo placeholder and back returns Home.
- [ ] Tapping the quick-pick icon opens Next Thing placeholder and back returns Home.
- [ ] Tapping the DDL card opens Todo placeholder with deadline-filter semantics.
- [ ] Tapping the search icon opens Todo Search placeholder and back returns Home.
- [ ] Tapping the bottom input text opens the create-todo bottom sheet.
- [ ] Create-todo sheet shows the one-line prompt, manual-create entry, goal-split entry, and disabled send button when empty.
- [ ] Typing into the create-todo sheet enables the send button.

## Settings

- [ ] Settings page opens from Home.
- [ ] The page shows `课表与作息` and `数据与分享` sections.
- [ ] Not-yet-implemented setting rows are visibly disabled or marked as pending, not presented as completed features.

## Route Shells

- [ ] Schedule placeholder can open Add Schedule placeholder.
- [ ] Todo placeholder can open the create-todo sheet.
- [ ] All placeholder pages can navigate back.

## Known Task-1 Limits

- [ ] No real local persistence is expected yet.
- [ ] No login, cloud sync, backend calls, or AI behavior is expected yet.
- [ ] Search, recommendations, schedule grid, todo CRUD, and goal split are placeholders for later roadmap tasks.
