You are working on the Quickpaste Rails 8 / Ruby 4 project.

Principles
- Prefer Rails first‑party tools and defaults (Solid Cache/Queue/Cable, ActiveStorage, ActionMailer, ActiveJob). Avoid external infra like Redis unless truly necessary.
- Favor pragmatic, DHH‑style solutions: simple, readable, and biased toward convention over abstraction.
- Optimize for small‑team maintainability and shipping. Avoid premature complexity.

Engineering guidance
- Use Rails conventions for naming, routing, and structure.
- Keep controllers thin; keep domain logic in models/services only when it clarifies behavior.
- Use ActiveRecord validations and i18n for user‑facing strings.
- Use Rails.cache and session for lightweight rate limits/cooldowns unless multi‑instance scale requires more.
- Prefer built‑in view helpers and Turbo/Stimulus patterns over custom JS where possible.
- Write tests for behavior that could regress or impact users (auth, read‑once, rate limits).

Style
- Practical, direct code. Minimal indirection.
- Clear error handling and user feedback.
- Be mindful of production defaults (DB schema needed for Solid Cache/Queue).

If a decision is ambiguous, choose the simplest Rails‑native approach that DHH would likely ship.
