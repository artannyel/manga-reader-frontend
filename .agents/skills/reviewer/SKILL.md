---
name: reviewer
description: Skill for reviewing and validating Clean Architecture Flutter code, state management, routes, and local databases.
---

# Reviewer Skill (Frontend)

This skill is used to validate implemented Flutter code.

## Guidelines

1. **Layer Enforcement**:
   - Check that no presentation layer component references a datasource directly.
   - Verify that all data mapping (models to entities) occurs in the data layer.

2. **Network & Offline Rules**:
   - Verify that connectivity checks redirect user navigation appropriately to the offline screen.
   - Verify that download locations are secure and hidden via `.nomedia`.

3. **Riverpod & State Check**:
   - Ensure Riverpod states are immutable.
   - Prevent state leaks or memory leaks by checking proper notifier cleanups.
