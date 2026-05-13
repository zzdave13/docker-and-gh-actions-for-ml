FROM python:3.11-slim

COPY --from=ghcr.io/astral-sh/uv:0.11.13 /uv /uvx /bin/

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT="/app/.venv"

ENV PATH="/app/.venv/bin:$PATH"
WORKDIR "/app"

COPY ./pyproject.toml ./uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev

COPY README.md ./
COPY src ./src
RUN uv sync --frozen --no-dev

EXPOSE 8000

CMD [ \
    "gunicorn", \
    "distilgpt2_api.api:app", \
    "--worker-class", "uvicorn.workers.UvicornWorker", \
    "--workers", "1", \
    "--bind", "0.0.0.0:8000" \
]