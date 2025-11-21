# SmartMarketplace API

AI-driven marketplace API integrating OpenAI agents for intelligent moderation, task automation, adaptive support, secure JWT authentication, Stripe-powered payments, Dockerized infrastructure, and a robust PostgreSQL backend designed for scalable, high-performance operations.

This project is a **capstone-style project** designed to demonstrate comprehensive API development skills, leveraging best-in-class technologies and market practices. It integrates multiple external APIs, including **OpenAI**, **Cloudinary**, and **Stripe**, and uses **JWT authentication** with the Devise gem to securely manage users.

---

## Project Overview

SmartMarketplace API is a backend platform for an AI-powered marketplace. It provides:

- Intelligent moderation of reviews, products, and images using AI agents.
- Automated task handling through background jobs.
- Secure user authentication and authorization using JWT and Devise.
- Payment processing integrated with Stripe.
- Image management integrated with Cloudinary.
- Scalable architecture using Docker and PostgreSQL.

The system is designed to maintain high data integrity, support rapid growth, and reduce administrative overhead through AI-driven automation. This project showcases advanced API design, external API integrations, and adherence to best development practices.

---

## Features

- **AI Moderation**: Automatic review and product moderation to flag fraudulent, offensive, or inappropriate content.
- **Background Jobs**: Efficient asynchronous processing of deliveries, review moderation, and photo verification.
- **Stripe Integration**: Secure payment processing for orders.
- **Cloudinary Integration**: Handles product image uploads and validations.
- **JWT Authentication**: Robust and secure user authentication via Devise.
- **Dockerized Infrastructure**: Easy deployment and consistent development environment.
- **PostgreSQL Backend**: Reliable and scalable database storage for all marketplace data.

---

## Business Rules & Agents

The platform relies on specialized services and background jobs, known as **agents**, to enforce business rules:

### Jobs

- [ ] **CompanyAgentJob**
  - Moderates company reviews, assigns risk scores, flags issues, and optionally creates admin alerts.

- [ ] **CreateDeliveryJob**
  - Handles creation and processing of deliveries for orders, ensuring correct delivery data and notifications.

- [ ] **PhotoAgentJob**
  - Moderates uploaded product images for inappropriate content or mismatches with descriptions.

### Services

- [ ] **ProductAgentService**
  - Evaluates product data for consistency, accuracy, and potential issues.

- [ ] **ReviewAgentService**
  - Evaluates user reviews, determines approval, risk scores, and categorizes reviews (spam, scam, offensive, etc.).

---

## Getting Started

## Environment Variables

Look at .env.example file


