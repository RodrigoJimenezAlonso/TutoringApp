# TutorFinder App

Full-stack mobile platform connecting students with tutors — developed as my **Final Year Project at the University of Birmingham**.

## Table of Contents

* [Overview](#overview)
* [Technologies](#technologies)
* [Features](#features)
* [Project Structure](#project-structure)
* [Setup](#setup)
* [Environment Variables](#environment-variables)
* [Run the Database (Docker)](#run-the-database-docker)
* [Testing & Results](#testing--results)
* [Future Work](#future-work)
* [License](#license)

## Overview

TutorFinder simplifies how students connect with tutors specialized in specific subjects and concepts. It offers:

* AI-powered recommendations *(planned)*
* Real-time messaging
* Booking system with calendar integration
* Video calls (Agora SDK)
* Secure authentication & data storage

Built to make tutoring more **personalized, accessible, and efficient**.

## Technologies

* **Frontend:** Flutter (Dart)
* **Backend & DB:** MariaDB (SQL), Docker
* **Security:** Bcrypt, Flutter Secure Storage
* **Integrations:** Agora (video), Stripe *(disabled for academic reasons)*
* **Tools:** Android Studio, MySQL Workbench, GitHub

## Features

* Registration & authentication (students / tutors)
* Tutor search with filters (subject, availability, etc.)
* Booking with interactive calendar
* Real-time chat (WhatsApp-style)
* Video calls (Agora SDK)
* Profiles & settings (including dark mode)
* Stripe payments *(proof of concept)*

## Screenshots

### Login
<img width="400" alt="Login Screen" src="https://github.com/user-attachments/assets/1af538f7-2bc7-45bb-843a-6a422bfe110d" />

### Profile
<img width="250" alt="Chat Screen" src="https://github.com/user-attachments/assets/0e2902ad-b516-4b05-9262-7e58c4ac642d" />

### Booking
<img width="250" alt="Booking Screen" src="https://github.com/user-attachments/assets/f069a96e-bba1-441a-8068-5c6a618514a1" />





## Project Structure

```text
lib/
  auth/           -> login & signup
  components/     -> reusable widgets (chat input, etc.)
  cryptography/   -> encryption & security
  models/         -> data structures
  providers/      -> state management
  screens/        -> UI screens
  services/       -> DB & API connections
  widgets/        -> shared UI elements
backend/          -> MariaDB + Docker setup
docs/             -> additional documentation
```
<img width="3840" height="2184" alt="Editor _ Mermaid Chart-2025-03-29-141743" src="https://github.com/user-attachments/assets/5f5c5858-827b-43e7-aaff-b86394574f43" />


## Setup

**Prerequisites**

* Flutter SDK
* Docker
* MariaDB/MySQL Workbench (optional if not using Docker)

**Running the app**

```bash
git clone https://github.com/RodrigoJimenezAlonso/TutoringApp.git
cd TutoringApp
flutter pub get
flutter run
```

## Environment Variables

Create a `.env` file (do not commit) based on `.env.example`:

```env
AGORA_APP_ID=your_agora_id
STRIPE_SECRET_KEY=your_stripe_key
DB_PASSWORD=your_password
```

## Run the Database (Docker)

```bash
cd backend
docker-compose up --build
```

## Testing & Results

* Average login response: < 2s
* Real-time chat updates: < 1s
* Booking confirmation: < 1s
* Video call connection: \~ 2.2s
* **UX feedback:** 100% positive during testing

## Future Work

* Replace polling with WebSockets or Firebase for real-time messaging
* Enable secure payment processing with Stripe
* Add ML for personalized tutor recommendations
* Deploy to cloud (AWS/GCP) for scalability

## License

MIT
