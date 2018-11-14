#!/bin/bash

mysql --user=root --host=127.0.0.1 <<EOF
CREATE USER IF NOT EXISTS 'gitlab'@'127.0.0.1';
GRANT ALL PRIVILEGES ON gitlabhq_test.* TO 'gitlab'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF
