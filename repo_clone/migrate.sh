#!/bin/bash

# GitHub Organization Migration Script
# Requires: curl, jq, git
# Usage: GITHUB_TOKEN=<your_token> ./migrate_repos.sh <source_org> <dest_org>

GITHUB_TOKEN=$(cat ./token)

set -euo pipefail

# Check dependencies
for cmd in curl jq git; do
    if ! command -v $cmd &>/dev/null; then
        echo "Error: $cmd is not installed"
        exit 1
    fi
done

# Validate arguments


SOURCE_ORG="swayful"
DEST_ORG="TMGroup211"
API_URL="https://api.github.com"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
TEMP_DIR=$(mktemp -d -t github-migrate-XXXXXX)

echo "Created temporary directory: $TEMP_DIR"
# trap 'rm -rf "$TEMP_DIR"' EXIT

# Get all repositories for an organization
get_repos() {
    local org="$1"
    local page=1
    local repos=()

    while :; do
        local response=$(curl -s -H "$AUTH_HEADER" \
            "$API_URL/orgs/$org/repos?per_page=100&page=$page")
        
        if [ -z "$response" ]; then
            break
        fi

        local count=$(echo "$response" | jq length)
        if [ "$count" -eq 0 ]; then
            break
        fi

        repos+=$(echo "$response" | jq -r '.[] | "\(.name) \(.private)"')
        ((page++))
    done

    echo "$repos"
}

# Create repository in destination organization
create_repo() {
    local repo="$1"
    local private="$2"

    curl -s -H "$AUTH_HEADER" -H "Accept: application/vnd.github.v3+json" \
        -X POST "$API_URL/orgs/$DEST_ORG/repos" \
        -d "{\"name\":\"$repo\", \"private\":$private}" >/dev/null
}

# Migrate repository with all branches
migrate_repo() {
    local repo="$1"
    local repo_dir="$TEMP_DIR/$repo"
    
    echo "Processing $SOURCE_ORG/$repo"
    
    # Clone with all references
    git clone --quiet --mirror "https://$GITHUB_TOKEN@github.com/$SOURCE_ORG/$repo.git" "$repo_dir"
    cd "$repo_dir"
    
    # Set new origin
    git remote set-url --push origin "https://$GITHUB_TOKEN@github.com/$DEST_ORG/$repo.git"
    
    # Push all references
    git push --quiet --mirror
    cd - >/dev/null
    
    # Clean up
    rm -rf "$repo_dir"
    echo "Successfully migrated $repo"
}

# Main migration process
echo "Starting migration from $SOURCE_ORG to $DEST_ORG"
repos=$(get_repos "$SOURCE_ORG")

if [ -z "$repos" ]; then
    echo "No repositories found in $SOURCE_ORG"
    exit 1
fi

echo "Found $(echo "$repos" | wc -l) repositories to migrate"

while read -r repo private; do
    (
        # Create destination repository
        #create_repo "$repo" "$private"
        
        # Migrate repository content
        migrate_repo "$repo"
    ) || echo "Failed to migrate $repo"
    
    # Avoid rate limiting
    sleep 2
done <<< "$repos"

echo "Migration completed successfully"