#!/bin/bash
set -euo pipefail

WORKERS=${WORKERS:-1}
WORKER_CLASS=${WORKER_CLASS:-gevent}
ACCESS_LOG=${ACCESS_LOG:--}
ERROR_LOG=${ERROR_LOG:--}
WORKER_TEMP_DIR=${WORKER_TEMP_DIR:-/dev/shm}
SECRET_KEY=${SECRET_KEY:-}
SKIP_DB_PING=${SKIP_DB_PING:-false}

OTEL_SERVICE_NAME=${OTEL_SERVICE_NAME:-"ctfd"}
OTEL_EXPORTER_OTLP_ENDPOINT=${OTEL_EXPORTER_OTLP_ENDPOINT:-""}
OTEL_EXPORTER_OTLP_INSECURE=${OTEL_EXPORTER_OTLP_INSECURE:-"false"}

# Check that a .ctfd_secret_key file or SECRET_KEY envvar is set
if [ ! -f .ctfd_secret_key ] && [ -z "$SECRET_KEY" ]; then
    if [ $WORKERS -gt 1 ]; then
        echo "[ ERROR ] You are configured to use more than 1 worker."
        echo "[ ERROR ] To do this, you must define the SECRET_KEY environment variable or create a .ctfd_secret_key file."
        echo "[ ERROR ] Exiting..."
        exit 1
    fi
fi

# Skip db ping if SKIP_DB_PING is set to a value other than false or empty string
if [[ "$SKIP_DB_PING" == "false" ]]; then
  # Ensures that the database is available
  python ping.py
fi

# Initialize database
flask db upgrade

if [[ "$OTEL_EXPORTER_OTLP_ENDPOINT" != "" ]]; then 
    echo "Modifying CTFd for OTEL support..."

    # This injects the monkey patch BEFORE auto-instrumentation, such there are no conflicts later
    cat <<EOF > /tmp/__init__.py
from gevent import monkey
monkey.patch_all()

from opentelemetry.instrumentation import auto_instrumentation
auto_instrumentation.initialize()
EOF
    cat /opt/CTFd/CTFd/__init__.py >> /tmp/__init__.py
    mv /tmp/__init__.py /opt/CTFd/CTFd/__init__.py

    export OTEL_SERVICE_NAME=$OTEL_SERVICE_NAME
    export OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT
    export OTEL_EXPORTER_OTLP_INSECURE=$OTEL_EXPORTER_OTLP_INSECURE
fi

exec gunicorn 'CTFd:create_app()' \
    --bind '0.0.0.0:8000' \
    --workers $WORKERS \
    --worker-tmp-dir "$WORKER_TEMP_DIR" \
    --worker-class "$WORKER_CLASS" \
    --access-logfile "$ACCESS_LOG" \
    --error-logfile "$ERROR_LOG"
