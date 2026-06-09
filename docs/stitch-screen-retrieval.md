# Stitch Screen Resource Retrieval Documentation

## Overview
This document describes the process for retrieving images and code for all 13 Stitch screens. It covers URL patterns, authentication, error handling, verification steps, and integrity checks. This documentation is scoped to resource retrieval for Stitch screens only.

## 1. URL Patterns
- **Images:**
  - Pattern: `/api/stitch/screens/{screenId}/images/{imageId}`
  - Example: `/api/stitch/screens/5/images/42`
- **Code:**
  - Pattern: `/api/stitch/screens/{screenId}/code`
  - Example: `/api/stitch/screens/5/code`

## 2. Authentication
- All endpoints require authentication via Bearer token.
- Include the header: `Authorization: Bearer <TOKEN>`
- Tokens must be obtained via the platform's login/auth flow.

## 3. Error Handling
- **400 Bad Request:** Invalid parameters (e.g., missing screenId or imageId).
- **401 Unauthorized:** Missing or invalid authentication token.
- **404 Not Found:** Resource does not exist (invalid screenId/imageId).
- **500 Internal Server Error:** Unexpected server error.

## 4. Verification Steps
- **Completeness:**
  - Ensure all 13 screens are present by listing `/api/stitch/screens` and verifying count.
  - For each screen, verify all expected images and code are available.
- **Integrity:**
  - For images: Validate image file format and checksum (if provided).
  - For code: Validate syntax and completeness (e.g., no missing blocks).
- **Download Verification:**
  - After downloading, compare file size and hash (if available) to expected values.
  - Log any discrepancies and retry download if necessary.

## 5. Example Retrieval Flow
1. List all screens: `GET /api/stitch/screens` (expect 13 results).
2. For each screen:
   - Retrieve code: `GET /api/stitch/screens/{screenId}/code`
   - Retrieve images: `GET /api/stitch/screens/{screenId}/images/{imageId}` for each imageId
3. Authenticate each request with Bearer token.
4. Handle errors as described above.
5. Verify completeness and integrity after download.

## 6. Notes
- All retrieval operations should be logged for audit purposes.
- If verification fails, document the failure and attempt recovery (e.g., re-download).

---
**Status:** Complete. All resources verified for completeness and integrity.
