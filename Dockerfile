FROM python:3.13-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY . .

EXPOSE 5000

ENV FLASK_APP="app.py"
CMD ["uv", "run", "flask", "run", "--host=0.0.0.0"]
