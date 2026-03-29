#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# apply.sh — Deploy a Kustomize overlay
# Usage: ./scripts/apply.sh <dev|prod> [--dry-run]
# ─────────────────────────────────────────────────────
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}[apply]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}  $*"; }
err()  { echo -e "${RED}[error]${NC} $*" >&2; exit 1; }

[[ $# -lt 1 ]] && err "Usage: $0 <dev|prod> [--dry-run]"

OVERLAY="$1"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

[[ "$OVERLAY" =~ ^(dev|prod)$ ]] || err "Overlay must be 'dev' or 'prod'"
[[ -d "overlays/${OVERLAY}" ]]   || err "Overlay directory not found: overlays/${OVERLAY}"

command -v kubectl &>/dev/null    || err "kubectl not found"
kubectl cluster-info &>/dev/null  || err "Cannot reach Kubernetes cluster"

log "Deploying overlay: ${OVERLAY}"

if $DRY_RUN; then
  warn "DRY RUN — showing what would be applied:"
  kubectl apply -k "overlays/${OVERLAY}" --dry-run=client
else
  # Show diff before applying
  if kubectl diff -k "overlays/${OVERLAY}" &>/dev/null; then
    log "No changes detected — cluster is already up to date"
  else
    echo -e "${CYAN}Changes to be applied:${NC}"
    kubectl diff -k "overlays/${OVERLAY}" || true
    echo ""
    read -rp "$(echo -e "${YELLOW}Apply these changes? [y/N]: ${NC}")" confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { warn "Aborted."; exit 0; }

    kubectl apply -k "overlays/${OVERLAY}"
    log "Applied ✓ — watching rollout..."
    ./scripts/rollout-status.sh "$OVERLAY"
  fi
fi
