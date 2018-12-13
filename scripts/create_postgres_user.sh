#!/bin/bash

if pg_isready -h localhost -U postgres; then
  psql -h localhost -U postgres postgres <<EOF
  CREATE USER gitlab;
  GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gitlab;
EOF
fi
