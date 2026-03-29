#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# rollout-status.sh — Watch deployment rollout
# Usage: ./scripts/rollout-status.sh <dev|prod>
# ─────────────────────────────────────────────────────
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'

OVERLAY="${1:-dev}"
NS="devops-${OVERLAY}"
DEPLOY="${OVERLAY}-devops-app"

echo -e "${CYAN}Watching rollout: ${DEPLOY} in namespace ${NS}${NC}"
echo ""

if kubectl rollout status deployment/"${DEPLOY}" \
    --namespace "${NS}" \
    --timeout=120s; then
  echo ""
  echo -e "${GREEN}✓ Rollout complete${NC}"
  echo ""
  kubectl get pods -n "${NS}" -l "app=devops-app" \
    -o wide --sort-by='.status.startTime'
else
  echo ""
  echo -e "${RED}✗ Rollout failed or timed out${NC}"
  echo ""
  echo "Recent events:"
  kubectl get events -n "${NS}" \
    --sort-by='.lastTimestamp' \
    --field-selector reason=Failed | tail -10
  exit 1
fi
