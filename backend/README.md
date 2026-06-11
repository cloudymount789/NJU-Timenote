# NJU Timenote Backend

This directory contains optional remote services for the local-first NJU Timenote app.

The service does not persist courses, todos, tags, settings, or uploaded user content by default. Core app features must remain usable without this service.

## Local development

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install -e ".[dev]"
.\.venv\Scripts\python -m uvicorn app.main:app --reload
```

Run checks:

```powershell
.\.venv\Scripts\python -m pytest
.\.venv\Scripts\python -m ruff check --no-cache .
```

Available endpoints:

- `GET /health`
- `GET /api/v1/capabilities`
