# 🩸 HemoConnect — Next-Gen Blood Logistics & Clinical Coordination Platform

[![Java](https://img.shields.io/badge/Java-21-orange.svg?logo=openjdk)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg?logo=springboot)](https://spring.io/projects/spring-boot)
[![Security](https://img.shields.io/badge/Security-OWASP%20Hardened-blue.svg?logo=dependabot)](https://owasp.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Build-In%20Active%20Development-amber.svg)]()

> **HemoConnect** is a healthcare coordination and blood logistics platform designed to eliminate life-threatening delays in finding compatible blood donors and emergency blood units.
>
> Built with **Java 21** and **Spring Boot 3.2.0**, HemoConnect provides a robust backend domain architecture, an intelligent **ABO/Rh immunohematology matching engine**, proximity-based blood bank stock escalation, defensive input sanitization, and resilient clinical services.

---

## 📑 Table of Contents
- [Project Overview](#-project-overview)
- [Current Features & Implementation](#-current-features--implementation)
  - [1. Clinical Domain Modeling](#1-clinical-domain-modeling)
  - [2. Smart ABO/Rh Compatibility Engine](#2-smart-aborh-compatibility-engine)
  - [3. Defensive Input Sanitization (OWASP XSS Defense)](#3-defensive-input-sanitization-owasp-xss-defense)
  - [4. Clinical Services Layer](#4-clinical-services-layer)
  - [5. Centralized Exception Handling & Data Validation](#5-centralized-exception-handling--data-validation)
- [Project Directory Structure](#-project-directory-structure)
- [Technical Architecture](#-technical-architecture)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Configuration](#configuration)
  - [Building the Project](#building-the-project)
- [License](#-license)

---

## 🩸 Project Overview

In clinical emergencies, discovering compatible blood units and verified volunteer donors is often delayed by fragmented hospital registries and manual verification. 

**HemoConnect** addresses this problem by centralizing donor and request management, enforcing strict medical compatibility protocols, and offering intelligent stock-first discovery with automated emergency escalation.

This repository currently contains the **core domain models, clinical business logic services, immunohematology matching algorithms, and defensive exception handling framework**.

---

## 🌟 Current Features & Implementation

The codebase pushed to date comprises the following foundational components:

### 1. Clinical Domain Modeling (`com.hemoconnect.model`)
* **`Donor`**: Represents voluntary blood donors with demographic tracking (name, city, district, contact), biological and clinical health metrics (age, weight, hemoglobin, pulse, blood pressure), and real-time donation eligibility status.
* **`BloodRequest`**: Models patient blood requirements with triage urgency classifications (`ROUTINE`, `URGENT`, `CRITICAL`), required blood group, units requested, target hospital/clinic, and fulfillment states (`PENDING`, `MATCHED`, `FULFILLED`).
* **`BloodBank`**: Represents regional blood banks and hospitals with localized geographic details (`city`, `subLocation`, coordinates) and real-time blood stock counts categorized by blood group (`Map<String, Integer> bloodInventory`).
* **`Hospital`**: Healthcare institution profile supporting clinical verification status and access credentials.
* **`Notification`**: In-app emergency broadcast messages and donor match notifications.
* **`Admin`**: Administrative user entity supporting system management roles.

### 2. Smart ABO/Rh Compatibility Engine (`com.hemoconnect.service.SmartMatchingEngine`)
* **Medical Transfusion Rules**:
  * **Universal Donor ($O^-$)**: Can donate red blood cells to all 8 blood groups.
  * **Universal Recipient ($AB^+$)**: Can receive red blood cells from any blood group.
  * **Strict Rh Factor Enforcement**: Rh-negative recipients strictly receive Rh-negative blood to prevent fatal hemolytic transfusion reactions.
  * **Clinical Eligibility Checks**: Validates that prospective donors are currently marked available and meet mandatory biological donation recovery periods.
* **Proximity & Compatibility Scoring (`findBestMatches`)**:
  * Matches compatible donors within the recipient's city.
  * Dynamically computes composite match scores (combining compatibility rating + distance proximity) to prioritize the most suitable donors.
* **Stock-First Proximity Escalation (`searchProximityStockFirst`)**:
  * Searches existing blood bank and hospital inventory in the local municipality/sub-location first.
  * Automatically flags `escalated = true` when total blood bank stock falls below the requested units, triggering immediate volunteer donor discovery and alert routing.

### 3. Defensive Input Sanitization (OWASP XSS Defense) (`com.hemoconnect.util.InputSanitizer`)
* Prevents Cross-Site Scripting (XSS) and script injection attacks on user-submitted data.
* Uses **Jsoup** with `Safelist.none()` to strip all HTML tags, script tags, and malicious payloads before data enters the persistence layer.

### 4. Clinical Services Layer (`com.hemoconnect.service`)
* **`DonorService`**:
  * Manages voluntary donor registration and profile lifecycle.
  * Enforces clinical age constraints (donors must be between 18 and 65 years old).
* **`BloodRequestService`**:
  * Ingests emergency and standard blood requests, setting initial `PENDING` states.
  * Triggers proximity stock searches and donor matching via `SmartMatchingEngine`.
  * Executes automated emergency dispatch broadcasts for `URGENT` and `CRITICAL` requests.
* **`NotificationService`**:
  * Logs and persists in-app alerts and donor match notifications.
  * Dispatches simulated email alerts to matched donors during high-priority emergency events.

### 5. Centralized Exception Handling & Data Validation (`com.hemoconnect.exception.GlobalExceptionHandler`)
* **`@RestControllerAdvice` Centralization**: Intercepts application exceptions and formats standardized JSON error responses.
* **JSR-380 Validation Handling**: Formats bean validation errors (`MethodArgumentNotValidException`) into user-friendly field-level error messages.
* **Strict JSON Schema Parsing**: Intercepts `HttpMessageNotReadableException` and catches unrecognized fields (`UnrecognizedPropertyException`) to prevent mass assignment vulnerabilities.
* **Business Rule Violations**: Returns clear HTTP 400 Bad Request responses for `IllegalArgumentException`.
* **Defensive Internal Error Shielding**: Catches general exceptions, logs server-side stack traces securely, and shields internal implementation details from end users.

---

## 📂 Project Directory Structure

```
HemoConnect/
├── .env.example                                      # Environment variable template
├── .gitignore                                        # Git ignore rules
├── pom.xml                                           # Maven dependencies (Spring Boot 3, Jsoup, Jackson)
├── README.md                                         # Project documentation
└── src/
    └── main/
        ├── java/com/hemoconnect/
        │   ├── HemoConnectApplication.java           # Spring Boot bootstrap application entrypoint
        │   ├── exception/
        │   │   └── GlobalExceptionHandler.java       # Centralized REST exception handler
        │   ├── model/                                # Core clinical domain entities
        │   │   ├── Admin.java                        # Administrator entity
        │   │   ├── BloodBank.java                    # Blood bank facility & inventory model
        │   │   ├── BloodRequest.java                 # Emergency blood request entity
        │   │   ├── Donor.java                        # Voluntary donor clinical profile
        │   │   ├── Hospital.java                     # Healthcare facility entity
        │   │   └── Notification.java                 # Emergency broadcast alert model
        │   ├── service/                              # Core clinical business logic
        │   │   ├── BloodRequestService.java          # Request lifecycle & emergency dispatch
        │   │   ├── DonorService.java                 # Donor registration & age validation
        │   │   ├── NotificationService.java          # Notification & alert dispatch service
        │   │   └── SmartMatchingEngine.java          # Immunohematology ABO/Rh rules & proximity ranking
        │   └── util/
        │       └── InputSanitizer.java               # Jsoup-based XSS sanitization utility
        └── resources/
            └── application.properties                # Spring Boot configuration
```

---

## 🏛️ Technical Architecture

```
+---------------------------------------------------------------------------------+
|                                 Clinical Layer                                  |
|         +----------------------+             +-----------------------+          |
|         |     DonorService     |             |  BloodRequestService  |          |
|         +----------+-----------+             +-----------+-----------+          |
+--------------------|-------------------------------------|----------------------+
                     |                                     |
                     v                                     v
+---------------------------------------------------------------------------------+
|                              Core Logic & Security                              |
|         +-------------------------------+   +-----------------------------+     |
|         |      SmartMatchingEngine      |   |        InputSanitizer       |     |
|         |  - ABO/Rh Compatibility Matrix|   |   - Jsoup XSS Stripping     |     |
|         |  - Proximity Stock-First Search|  +-----------------------------+     |
|         |  - Emergency Escalation Logic |   |    GlobalExceptionHandler   |     |
|         +-------------------------------+   |   - Schema & Fault Shielding|     |
+---------------------------------------------------------------------------------+
```

---

## ⚡ Getting Started

### Prerequisites
* **Java Development Kit (JDK) 21** or higher
* **Apache Maven 3.9+** (or IDE-bundled Maven)

### Configuration
Review `src/main/resources/application.properties` for default Spring Boot configurations:
```properties
spring.application.name=hemoconnect
server.port=8080
spring.jackson.deserialization.fail-on-unknown-properties=true
```

### Building the Project
Clone the repository and compile the core components:
```bash
git clone <repository-url>
cd HEMOCONNECT
mvn clean compile
```

---

## 📄 License

Distributed under the **MIT License**.
