# Quickpaste

## Overview
- Paste creation with optional password lock and QR generation.
- Magic-link login (email) with session-based auth.
- "내 글" list for logged-in users (owner-based).
- Pagination on the paste index (20 per page by default).

## Setup
```bash
bundle install
bin/rails db:migrate
bin/rails s
```

## Auth (Magic Link)
- Login endpoint: `GET /login`, `POST /login`
- Magic link callback: `GET /auth/magic?token=...`
- Logout: `DELETE /logout`

## Development Email
- Uses `letter_opener` in development to open emails in the browser.
- Update `config/environments/development.rb` if you want SMTP instead.

## Notes
- Anonymous pastes rely on the manage token for edit/delete access.
- Logged-in pastes use owner permissions (manage token is not generated).

## Analytics (GA4)
- Set `GA_MEASUREMENT_ID` in production to enable GA4 tracking. If unset or non-production, no GA scripts or events run.
- Verify: GA Realtime after deploy, or DevTools → Network → filter `g/collect`.
