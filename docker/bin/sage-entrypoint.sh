#!/bin/bash
echo "[INFO] Installing yarn dependencies"
yarn install --verbose
echo "[DONE] Installing yarn dependencies"
echo "[INFO] Compiling assets for development environment"
yarn build
echo "[DONE] Compiling assets for development environment"
exec "$@"
