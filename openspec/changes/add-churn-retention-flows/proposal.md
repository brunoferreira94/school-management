## Why

Implement churn-retention flows to reduce subscription cancellation through win-back offers and contextual guidance.

## What Changes

- Added PUT endpoints for account summary and subscription pause
- Added cancel-flow endpoint with reason persistence
- Added AccountSummaryDto with student/class/guardian counts
- Added PauseSubscriptionRequest and GetAccountSummaryQuery

## Impact

- Affected specs: self-service-portal, subscription-retention
- Affected code: SubscriptionsController, SubscriptionService, DTOs