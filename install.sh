#!/usr/bin/env bash

set -euo pipefail

# -------------
# Config
# -------------

GRAPHVIZ_VERSION="2.42.2-9ubuntu0.1"

DEB_DIR="debs"
DEB_URL_BASE="http://archive.ubuntu.com/ubuntu/pool/universe"

DEB_FILES=(
    "g/graphviz/graphviz_${GRAPHVIZ_VERSION}_amd64.deb"
    "g/graphviz/libcgraph6_${GRAPHVIZ_VERSION}_amd64.deb"
    "g/graphviz/libgvc6_${GRAPHVIZ_VERSION}_amd64.deb"
    "g/graphviz/libgvpr2_${GRAPHVIZ_VERSION}_amd64.deb"
    "g/graphviz/libcdt5_${GRAPHVIZ_VERSION}_amd64.deb"
    "g/graphviz/libpathplan4_${GRAPHVIZ_VERSION}_amd64.deb"
    "g/graphviz/libgts-0.7-5_0.7.6-6_amd64.deb"
    "a/ann/libann0_1.1.2+doc-9build1_amd64.deb"
    "x/xaw3d/libxaw7_2%3a1.0.14-1_amd64.deb"
)

# -------------
# Helpers
# -------------

info() { echo -e "ℹ️  $*"; }
ok()   { echo -e "✅ $*"; }
warn() { echo -e "⚠️  $*"; }
fail() { echo -e "❌ $*" >&2; exit 1; }

# -------------
# Sudo detection
# -------------

info "Detecting sudo availability..."

if [[ "$(id -u)" -eq 0 ]]; then
    SUDO=""
    ok "Running as root — no sudo needed"
else
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
        ok "Using existing sudo"
    else
        fail "❌ sudo is required but not installed, and you are not root. Cannot proceed."
    fi
fi

# -------------
# Downloader detection
# -------------

info "Detecting available downloader (wget or curl)..."

DOWNLOADER=""
if command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget -q -O"
    ok "Using existing wget for downloads"
elif command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl -fsSL -o"
    ok "Using existing curl for downloads"
else
    warn "Neither wget nor curl found — will install wget via apt-get (⚠️ this will be slow and defeats the purpose of this script!). Note: this should never happen on Ubuntu GitHub Actions runners."
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y wget
    DOWNLOADER="wget -q -O"
    ok "wget installed and ready"
fi

# -------------
# Main logic
# -------------

info "Preparing download directory..."
mkdir -p "${DEB_DIR}"

info "Downloading required .deb files..."
for deb_path in "${DEB_FILES[@]}"; do
    url="${DEB_URL_BASE}/${deb_path}"
    file="${DEB_DIR}/$(basename "${deb_path}")"
    
    if [[ -f "${file}" ]]; then
        ok "Cached: $(basename "${file}")"
    else
        info "Downloading $(basename "${file}")..."
        ${DOWNLOADER} "${file}" "${url}" || fail "Failed to download ${url}"
        ok "Downloaded $(basename "${file}")"
    fi
done

info "Installing .deb files with dpkg..."
# Allow partial install to continue and fix broken deps after
if ${SUDO} dpkg -i ${DEB_DIR}/*.deb; then
    ok "dpkg install step completed"
else
    warn "dpkg reported errors — will run apt-get -f install to fix"
fi

info "Running apt-get -f install..."
${SUDO} apt-get -f install -y || fail "apt-get -f install failed"
ok "All dependencies installed"

# -------------
# Validation
# -------------

info "Validating Graphviz installation..."

if command -v dot >/dev/null 2>&1; then
    ok "dot command found"
else
    fail "dot command NOT found after install"
fi

dot_version=$(dot -V 2>&1 || true)
if [[ -n "${dot_version}" ]]; then
    ok "Graphviz version: ${dot_version}"
else
    fail "Could not determine Graphviz version"
fi

info "Checking for missing shared libraries..."
if ldd "$(command -v dot)" | grep "not found"; then
    fail "Some shared libraries are missing!"
else
    ok "All shared libraries satisfied"
fi

ok "Graphviz installation verified successfully 🎉"
