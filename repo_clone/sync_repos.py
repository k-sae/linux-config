from time import sleep
import requests
import os

# Configuration
TOKEN_FILE = 'token'
PRIMARY_ORG = 'swayful'  # Replace with your primary organization name
SECONDARY_ORG = 'TMGroup211'  # Replace with your secondary organization name

def read_token():
    try:
        with open(TOKEN_FILE, 'r') as file:
            return file.read().strip()
    except FileNotFoundError:
        print(f"Token file {TOKEN_FILE} not found.")
        exit(1)

def get_org_repos(org, token):
    repos = []
    page = 1
    while True:
        url = f'https://api.github.com/orgs/{org}/repos?page={page}&per_page=100'
        headers = {'Authorization': f'token {token}'}
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
        if not data:
            break
        repos.extend([(repo['name'], repo['private']) for repo in data])
        page += 1
    return repos

def create_repo(org, token, repo_name, private):
    url = f'https://api.github.com/orgs/{org}/repos'
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    data = {
        'name': repo_name,
        'private': private,
        'auto_init': False  # Don't initialize with README
    }
    response = requests.post(url, headers=headers, json=data)
    sleep(5)  # To avoid hitting rate limits
    if response.status_code == 201:
        print(f"Created repo {repo_name} in {org}")
    else:
        print(f"Failed to create repo {repo_name}: {response.json()}")

def main():
    token = read_token()
    
    # Get repositories from both organizations
    print(f"Fetching repositories from {PRIMARY_ORG}...")
    primary_repos = get_org_repos(PRIMARY_ORG, token)
    print(f"Found {len(primary_repos)} repositories in {PRIMARY_ORG}")
    
    print(f"Fetching repositories from {SECONDARY_ORG}...")
    secondary_repos = get_org_repos(SECONDARY_ORG, token)
    secondary_names = {repo[0] for repo in secondary_repos}
    print(f"Found {len(secondary_repos)} repositories in {SECONDARY_ORG}")
    
    # Find missing repositories
    missing_repos = [repo for repo in primary_repos if repo[0] not in secondary_names]
    
    if not missing_repos:
        print("No missing repositories found.")
        return
    
    print(f"Found {len(missing_repos)} missing repositories:")
    for repo_name, private_status in missing_repos:
        print(f"- {repo_name} (private: {private_status})")
        create_repo(SECONDARY_ORG, token, repo_name, private_status)

if __name__ == '__main__':
    main()