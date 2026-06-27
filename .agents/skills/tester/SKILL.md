---
name: tester
description: Skill for designing and writing unit, widget, and integration tests in Flutter, mocking network clients, and asserting offline states.
---

# Tester Skill (Frontend)

This skill is used to plan and run Flutter tests.

## Guidelines

1. **Unit Testing**:
   - Write unit tests for Use Cases and State Notifiers.
   - Mock repositories and network calls using mockito or mocktail.

2. **Widget/UI Testing**:
   - Write widget tests for pages, checking the existence of specific text, buttons, and state transitions.
   - Test offline states by stubbing connectivity states.

3. **Database Test**:
   - Verify Isar/Hive schema actions (storing, listing, deleting downloaded mangas) using memory-based or mock databases.
