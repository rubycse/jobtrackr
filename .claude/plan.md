# JobTrackr MVP Plan

## Scope

A working app where a user can register, log in, manage job applications, and view basic stats.

Post-MVP (v1.1+): contacts, reminders, file upload, CSV/PDF export, kanban UI, analytics.

---

## Phase 1 — Project Setup

| # | Task | Output |
|---|------|--------|
| 1 | Bootstrap Spring Boot project: `pom.xml`, `application.yml`, `JobTrackrApplication.java` | project scaffold |
| 2 | Write Flyway `V1__init.sql` — `users` and `applications` tables | `db/migration/V1__init.sql` |
| 3 | Write Flyway `V2__status_history.sql` — `status_history` table | `db/migration/V2__status_history.sql` |

## Phase 2 — Auth Layer

| # | Task | Output |
|---|------|--------|
| 4 | `User` entity + `UserRepository` | entity + JPA repo |
| 5 | `JwtUtil` (generate + validate tokens) | utility class |
| 6 | `JwtFilter` (OncePerRequestFilter) | security filter |
| 7 | `SecurityConfig` (filter chain, BCrypt bean, permit `/api/auth/**`) | Spring Security config |
| 8 | `AuthController` — POST `/api/auth/register`, POST `/api/auth/login` | REST endpoints |
| 9 | `AuthService` — register (hash password), login (return JWT) | service class |
| 10 | Auth DTOs: `RegisterRequest`, `LoginRequest`, `AuthResponse` | DTOs |

## Phase 3 — Application CRUD

| # | Task | Output |
|---|------|--------|
| 11 | `Application` entity (all fields from schema, status ENUM) | entity |
| 12 | `ApplicationRepository` (JPA, filter by user_id) | repo |
| 13 | `StatusHistory` entity + `StatusHistoryRepository` | entity + repo |
| 14 | Application DTOs: `ApplicationRequest`, `ApplicationResponse`, `PagedResponse<T>` | DTOs |
| 15 | `ApplicationMapper` (MapStruct) | mapper |
| 16 | `ApplicationService` — CRUD + `updateStatus()` (logs to status_history) | service |
| 17 | `ApplicationController` — GET list (paginated), GET detail, POST, PATCH status, DELETE | REST controller |
| 18 | `GlobalExceptionHandler` (`@RestControllerAdvice`) — 400, 401, 403, 404, 500 | exception handler |

## Phase 4 — Dashboard

| # | Task | Output |
|---|------|--------|
| 19 | `DashboardService` + `DashboardStatsResponse` DTO | service + DTO |
| 20 | `DashboardController` — GET `/api/dashboard/stats` (count by status, total) | REST endpoint |

## Phase 5 — Tests

| # | Task | Output |
|---|------|--------|
| 21 | Unit tests for `ApplicationService` (JUnit 5 + Mockito) | test class |
| 22 | Unit tests for `AuthService` | test class |
| 23 | Integration tests for auth endpoints (MockMvc + Testcontainers MySQL) | test class |
| 24 | Integration tests for application endpoints | test class |

## Phase 6 — Frontend

| # | Task | Output |
|---|------|--------|
| 25 | Initialize React + TypeScript project with Vite + Tailwind CSS in `frontend/` | `frontend/` scaffold |
| 26 | Set up React Router (`/login`, `/register`, `/dashboard`, `/applications`, `/applications/:id`) | router config |
| 27 | Axios instance with JWT interceptor + 401 redirect | `src/api/api.ts` |
| 28 | Auth state management (`useAuth` context + localStorage) | auth context |
| 29 | Login page | `LoginPage.tsx` |
| 30 | Register page | `RegisterPage.tsx` |
| 31 | Applications list page (table, status badges, pagination) | `ApplicationsPage.tsx` |
| 32 | Add/Edit Application form | `ApplicationForm.tsx` |
| 33 | Application detail page (read-only + status timeline) | `ApplicationDetailPage.tsx` |
| 34 | Dashboard page (count cards per status) | `DashboardPage.tsx` |

## Phase 7 — DevOps

| # | Task | Output |
|---|------|--------|
| 35 | `Dockerfile` for Spring Boot API (multi-stage: Maven build → JRE runtime) | `Dockerfile` |
| 36 | `Dockerfile` for React frontend (Vite build → Nginx) | `frontend/Dockerfile` |
| 37 | `docker-compose.yml` (api + ui + mysql, env vars, health checks, volumes) | `docker-compose.yml` |
| 38 | End-to-end smoke test: `docker-compose up`, register, create application, view dashboard | manual verification |

---

## Key Files

```
pom.xml
src/main/java/com/jobtrackr/JobTrackrApplication.java
src/main/java/com/jobtrackr/config/{SecurityConfig,JwtFilter,JwtUtil}.java
src/main/java/com/jobtrackr/entity/{User,Application,StatusHistory}.java
src/main/java/com/jobtrackr/repository/{UserRepository,ApplicationRepository,StatusHistoryRepository}.java
src/main/java/com/jobtrackr/dto/{RegisterRequest,LoginRequest,AuthResponse}.java
src/main/java/com/jobtrackr/dto/{ApplicationRequest,ApplicationResponse,PagedResponse,DashboardStatsResponse}.java
src/main/java/com/jobtrackr/mapper/ApplicationMapper.java
src/main/java/com/jobtrackr/service/{AuthService,ApplicationService,DashboardService}.java
src/main/java/com/jobtrackr/controller/{AuthController,ApplicationController,DashboardController}.java
src/main/java/com/jobtrackr/exception/{GlobalExceptionHandler,ResourceNotFoundException}.java
src/main/resources/application.yml
src/main/resources/db/migration/{V1__init.sql,V2__status_history.sql}
src/test/java/com/jobtrackr/service/{ApplicationServiceTest,AuthServiceTest}.java
src/test/java/com/jobtrackr/controller/{AuthControllerIT,ApplicationControllerIT}.java
frontend/src/{pages,components,context,api,hooks}/
Dockerfile
frontend/Dockerfile
docker-compose.yml
```

---

## Verification

1. `mvn clean install` — all tests pass, build succeeds
2. `docker-compose up` — all 3 services start healthy
3. `POST /api/auth/register` → 201, `POST /api/auth/login` → JWT
4. `POST /api/applications` with JWT → 201
5. `PATCH /api/applications/{id}/status` → status updated, history logged
6. `GET /api/dashboard/stats` → counts per status
7. Frontend: login → applications list → add application → view detail
