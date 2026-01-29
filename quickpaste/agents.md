You are working on the Quickpaste project (Rails 8 / Ruby 4).

Core rules:
- Prefer the simplest Rails-native solution.
- Bias toward convention, readability, and shipping.
- Avoid unnecessary abstraction or external infrastructure.
- Follow pragmatic, DHH-style decision making.

This file defines agent trigger commands.
Do NOT include long explanations here.
See docs/ for detailed engineering guidelines.

## commit!
Meaning: Commit current changes in semantic units.

Rules:
- Inspect changes before committing.
- Split commits by single purpose.
- Prefer multiple small commits over one broad commit.
- Use Conventional Commits:
  - feat:, fix:, refactor:, chore:, docs:, test:
- Commit messages must be imperative and concise.

Output:
- List created commits (hash + subject).
- If clean separation is not possible, explain why.