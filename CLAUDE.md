# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

JobTrackr is currently in the **planning phase**. Only `requirements.md` exists — no source code has been written yet. The project is ready to be built following the phased roadmap in `requirements.md`.

## Tech Stack

- **Backend:** Spring Boot 3.x, Java 21, Maven
  - Spring Security (JWT), Spring Data JPA, Spring Mail, Spring Batch, Spring Cache
  - Flyway (DB migrations), MapStruct (DTO mapping)
  - MySQL 8
- **Frontend:** React + TypeScript, Vite, Tailwind CSS
  - React Query, React DnD (or dnd-kit), Recharts
- **Deployment:** Docker + Docker Compose

## Architecture

```
frontend/           React + TypeScript (Vite)
    ↓ REST API (JSON)
src/main/java/com/jobtrackr/
    config/         Security, CORS, Mail config
    controller/     REST controllers
    service/        Business logic
    repository/     JPA repositories
    entity/         JPA entities
    dto/            Request/Response DTOs
    mapper/         MapStruct mappers
    scheduler/      @Scheduled reminder jobs
    exception/      Global exception handling (@RestControllerAdvice)
src/main/resources/
    db/migration/   Flyway SQL scripts (V1__, V2__, ...)
    application.yml
```

## Commands

### Backend
```bash
mvn clean install          # Build and run all tests
mvn spring-boot:run        # Run the API server
mvn test                   # Run all tests
mvn test -Dtest=FooTest    # Run a single test class
mvn verify                 # Run integration tests
```

### Frontend (inside `frontend/`)
```bash
npm install       # Install dependencies
npm run dev       # Start dev server
npm run build     # Production build
npm run test      # Run tests
```

### Docker
```bash
docker-compose up     # Start full stack (api + ui + mysql)
docker-compose down   # Stop all services
```

## Key Design Decisions

- **JWT auth:** Token stored in localStorage on the frontend; Spring Security filter chain validates on every request
- **Status pipeline:** `Saved → Applied → Phone Screen → Technical Screen → Technical Interview → Behavioral Interview → On-site → Final Round → Offer → Rejected → Withdrawn` — every status change is logged to `status_history`. Not all applications pass through every stage.
- **Flyway migrations:** Named `V1__`, `V2__`, etc. in `src/main/resources/db/migration/`
- **All list endpoints** must be paginated with metadata in response
- **User data isolation:** Every query must filter by the authenticated user's ID
- **File storage:** Resumes/cover letters stored locally or S3 (configurable via `application.yml`)

## Testing Strategy

- Unit tests: JUnit 5 + Mockito for service layer
- Integration tests: `@SpringBootTest` + Testcontainers (MySQL) for repositories and full flows
- Controller tests: MockMvc for API endpoints
- Target: >70% code coverage

## API Base

All endpoints are prefixed with `/api`. See `requirements.md` for the full REST API design and database schema.
