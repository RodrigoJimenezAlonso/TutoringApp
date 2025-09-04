# TutorFinder App

Full-stack mobile platform connecting students with tutors — developed as my **Final Year Project at the University of Birmingham**.

## Table of Contents
- [Overview](#overview)
- [Technologies](#technologies)
- [Features](#features)
- [Project Structure](#project-structure)
- [Setup](#setup)
- [Environment Variables](#environment-variables)
- [Run the Database (Docker)](#run-the-database-docker)
- [Testing & Results](#testing--results)
- [Future Work](#future-work)
- [License](#license)

## Overview
TutorFinder simplifies how students connect with tutors specialized in specific subjects and concepts. It offers:
- AI-powered recommendations *(planned)*
- Real-time messaging
- Booking system with calendar integration
- Video calls (Agora SDK)
- Secure authentication & data storage

Built to make tutoring more **personalized, accessible, and efficient**.

## Technologies
- **Frontend:** Flutter (Dart)  
- **Backend & DB:** MariaDB (SQL), Docker  
- **Security:** Bcrypt, Flutter Secure Storage  
- **Integrations:** Agora (video), Stripe *(disabled for academic reasons)*  
- **Tools:** Android Studio, MySQL Workbench, GitHub  

## Features
- Registration & authentication (students / tutors)  
- Tutor search with filters (subject, availability, etc.)  
- Booking with interactive calendar  
- Real-time chat (WhatsApp-style)  
- Video calls (Agora SDK)  
- Profiles & settings (including dark mode)  
- Stripe payments *(proof of concept)*  

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
