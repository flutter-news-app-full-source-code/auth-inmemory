<div align="center">
  <img src="https://avatars.githubusercontent.com/u/202675624?s=400&u=dc72a2b53e8158956a3b672f8e52e39394b6b610&v=4" alt="Flutter News App Toolkit Logo" width="220">
  <h1>Auth In-Memory</h1>
  <p><strong>An in-memory implementation of the `AuthClient` interface for the Flutter News App Toolkit.</strong></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/coverage-13%25-red?style=for-the-badge" alt="coverage">
  <a href="https://flutter-news-app-full-source-code.github.io/docs/"><img src="https://img.shields.io/badge/LIVE_DOCS-VIEW-slategray?style=for-the-badge" alt="Live Docs: View"></a>
  <a href="https://github.com/flutter-news-app-full-source-code"><img src="https://img.shields.io/badge/MAIN_PROJECT-BROWSE-purple?style=for-the-badge" alt="Main Project: Browse"></a>
</p>

This `auth_inmemory` package provides an in-memory implementation of the `AuthClient` interface within the [**Flutter News App Full Source Code Toolkit**](https://github.com/flutter-news-app-full-source-code). It offers a mock authentication client that operates entirely on in-memory data, making it suitable for demonstration purposes, local development, and testing without requiring a live backend. This package simulates various authentication flows, ensuring consistent behavior and robust error handling based on the `auth_client` contract.

## ⭐ Feature Showcase: Simplified Authentication Testing & Development

This package offers a comprehensive set of features for managing authentication operations in a simulated environment.

<details>
<summary><strong>🧱 Core Functionality</strong></summary>

### 🚀 `AuthClient` Implementation
- **`AuthInmemory` Class:** A concrete in-memory implementation of the `AuthClient` interface, providing a standardized way to simulate authentication.
- **Simulated Authentication Flows:** Implements `requestSignInCode`, `verifySignInCode`, `signInAnonymously`, and `signOut` to simulate various authentication processes.
- **Reactive State Changes:** Provides `authStateChanges` (a stream that emits the current authenticated `User` or `null` on state changes) and `getCurrentUser` to retrieve the current user.

### 🌐 Debugging & Validation
- **Privileged Flow Simulation:** Supports an `isDashboardLogin` flag in `requestSignInCode` and `verifySignInCode` to simulate privileged flows, allowing testing of admin-specific authentication logic (e.g., only `admin@example.com` is allowed).
- **Token Retrieval:** Includes a `currentToken` getter to retrieve the simulated authentication token for inspection during development.

### 🛡️ Standardized Error Handling
- **`HttpException` Propagation:** Throws standard `HttpException` subtypes (e.g., `UnauthorizedException`, `NotFoundException`, `AuthenticationException`, `InvalidInputException`) from `core` on simulated failures, ensuring consistent error handling in a testing context.

> **💡 Your Advantage:** This package provides a reliable, in-memory authentication client that simplifies testing and development of authentication-related features. It eliminates the need for external backend dependencies during development, offering immediate feedback and consistent behavior for your authentication logic, especially for complex scenarios like privileged logins.

</details>

## 🔑 Licensing

This `auth_inmemory` package is an integral part of the [**Flutter News App Full Source Code Toolkit**](https://github.com/flutter-news-app-full-source-code). For comprehensive details regarding licensing, including trial and commercial options for the entire toolkit, please refer to the main toolkit organization page.
