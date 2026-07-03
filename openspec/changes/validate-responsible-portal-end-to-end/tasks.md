# Tasks: Validate Responsible Portal End-to-End

## Task List

### 1. Cookie Consent Flow Validation

- [x] 1.1 Design and implement a cookie consent banner in the UI. (`cookie-consent-banner.component.ts`)
- [x] 1.2 Integrate the banner with backend APIs to store user consent. (`cookie-consent.service.ts`)
- [x] 1.3 Ensure cookies are only activated after user consent.
- [x] 1.4 Verify analytics events blocked when consent = unset

### 2. Portal Analytics Integration

- [x] 2.1 Fix TypeScript imports in portal-analytics.service.ts
- [x] 2.2 Verify `PortalAnalyticsService.emit()` integrates with gtag/posthog
- [x] 2.3 Verify `first_relevant_action` event fires on `/portal/dashboard`
- [x] 2.4 Verify `onboarding_start` / `onboarding_complete` events fire in registration flow

### 3. API Integration

- [x] 3.1 Cookie consent endpoints exist (`/api/privacy/cookie-consent/*`)
- [x] 3.2 LGPD data endpoints exist (`/api/privacy/data-subject/*`)
- [x] 3.3 Verify backend cookie consent endpoints respond correctly

### 4. Smoke Test

- [x] 4.1 TypeScript compile passes for portal analytics files
- [x] 4.2 Frontend build: `cd school-management-ui && npm run build`
- [x] 4.3 Backend build: `cd school-management-api && dotnet build`