# PROJECT_RULES.md

## Engineering Principles

Act as a Staff-Level Software Engineer.

Prioritize:

* Simplicity
* Readability
* Maintainability
* Scalability
* Type Safety

Avoid:

* Premature optimization
* Overengineering
* Unnecessary abstractions

---

# Tech Stack

Frontend:

* Next.js
* TypeScript
* Tailwind
* Shadcn UI

Backend:

* Supabase
* PostgreSQL

State:

* React Query
* Zustand

---

# Architecture Rules

Use:

* Feature-first architecture
* Modular design
* Separation of concerns
* SOLID principles

Example:

src/

features/
auth/
users/
categories/
topics/
resources/
search/
bookmarks/

shared/
components/
hooks/
utils/
types/
constants/

---

# Component Rules

Components must:

* Have a single responsibility
* Be reusable
* Be composable

Avoid:

* Giant components
* Duplicated UI
* Deep prop drilling

Maximum target size:

* Components: 200 lines
* Hooks: 100 lines

---

# Data Model Rules

Use UUIDs.

Every table must contain:

* id
* created_at
* updated_at
* created_by
* updated_by

Support soft deletion where appropriate.

---

# API Rules

Use consistent naming.

Examples:

GET /topics

GET /topics/:id

POST /topics

PATCH /topics/:id

DELETE /topics/:id

Support:

* Pagination
* Filtering
* Sorting

---

# Security Rules

Implement:

* Supabase Authentication
* RBAC
* Route Protection
* Input Validation
* File Validation

Never trust client input.

---

# Permission Rules

Roles:

* SUPER_ADMIN
* ADMIN
* PREACHER
* USER

Permissions must be enforced:

* Database Layer
* API Layer
* UI Layer

Frontend permissions alone are not sufficient.

---

# Search Rules

Search must support:

* Topic Title
* Resource Title
* Speaker
* Tags
* Category
* Location

Design architecture so Elasticsearch can be introduced later.

---

# UI Principles

Inspired by:

* Notion
* Linear
* GitHub
* Google Drive

Requirements:

* Clean
* Modern
* Fast
* Mobile-first

Avoid:

* Clutter
* Excessive colors
* Complex navigation

---

# AI Agent Workflow

Before writing code:

1. Create architecture.
2. Create schema.
3. Create APIs.
4. Create user flows.
5. Explain implementation plan.

Only then generate code.

---

# Development Process

Build one feature at a time.

Order:

1. Authentication
2. RBAC
3. Categories
4. Topics
5. Resources
6. Search
7. Bookmarks
8. Batch Permissions

Complete one feature before starting another.

---

# Code Quality

Required:

* TypeScript strict mode
* ESLint
* Prettier

Prefer:

* Reuse over duplication
* Clear naming
* Small functions
* Predictable structure

The code should be understandable by a new developer within one day.

---

# Important

Do not generate code immediately.

Always provide:

* Architecture
* Data model
* API design
* User flow

and wait for approval before implementation.
