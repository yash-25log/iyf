# ISKCON Youth Forum (IYF) Platform

## Phase 1 MVP

### Module: Preacher's Zone

---

# Vision

Create a centralized knowledge repository for ISKCON Youth Forum preachers, mentors, volunteers, and administrators.

Currently resources are scattered across WhatsApp groups, Google Drive folders, YouTube playlists, PDFs, PPTs, notes, and personal systems.

The objective is to create a searchable, permission-controlled repository that preserves institutional knowledge and makes preaching resources easily discoverable.

---

# Problem Statement

Current challenges:

* Resources are difficult to locate.
* Knowledge gets lost when leaders change.
* Duplicate content is repeatedly recreated.
* New preachers cannot easily access historical material.
* No centralized search exists.
* Permissions are managed manually.

---

# Success Metrics

Success is achieved when:

* Resources can be found within seconds.
* New preachers can onboard without asking multiple people.
* Historical content remains discoverable.
* Resource sharing becomes standardized.
* Admins can manage visibility and permissions centrally.

---

# User Roles

## Super Admin

Responsibilities:

* Manage users
* Manage permissions
* Manage categories
* Manage batches
* Manage all content
* View platform analytics

---

## Admin / Preacher

Responsibilities:

* Create topics
* Upload resources
* Organize categories
* Edit own content
* View permitted resources

---

## User

Responsibilities:

* Browse resources
* Search resources
* Bookmark resources
* Access permitted content

Users cannot upload resources.

---

# Core Concepts

## Category

High-level grouping.

Examples:

* Bhagavad Gita
* Youth Seminars
* Outreach
* Leadership
* Festivals
* Bhakti Shastri

---

## Topic

Represents a preaching subject.

Examples:

* Overcoming Stress
* Art of Mind Control
* Bhagavad Gita Chapter 2
* Public Speaking

A topic may contain multiple resources.

---

## Resource

Individual content attached to a topic.

Supported Types:

* YouTube Link
* Google Drive Link
* PDF
* PPT
* DOC
* External URL

---

# Topic Structure

Fields:

* Title
* Description
* Category
* Subcategory
* Speaker
* Tags
* Date
* Location
* Thumbnail
* Visibility
* Status

---

# Resource Structure

Fields:

* Title
* Resource Type
* URL
* Description

---

# Visibility Model

## Public

Visible to all authenticated users.

## Batch Based

Visible only to selected batches.

Examples:

* Gita Life 2025
* Gita Life 2026
* Youth Leaders
* Bhakti Shastri

## Admin Only

Visible only to admins and super admins.

---

# Search Requirements

Global search must support:

* Topic title
* Speaker
* Tags
* Category
* Location
* Resource title

Search should feel similar to Notion and Google Drive.

---

# Filters

Allow filtering by:

* Category
* Speaker
* Year
* Resource Type
* Location

---

# Dashboard

Display:

* Search Bar
* Recent Resources
* Popular Resources
* Categories
* Recently Added Topics

---

# Bookmarking

Users can:

* Save topics
* Save resources
* View bookmarks

---

# Non-Functional Requirements

* Mobile responsive
* Fast loading
* Accessible
* Secure
* Scalable
* Role-based access control
* Audit logging support

---

# MVP Scope

Included:

* Authentication
* User Management
* Categories
* Topics
* Resources
* Search
* Bookmarks
* Batch Permissions

Excluded:

* Event Calendar
* Course Builder
* Attendance Tracking
* Devotee CRM
* WhatsApp Automation
* Analytics Dashboard
* Mobile App

These will be Phase 2+ modules.
