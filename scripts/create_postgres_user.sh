#!/bin/bash

psql -h localhost -U postgres postgres <<EOF
CREATE USER gitlab;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO gitlab;
EOF
