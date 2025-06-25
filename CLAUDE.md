# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**おくすり飲んでね** (Medicine Reminder App) - A Japanese medication reminder application designed to help families manage medication schedules. The app reduces stress around medication adherence by providing automated notifications to both medication takers and family guardians, with a gamification system through reward conditions.

## Tech Stack

- **Backend**: Ruby on Rails 7.2.2 with PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus) with Tailwind CSS
- **JavaScript**: esbuild bundling with Stimulus controllers
- **Authentication**: Devise with LINE OAuth integration
- **Background Jobs**: Sidekiq with Redis for async processing
- **Notifications**: LINE Messaging API
- **Localization**: Japanese primary language (rails-i18n)

## Development Commands

### Setup & Development
```bash
# Start development server with hot reloading
bin/dev

# Individual services (if needed)
bin/rails server
yarn build --watch
bin/rails tailwindcss:watch

# Database operations
bin/rails db:migrate
bin/rails db:seed
```

### Testing & Quality
```bash
# Run tests
bin/rails test
bin/rails test:system

# Code quality checks
bin/rubocop
bin/brakeman
```

### Background Jobs
```bash
# Start Sidekiq (for development)
bundle exec sidekiq
```

## Architecture Overview

### Core Models & Relationships
- **User**: LINE OAuth authenticated users
- **MedicationGroup**: Family medication groups (users can belong to max 3 groups)
- **MedicationGroupUser**: Join table with user roles (medication_taker: 0, family_guardian: 1)
- **MedicationSchedule**: Medication timing and reminder settings
- **MedicationManagement**: Daily medication tracking with reminder counts
- **MedicationGroupInvitation**: Secure token-based group invitations
- **RewardCondition/RewardHistory**: Gamification system for adherence motivation

### Key Features
- **Multi-user Groups**: Users can be medication takers or family guardians
- **Flexible Scheduling**: Customizable reminder intervals and family notification delays
- **LINE Integration**: Authentication and notifications through LINE Messaging API
- **Background Processing**: Sidekiq-scheduler runs every 30 minutes for notifications
- **Invitation System**: Secure token-based URLs with expiration and usage limits

### Notification System
- **Medication Reminders**: Sent to medication takers at scheduled times
- **Family Notifications**: Sent to guardians when medication not taken by family notification delay time
- **Completion Notifications**: Sent to guardians when medication is taken
- **Reward Notifications**: Sent when reward conditions are met
- **Retry Logic**: Configurable reminder counts and intervals

### Database Schema Notes
- Users are linked to medication groups through `medication_group_users` with role specification
- Medication schedules contain timing, reminder settings, and family notification delays
- Daily medication management tracks completion status and reminder counts
- Invitation system uses token-based authentication with max uses and expiration
- Reward system supports weekly and consecutive day achievement conditions

### Recent Development Context
Current development branch (`devlop_01`) includes recent work on:
- Medication group invitation system with secure token-based URLs
- LINE notification infrastructure and job processing
- Stimulus controllers for invitation generation and modal handling
- Database migrations for invitation tracking

## Development Notes

- **Time Zone**: Configured for Asia/Tokyo
- **Localization**: Primary language is Japanese with rails-i18n
- **Active Job**: Uses Sidekiq queue adapter
- **Database**: PostgreSQL with foreign key constraints
- **Asset Pipeline**: Uses jsbundling-rails with esbuild for JavaScript
- **CSS**: Tailwind CSS with live reloading
- **Testing**: Rails built-in testing with Capybara for system tests

## Code Conventions

- Follow Rails Omakase configuration with RuboCop
- Use Hotwire patterns for JavaScript interactions
- Maintain Japanese language support throughout the application
- Follow existing patterns for Stimulus controllers and Turbo frames
- Use enum_help for Japanese enum translations