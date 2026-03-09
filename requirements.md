# JobTrackr — Requirements & Project Plan

## Project Overview

**Name:** JobTrackr
**Description:** A full stack web application to manage job applications through a visual pipeline, with status tracking, contact management, reminders, and analytics.

**Tech Stack:**
- Backend: Spring Boot 3.x, Java 21, Spring Security (JWT), Spring Data JPA, Spring Mail, Spring Batch, Spring Cache
- Database: MySQL 8 + Flyway (migrations)
- Frontend: React + TypeScript + Tailwind CSS
- Build: Maven
- Deployment: Docker + Docker Compose

---

## Core Features

### 1. Authentication & Authorization
- Register/login with JWT-based auth
- Password reset via email (Spring Mail + Gmail SMTP)
- Spring Security with role-based access (USER, ADMIN)

### 2. Application Pipeline (Kanban Board)
- Drag-and-drop columns: `Saved → Applied → Phone Screen → Technical Screen → Technical Interview → Behavioral Interview → On-site → Final Round → Offer → Rejected → Withdrawn`
- Each card shows: company, role, salary range, date applied
- Color-coded priority labels

### 3. Application Detail View
- Company info (name, website, location, industry)
- Job description notes and requirements checklist
- Salary range (min/max/currency)
- Application source (LinkedIn, Indeed, referral, etc.)
- Status history log (who changed what, when)

### 4. Contacts & Networking
- Link contacts (recruiters, hiring managers) to applications
- Store name, email, phone, LinkedIn URL
- Notes per contact

### 5. Follow-up Reminders
- Set reminders per application (e.g., "Follow up in 3 days")
- Spring `@Scheduled` jobs to send email reminders daily
- In-app notification bell

### 6. Documents
- Upload resume/cover letter per application (store in filesystem or S3)
- Track which version of resume was sent

### 7. Dashboard & Analytics
- Total applications by status (pie chart)
- Applications over time (line chart)
- Response rate, interview conversion rate
- Average time per stage

### 8. Export
- Export all applications to CSV
- PDF report generation (iText or JasperReports)

---

## Technical Architecture

```
┌──────────────────────────────────────────────────┐
│                   Frontend                        │
│         React + TypeScript + Tailwind CSS         │
│      React Query · React DnD · Recharts           │
└────────────────────┬─────────────────────────────┘
                     │ REST API (JSON)
┌────────────────────▼─────────────────────────────┐
│               Spring Boot 3.x                     │
│                                                   │
│  Controllers → Services → Repositories            │
│  Spring Security (JWT)                            │
│  Spring Mail · Spring Batch · Spring Cache        │
│  MapStruct (DTO mapping)                          │
│  Flyway (DB migrations)                           │
└────────────────────┬─────────────────────────────┘
                     │ JPA / Hibernate
┌────────────────────▼─────────────────────────────┐
│                  MySQL 8                          │
└──────────────────────────────────────────────────┘
```

---

## Database Schema

```sql
users
  id, email, password_hash, name, created_at

applications
  id, user_id, company_name, role_title, job_url
  status ENUM(SAVED, APPLIED, PHONE_SCREEN, TECHNICAL_SCREEN, TECHNICAL_INTERVIEW,
             BEHAVIORAL_INTERVIEW, ON_SITE, FINAL_ROUND, OFFER, REJECTED, WITHDRAWN)
  priority, salary_min, salary_max, currency
  source, notes, applied_at, created_at, updated_at

status_history
  id, application_id, old_status, new_status
  changed_at, changed_by_user_id

contacts
  id, application_id, name, email, phone
  linkedin_url, role, notes

reminders
  id, application_id, remind_at, message
  is_sent, created_at

documents
  id, application_id, file_name, file_path
  doc_type (RESUME | COVER_LETTER), uploaded_at
```

---

