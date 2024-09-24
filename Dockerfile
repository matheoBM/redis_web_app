FROM python:3.11.9-slim-bullseye

RUN apt-get update && \
    apt-get upgrade --yes

RUN useradd --create-home redis_web_app
USER redis_web_app
WORKDIR /home/redis_web_app

ENV VIRTUALENV=/home/redis_web_app/venv
RUN python3 -m venv $VIRTUALENV
ENV PATH="$VIRTUALENV/bin:$PATH"

COPY --chown=redis_web_app pyproject.toml constraints.txt ./
RUN python -m pip install --upgrade pip setuptools && \
    python -m pip install --no-cache-dir -c constraints.txt ".[dev]"

COPY --chown=redis_web_app src/ src/
COPY --chown=redis_web_app test/ test/

RUN python -m pip install . -c constraints.txt && \
    python -m pytest test/unit/ && \
    python -m flake8 src/ && \
    python -m isort src/ --check && \
    python -m black src/ --check --quiet && \
    python -m pylint src/ --disable=C0114,C0116,R1705 && \
    python -m bandit -r src/ --quiet

CMD ["flask", "--app", "page_tracker.app", "run", \
"--host", "0.0.0.0", "--port", "5000"]