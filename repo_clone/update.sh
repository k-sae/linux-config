#!/bin/bash
#!/bin/bash

# GitHub Repository Sync Script
# Syncs all repositories from a source organization to a target organization

# Configuration
TOKEN_FILE="./token"  # File containing GitHub token
API_URL="https://api.github.com"
TEMP_DIR=$(mktemp -d -t repo-sync.XXXXX)

# Error handling
set -e
trap 'cleanup' EXIT
trap 'echo "Error on line $LINENO"; exit 1' ERR

cleanup() {
    echo "Cleaning up..."
    rm -rf "$TEMP_DIR"
}

# Check dependencies
check_dependencies() {
    command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed. Aborting."; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "jq is required but not installed. Aborting."; exit 1; }
    command -v git >/dev/null 2>&1 || { echo "git is required but not installed. Aborting."; exit 1; }
}

# Read GitHub token from file
get_github_token() {
    if [[ ! -f "$TOKEN_FILE" ]]; then
        echo "GitHub token file not found at $TOKEN_FILE"
        echo "Please create a file with your GitHub personal access token"
        exit 1
    fi
    
    GITHUB_TOKEN=$(cat "$TOKEN_FILE" | tr -d '[:space:]')
    
    if [[ -z "$GITHUB_TOKEN" ]]; then
        echo "Token file is empty"
        exit 1
    fi
}

# Make authenticated GitHub API request
github_api() {
    local endpoint="$1"
    local method="${2:-GET}"
    local data="${3:-}"
    
    local curl_cmd=("curl" -s -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json")
    
    if [[ "$method" == "POST" ]]; then
        curl_cmd+=(-X POST -H "Content-Type: application/json" -d "$data")
    else
        curl_cmd+=(-X GET)
    fi
    
    "${curl_cmd[@]}" "$API_URL/$endpoint"
}

# Get all repositories for an organization
get_org_repos() {
    local org="$1"
    local page=1
    local repos=()
    
    while : ; do
        local response=$(github_api "orgs/$org/repos?page=$page&per_page=100")
        local count=$(echo "$response" | jq length)
        
        if [[ "$count" == "0" ]]; then
            break
        fi
        
        repos+=($(echo "$response" | jq -r '.[].name'))
        ((page++))
    done
    
    echo "${repos[@]}"
}

# Check if repository exists in organization
repo_exists() {
    local org="$1"
    local repo="$2"
    
    github_api "repos/$org/$repo" | jq -e '.id' >/dev/null 2>&1
}

# Create repository in organization
create_repo() {
    local org="$1"
    local repo="$2"
    local source_org="$3"
    
    echo "Creating $repo in $org..."
    
    # Get source repo details to copy settings
    local source_repo=$(github_api "repos/$source_org/$repo")
    local description=$(echo "$source_repo" | jq -r '.description // ""')
    local homepage=$(echo "$source_repo" | jq -r '.homepage // ""')
    local private=$(echo "$source_repo" | jq -r '.private')
    local has_issues=$(echo "$source_repo" | jq -r '.has_issues')
    local has_projects=$(echo "$source_repo" | jq -r '.has_projects')
    local has_wiki=$(echo "$source_repo" | jq -r '.has_wiki')
    
    local data=$(jq -n \
        --arg name "$repo" \
        --arg description "$description" \
        --arg homepage "$homepage" \
        --argjson private "$private" \
        --argjson has_issues "$has_issues" \
        --argjson has_projects "$has_projects" \
        --argjson has_wiki "$has_wiki" \
        '{
            name: $name,
            description: $description,
            homepage: $homepage,
            private: $private,
            has_issues: $has_issues,
            has_projects: $has_projects,
            has_wiki: $has_wiki,
            auto_init: false
        }')
    
    github_api "orgs/$org/repos" "POST" "$data" >/dev/null
}

# Clone repository with all branches
clone_repo() {
    local org="$1"
    local repo="$2"
    local dir="$3"
    
    echo "Cloning $org/$repo..."
    
    # Use token for authentication
    local url="https://$GITHUB_TOKEN@github.com/$org/$repo.git"
    git clone --mirror "$url" "$dir" 2>/dev/null || return 1
}

# Push all branches to target repository
push_to_target() {
    local org="$1"
    local repo="$2"
    local dir="$3"
    
    echo "Pushing to $org/$repo..."
    
    cd "$dir"
    local url="https://$GITHUB_TOKEN@github.com/$org/$repo.git"
    git push --mirror "$url" 2>/dev/null || return 1
    cd - >/dev/null
}

# Main sync function
sync_repos() {
    local source_org="$1"
    local target_org="$2"
    
    echo "Getting repositories from $source_org..."
    local repos=($(get_org_repos "$source_org"))
    
    if [[ ${#repos[@]} -eq 0 ]]; then
        echo "No repositories found in $source_org"
        return
    fi
    
    echo "Found ${#repos[@]} repositories in $source_org"
    
    for repo in "${repos[@]}"; do
        echo "Processing: $repo"
        
        # Check if repo exists in target org
        if repo_exists "$target_org" "$repo"; then
            echo "$repo exists in $target_org, updating..."
        else
            echo "$repo does not exist in $target_org, creating..."
            create_repo "$target_org" "$repo" "$source_org"
        fi
        
        # Clone and push
        local repo_dir="$TEMP_DIR/$repo"
        if clone_repo "$source_org" "$repo" "$repo_dir"; then
            if push_to_target "$target_org" "$repo" "$repo_dir"; then
                echo "Successfully synced $repo"
            else
                echo "Failed to push $repo to $target_org"
            fi
            rm -rf "$repo_dir"
        else
            echo "Failed to clone $source_org/$repo"
        fi
        
        echo
    done
}

# Main execution
main() {
    check_dependencies
    get_github_token
    
    local source_org="swayful"
    local target_org="TMGroup211"
    
    echo "Starting sync from $source_org to $target_org"
    sync_repos "$source_org" "$target_org"
    echo "Sync completed"
}

main "$@"