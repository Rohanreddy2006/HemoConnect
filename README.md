# 🩸 HemoConnect — Next-Gen Blood Logistics & Clinical Coordination Platform

[![Java](https://img.shields.io/badge/Java-21-orange.svg?logo=openjdk)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.0-brightgreen.svg?logo=springboot)](https://spring.io/projects/spring-boot)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%26%20Hosting-amber.svg?logo=firebase)](https://firebase.google.com/)
[![Security](https://img.shields.io/badge/Security-OWASP%20Hardened-blue.svg?logo=dependabot)](https://owasp.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Build-In%20Active%20Development-success.svg)]()

> **HemoConnect** is a healthcare coordination and emergency blood logistics platform designed to eliminate life-threatening delays in finding compatible blood donors and critical blood units.
>
> Built with **Java 21** and **Spring Boot 3.3.0**, HemoConnect provides a robust backend domain architecture, an intelligent **ABO/Rh immunohematology matching engine**, proximity-based blood bank stock escalation, national voluntary registry scraping, predictive clinical analytics, and dual-mode Cloud Firestore persistence.

---

## 📑 Table of Contents
- [Project Overview](#-project-overview)
- [Implementation Milestones (Parts 1–6)](#-implementation-milestones-parts-16)
  - [1. Clinical Domain Modeling (Part 2)](#1-clinical-domain-modeling-part-2)
  - [2. Smart ABO/Rh Compatibility Engine (Part 3)](#2-smart-aborh-compatibility-engine-part-3)
  - [3. Defensive Input Sanitization (Part 3)](#3-defensive-input-sanitization-part-3)
  - [4. Clinical Services Layer (Part 4)](#4-clinical-services-layer-part-4)
  - [5. Centralized Exception Handling & Data Validation (Part 4)](#5-centralized-exception-handling--data-validation-part-4)
  - [6. Cloud Firestore Persistence & Regional Clinic Datasets (Part 5)](#6-cloud-firestore-persistence--regional-clinic-datasets-part-5)
  - [7. National Donor Registry Web Scraper & Analytics Engine (Part 6)](#7-national-donor-registry-web-scraper--analytics-engine-part-6)
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

**HemoConnect** addresses this challenge by centralizing donor and request management, enforcing strict medical compatibility protocols, offering intelligent stock-first discovery with automated emergency escalation, and integrating real-time regional blood bank telemetry.

This repository tracks progressive development across organized architectural milestones.

---

## 🌟 Implementation Milestones (Parts 1–6)

### 1. Clinical Domain Modeling (Part 2) (`com.hemoconnect.model`)
* **`Donor`**: Represents voluntary blood donors with demographic tracking (name, city, district, contact), biological metrics (age, weight, hemoglobin, pulse, blood pressure), and real-time donation eligibility status.
* **`BloodRequest`**: Models patient blood requirements with triage urgency classifications (`ROUTINE`, `URGENT`, `CRITICAL`), required blood group, units requested, target hospital/clinic, and fulfillment states (`PENDING`, `MATCHED`, `FULFILLED`).
* **`BloodBank`**: Represents regional blood banks and hospitals with localized geographic details (`city`, `subLocation`, coordinates) and real-time blood stock counts categorized by blood group (`Map<String, Integer> bloodInventory`).
* **`Hospital`**: Healthcare institution profile supporting clinical verification status and access credentials.
* **`Notification`**: In-app emergency broadcast messages and donor match notifications.
* **`Admin`**: Administrative user entity supporting system management roles.

---

### 2. Smart ABO/Rh Compatibility Engine (Part 3) (`com.hemoconnect.service.SmartMatchingEngine`)
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

---

### 3. Defensive Input Sanitization (Part 3) (`com.hemoconnect.util.InputSanitizer`)
* Prevents Cross-Site Scripting (XSS) and script injection attacks on user-submitted data.
* Uses **Jsoup** with `Safelist.none()` to strip all HTML tags, script tags, and malicious payloads before data enters the persistence layer.

---

### 4. Clinical Services Layer (Part 4) (`com.hemoconnect.service`)
* **`DonorService`**: Manages voluntary donor registration and profile lifecycle, enforcing clinical age constraints (between 18 and 65 years old).
* **`BloodRequestService`**: Ingests emergency and standard blood requests, setting initial `PENDING` states, triggering proximity stock searches, and executing automated emergency dispatch broadcasts for `URGENT` and `CRITICAL` requests.
* **`NotificationService`**: Logs and persists in-app alerts and donor match notifications, dispatching simulated alerts during high-priority emergency events.

---

### 5. Centralized Exception Handling & Data Validation (Part 4) (`com.hemoconnect.exception.GlobalExceptionHandler`)
* **`@RestControllerAdvice` Centralization**: Intercepts application exceptions and formats standardized JSON error responses.
* **JSR-380 Validation Handling**: Formats bean validation errors (`MethodArgumentNotValidException`) into user-friendly field-level error messages.
* **Strict JSON Schema Parsing**: Intercepts `HttpMessageNotReadableException` and catches unrecognized fields (`UnrecognizedPropertyException`) to prevent mass assignment vulnerabilities.
* **Business Rule Violations**: Returns clear HTTP 400 Bad Request responses for `IllegalArgumentException`.
* **Defensive Error Shielding**: Catches general exceptions, logs server-side stack traces securely, and shields internal implementation details from end users.

---

### 6. Cloud Firestore Persistence & Regional Clinic Datasets (Part 5)
* **`FirebaseConfig`**: Manages Google Firebase Admin SDK lifecycle, project credentials, and Firestore connection pooling.
* **`FirebaseService`**: Implements a resilient dual-mode architecture:
  * **Production Mode**: Full bidirectional synchronization with Google Cloud Firestore collections (`donors`, `requests`, `bloodbanks`, `hospitals`).
  * **Demo / Fallback Mode**: Thread-safe in-memory `ConcurrentHashMap` storage pre-seeded with clinical demo entities for reliable offline or sandbox operation.
* **Regional Clinic Dataset (`blood_banks_data.json`)**: Pre-populated clinical repository containing real-world hospital locations, contact phone lines, and regional blood bank coordinates across Greater Hyderabad sectors.
* **Firebase Infrastructure**: Configured `.firebaserc` and `firebase.json` for seamless static hosting and cloud database bindings.

---

### 7. National Donor Registry Web Scraper & Analytics Engine (Part 6)
* **`VoluntaryRegistryScraper`**:
  * Real-time web scraper leveraging **Jsoup** to ingest external voluntary donor records from public and national donor directories.
  * Employs timeout management, connection retries, and defensive parsing to ensure high availability during third-party service fluctuations.
  * Normalizes ingested donor names, contacts, and blood types into internal domain models.
* **`AnalyticsService`**:
  * **Demand & Shortage Metrics**: Analyzes real-time blood stock across all facilities to identify critical shortage blood groups (e.g., critical reserves $\le 5$ units).
  * **Hospital Activity Tracking**: Identifies high-demand municipal sectors and aggregates total available units across the regional grid.
  * **Fulfillment Velocity**: Computes request turnaround time and donor response metrics for operational reporting.

---

## 📂 Project Directory Structure

```
HemoConnect/
├── .env.example                                      # Environment variable template
├── .firebaserc                                       # Firebase project configuration
├── .gitignore                                        # Git ignore rules
├── firebase.json                                     # Firebase hosting configuration
├── pom.xml                                           # Maven dependencies (Spring Boot 3, Firebase, Jsoup, Jackson)
├── README.md                                         # Project documentation
└── src/
    └── main/
        ├── java/com/hemoconnect/
        │   ├── HemoConnectApplication.java           # Spring Boot bootstrap application entrypoint
        │   ├── config/
        │   │   └── FirebaseConfig.java               # Firebase Admin SDK & Firestore configuration
        │   ├── exception/
        │   │   └── GlobalExceptionHandler.java       # Centralized REST exception handler
        │   ├── model/                                # Core clinical domain entities
        │   │   ├── Admin.java                        # Administrator entity
        │   │   ├── BloodBank.java                    # Blood bank facility & inventory model
        │   │   ├── BloodRequest.java                 # Emergency blood request entity
        │   │   ├── Donor.java                        # Voluntary donor clinical profile
        │   │   ├── Hospital.java                     # Healthcare facility entity
        │   │   └── Notification.java                 # Emergency broadcast alert model
        │   ├── service/                              # Core clinical business logic & integrations
        │   │   ├── AnalyticsService.java             # Blood stock analytics & shortage forecasting
        │   │   ├── BloodRequestService.java          # Request lifecycle & emergency dispatch
        │   │   ├── DonorService.java                 # Donor registration & age validation
        │   │   ├── FirebaseService.java              # Cloud Firestore & in-memory persistence layer
        │   │   ├── NotificationService.java          # Notification & alert dispatch service
        │   │   ├── SmartMatchingEngine.java          # Immunohematology ABO/Rh rules & proximity ranking
        │   │   └── VoluntaryRegistryScraper.java     # Jsoup national donor registry scraper
        │   └── util/
        │       └── InputSanitizer.java               # Jsoup-based XSS sanitization utility
        └── resources/
            ├── application.properties                # Spring Boot & client configuration
            └── blood_banks_data.json                 # Comprehensive Hyderabad clinic dataset
```

---

## 🏛️ Technical Architecture

```
+---------------------------------------------------------------------------------------+
|                                    Clinical Layer                                     |
|         +----------------------+                   +-----------------------+          |
|         |     DonorService     |                   |  BloodRequestService  |          |
|         +----------+-----------+                   +-----------+-----------+          |
+--------------------|-------------------------------------------|----------------------+
                     |                                           |
                     v                                           v
+---------------------------------------------------------------------------------------+
|                               Core Intelligence & Security                            |
|         +-------------------------------+         +-----------------------------+     |
|         |      SmartMatchingEngine      |         |        InputSanitizer       |     |
|         |  - ABO/Rh Compatibility Matrix|         |   - Jsoup XSS Stripping     |     |
|         |  - Proximity Stock-First Search|        +-----------------------------+     |
|         |  - Emergency Escalation Logic |         |    GlobalExceptionHandler   |     |
|         +-------------------------------+         |   - Schema & Fault Shielding|     |
+---------------------------------------------------|-----------------------------------+
                     |                                           |
                     v                                           v
+---------------------------------------------------------------------------------------+
|                          Data Integrations & Cloud Persistence                        |
|   +----------------------------+  +-------------------------+  +------------------+   |
|   |  VoluntaryRegistryScraper  |  |     AnalyticsService    |  |  FirebaseService |   |
|   |  - Real-time Jsoup Scraper |  |  - Shortage Forecasting |  |  - Firestore Sync|   |
|   |  - National Registry Feed  |  |  - Consumption Velocity |  |  - Mock Fallback |   |
|   +----------------------------+  +-------------------------+  +------------------+   |
+---------------------------------------------------------------------------------------+
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
Clone the repository and compile the components:
```bash
git clone <repository-url>
cd HEMOCONNECT
mvn clean compile
```

---

## 📄 License

Distributed under the **MIT License**.
