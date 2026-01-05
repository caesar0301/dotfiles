# Prune all docker junk data
# Requires: docker
docker-prune-all() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "[docker-prune-all] Error: docker not found in PATH" >&2
    return 1
  fi
  docker system prune -f
}

# Docker image tag generator
# Usage: docker-image-tag [tag] [mode]
docker-image-tag() {
  if ! command -v git >/dev/null 2>&1; then
    echo "[docker-image-tag] Error: git not found in PATH" >&2
    return 1
  fi
  TAG="${1:-notag}"
  MODE="${2:-release}"
  echo "${MODE}_$(date +"%Y%m%d%H%M%S")_${TAG}_$(git rev-parse HEAD | head -c 8)"
}

# Stop all running docker compose projects
docker-compose-stop-world() {
  if ! command -v docker >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    echo "[docker-compose-stop-world] Error: docker or jq not found in PATH" >&2
    return 1
  fi
  docker compose ls --format json | jq -r '.[].Name' | while IFS= read -r name; do
    docker compose -p "$name" down
  done
}

# Reset Colima environment (dangerous: removes all data)
docker-colima-reset-all() {
  rm -rf ~/.colima ~/.lima ~/.docker
}

# Diagnose Docker and Colima status
docker-colima-diagnose() {
    echo "🔍 Docker & Colima Diagnostics"
    echo "================================"
    echo ""
    
    # Check if colima is installed
    echo "📦 Colima Installation:"
    if command -v colima &> /dev/null; then
        echo "  ✅ Colima installed: $(which colima)"
        colima version 2>/dev/null || echo "  ⚠️  Could not get version"
    else
        echo "  ❌ Colima not installed"
        echo "  💡 Install with: brew install colima"
        return 1
    fi
    echo ""
    
    # Check colima status
    echo "🚀 Colima Status:"
    if colima status &> /dev/null; then
        colima status 2>&1 | sed 's/^/  /'
        echo "  ✅ Colima is running"
    else
        echo "  ❌ Colima is not running"
        echo "  💡 Start with: colima start"
    fi
    echo ""
    
    # Check colima list
    echo "📋 Colima Instances:"
    colima list 2>&1 | sed 's/^/  /'
    echo ""
    
    # Check docker installation
    echo "🐳 Docker Installation:"
    if command -v docker &> /dev/null; then
        echo "  ✅ Docker installed: $(which docker)"
        docker --version 2>/dev/null | sed 's/^/  /'
    else
        echo "  ❌ Docker CLI not installed"
        echo "  💡 Install with: brew install docker"
        return 1
    fi
    echo ""
    
    # Check environment variables
    echo "🔧 Environment Variables:"
    if [ -n "$DOCKER_HOST" ]; then
        echo "  ⚠️  DOCKER_HOST is set: $DOCKER_HOST"
        echo "  💡 This may override Colima context. Consider unsetting it."
    else
        echo "  ✅ DOCKER_HOST not set (good for Colima)"
    fi
    
    if [ -n "$DOCKER_CONTEXT" ]; then
        echo "  📌 DOCKER_CONTEXT: $DOCKER_CONTEXT"
    fi
    echo ""
    
    # Check docker context
    echo "🎯 Docker Context:"
    docker context ls 2>&1 | sed 's/^/  /'
    echo ""
    echo "  Current context: $(docker context show 2>/dev/null || echo 'unknown')"
    echo ""
    
    # Test docker connection
    echo "🔌 Docker Connection Test:"
    if docker info &> /dev/null; then
        echo "  ✅ Docker daemon is accessible"
        docker info 2>&1 | grep -E "Server Version|Operating System|OSType|Architecture|CPUs|Total Memory|Docker Root Dir" | sed 's/^/  /'
    else
        echo "  ❌ Cannot connect to Docker daemon"
        echo "  💡 Try: colima restart"
    fi
    echo ""
    
    # Test docker ps
    echo "🐋 Running Containers:"
    if docker ps --format "table {{.Names}}\t{{.Status}}" &> /dev/null; then
        local container_count=$(docker ps -q | wc -l | tr -d ' ')
        echo "  ✅ Docker ps works ($container_count containers running)"
        if [ "$container_count" -gt 0 ]; then
            docker ps --format "table {{.Names}}\t{{.Status}}" 2>&1 | head -6 | sed 's/^/  /'
            if [ "$container_count" -gt 5 ]; then
                echo "  ... and $((container_count - 5)) more"
            fi
        fi
    else
        echo "  ❌ docker ps failed"
    fi
    echo ""
    
    # Check socket files
    echo "🔗 Docker Socket Status:"
    local sockets=(
        "$HOME/.colima/default/docker.sock"
        "$HOME/.colima/docker.sock"
        "/var/run/docker.sock"
    )
    
    for sock in "${sockets[@]}"; do
        if [ -S "$sock" ]; then
            echo "  ✅ $sock (exists)"
        else
            echo "  ❌ $sock (not found)"
        fi
    done
    echo ""
    
    # Overall status and recommendations
    echo "📊 Overall Status:"
    if docker ps &> /dev/null && colima status &> /dev/null; then
        echo "  ✅ Everything looks good!"
    else
        echo "  ⚠️  Issues detected. Recommended actions:"
        echo ""
        echo "  🔧 Quick fixes:"
        echo "     1. Restart Colima: colima restart"
        echo "     2. Unset DOCKER_HOST: unset DOCKER_HOST"
        echo "     3. Use Colima context: docker context use colima"
        echo "     4. If still broken: colima stop && colima start"
    fi
    echo ""
    echo "================================"
}