## REST API Design

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/register` | Register user |
| POST | `/api/auth/login` | Login, returns JWT |
| GET | `/api/applications` | List all (paginated, filtered) |
| POST | `/api/applications` | Create application |
| GET | `/api/applications/{id}` | Get detail |
| PATCH | `/api/applications/{id}/status` | Update status |
| GET | `/api/applications/{id}/timeline` | Status history |
| POST | `/api/applications/{id}/contacts` | Add contact |
| POST | `/api/applications/{id}/reminders` | Set reminder |
| POST | `/api/applications/{id}/documents` | Upload file |
| GET | `/api/dashboard/stats` | Analytics data |
| GET | `/api/export/csv` | Download CSV |

---

## Project Structure

```
jobtrackr/
├── src/main/java/com/jobtrackr/
│   ├── config/          # Security, CORS, Mail config
│   ├── controller/      # REST controllers
│   ├── service/         # Business logic
│   ├── repository/      # JPA repositories
│   ├── entity/          # JPA entities
│   ├── dto/             # Request/Response DTOs
│   ├── mapper/          # MapStruct mappers
│   ├── scheduler/       # @Scheduled reminder jobs
│   └── exception/       # Global exception handling
├── src/main/resources/
│   ├── db/migration/    # Flyway SQL scripts
│   └── application.yml
└── frontend/            # React app (or separate repo)
```

---

## Development Phases

| Phase | Tasks | Outcome |
|---|---|---|
| **1 — Setup** | Spring Boot init, MySQL config, Flyway, JWT auth | Working login/register |
| **2 — Core CRUD** | Applications API, status pipeline, status history | Full kanban data layer |
| **3 — Contacts & Reminders** | Contacts API, scheduler, Spring Mail | Email reminders working |
| **4 — Files & Export** | File upload, CSV export, PDF report | Document management |
| **5 — Frontend** | React UI, Kanban board, dashboard charts | Full UI complete |
| **6 — Polish** | Docker Compose, tests, CI/CD, README | Production-ready |

---

## Testing Strategy

- **Unit tests:** JUnit 5 + Mockito for services
- **Integration tests:** `@SpringBootTest` + Testcontainers (MySQL)
- **API tests:** MockMvc for controller layer
- Target: **>70% code coverage**

---

## Task List

### MVP — v1.0 (Core Usable App)

**Goal:** A working app where a user can register, log in, manage job applications, and view basic stats.

#### Backend
- [ ] Initialize Spring Boot project with Maven (`pom.xml` with all dependencies)
- [ ] Configure `application.yml` (datasource, JWT secret, mail, file upload)
- [ ] Set up Flyway and write V1 migration (users, applications tables)
- [ ] Implement `User` entity + `UserRepository`
- [ ] Implement JWT auth: `JwtUtil`, `JwtFilter`, `AuthController` (register/login)
- [ ] Configure Spring Security (filter chain, BCrypt password encoder)
- [ ] Implement `Application` entity + `ApplicationRepository`
- [ ] Implement `ApplicationService` (CRUD + status update)
- [ ] Implement `ApplicationController` (GET list, GET detail, POST, PATCH status, DELETE)
- [ ] Add global exception handler (`@RestControllerAdvice`)
- [ ] Add request validation (`@Valid`, `@NotBlank`, etc.)
- [ ] Write Flyway V2 migration (status_history table)
- [ ] Implement status history logging on every status change
- [ ] Implement `DashboardController` (count by status, total applications)
- [ ] Write unit tests for `ApplicationService` (JUnit 5 + Mockito)
- [ ] Write integration tests for auth and application endpoints (MockMvc + Testcontainers)

#### Frontend
- [ ] Initialize React + TypeScript project (Vite + Tailwind CSS)
- [ ] Set up React Router (routes: login, register, dashboard, applications, detail)
- [ ] Set up Axios instance with JWT interceptor
- [ ] Build Login and Register pages
- [ ] Build Applications list page (table view with status badges)
- [ ] Build Add/Edit Application form (modal or page)
- [ ] Build Application detail page (read-only view)
- [ ] Build basic Dashboard page (counts per status as cards)
- [ ] Handle auth state (store JWT in localStorage, redirect on 401)

#### DevOps
- [ ] Write `Dockerfile` for Spring Boot API
- [ ] Write `Dockerfile` for React frontend (Nginx)
- [ ] Write `docker-compose.yml` (api + ui + mysql)
- [ ] Test full stack runs locally with Docker Compose

---

### v1.1 — Contacts & Reminders

**Goal:** Add relationship management and follow-up automation.

#### Backend
- [ ] Flyway migration: contacts + reminders tables
- [ ] Implement `Contact` entity, repository, service, controller
- [ ] Implement `Reminder` entity, repository, service, controller
- [ ] Configure Spring Mail (Gmail SMTP)
- [ ] Implement `ReminderScheduler` (`@Scheduled` daily job to send due reminders)
- [ ] Write tests for reminder scheduling logic

#### Frontend
- [ ] Contacts section on Application detail page (list, add, edit, delete)
- [ ] Reminders section on Application detail page (set date, message)
- [ ] In-app notification bell showing pending reminders

---

### v1.2 — Documents & Export

**Goal:** File management and data portability.

#### Backend
- [ ] Flyway migration: documents table
- [ ] Implement file upload endpoint (multipart, store locally or S3)
- [ ] Implement `DocumentController` (upload, list, download, delete)
- [ ] Implement CSV export endpoint (all applications for logged-in user)
- [ ] Implement PDF report generation (iText or JasperReports)

#### Frontend
- [ ] Documents section on Application detail page (upload, list, download)
- [ ] Export buttons on Applications list page (CSV + PDF)

---

### v2.0 — Enhanced UX & Analytics

**Goal:** Production-quality experience with rich UI and insights.

#### Backend
- [ ] Advanced filtering and search API (by status, company, date range, source)
- [ ] Pagination metadata in all list responses
- [ ] Analytics endpoint (applications over time, response rate, avg days per stage)
- [ ] Spring Cache on dashboard/analytics endpoints

#### Frontend
- [ ] Kanban board view (drag-and-drop with React DnD or dnd-kit)
- [ ] Timeline/history tab on Application detail page
- [ ] Analytics dashboard (Recharts: line chart, pie chart, conversion funnel)
- [ ] Advanced filter bar (status, date range, source, priority)
- [ ] Dark mode toggle

#### DevOps & Quality
- [ ] GitHub Actions CI pipeline (build + test on every PR)
- [ ] Achieve >70% test coverage
- [ ] Add Swagger/OpenAPI docs (`springdoc-openapi`)
- [ ] Deploy to cloud (Railway / Render / DigitalOcean)
- [ ] Write full `README.md` (setup, API docs, screenshots)

---

## Deployment

```yaml
# docker-compose.yml covers:
- jobtrackr-api    (Spring Boot JAR)
- jobtrackr-ui     (Nginx serving React build)
- mysql            (MySQL 8)
```

**Deploy options:** Railway, Render, AWS EC2, or DigitalOcean
