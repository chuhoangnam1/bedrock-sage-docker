#!/bin/bash
echo "[INFO] Installing composer dependencies"
composer install -vvv
echo "[DONE] Installing composer dependencies"
exec "$@"
