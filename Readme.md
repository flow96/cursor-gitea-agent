# Cursor Gitea Agent

A GitHub Action that enables Cursor AI assistance in your Gitea repository. Mention `@cursor` in issue or pull request comments to get AI-powered code help.

## Setup

1. **Create a "cursor" user** in your Gitea instance
2. **Login as the cursor user** and create an API token with repository access permissions
3. **Add the cursor user as a member** to repositories where you want AI assistance
4. **Create the workflow** file in your repository's `.github/workflows/` directory

## Usage

Add this workflow to your repository's `.gitea/workflows/` directory:

```yaml
name: Cursor Agent
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  cursor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: flow96/cursor-gitea-agent@main
        with:
          cursor_api_key: ${{ secrets.CURSOR_API_KEY }}
          gitea_token: ${{ secrets.GITEA_TOKEN }}
          gitea_base_url: <YOUR GITEA INSTANCE URL>
          ai_model: <AI MODEL>
```

## Secrets

Store secrets for the following parameters:
- `cursor_api_key` (required): Your Cursor API key
- `gitea_token` (required): Gitea API token created from the new cursor account with repository access
- `gitea_base_url` (required): Your Gitea instance URL
- `ai_model` (required): AI model to use (default: `sonnet-4.5`, available models: `auto, composer-1, gpt-5.2-codex, gpt-5.2-codex-high, gpt-5.2-codex-low, gpt-5.2-codex-xhigh, gpt-5.2-codex-fast, gpt-5.2-codex-high-fast, gpt-5.2-codex-low-fast, gpt-5.2-codex-xhigh-fast, gpt-5.1-codex-max, gpt-5.1-codex-max-high, gpt-5.2, opus-4.5-thinking, gpt-5.2-high, gemini-3-pro, opus-4.5, sonnet-4.5, sonnet-4.5-thinking, gpt-5.1-high, gemini-3-flash, grok`)

## How it works

When someone comments `@cursor` on an issue or pull request, the action:
1. Detects the mention
2. Captures the full context (issue/PR details, repository info)
3. Runs Cursor AI with the comment and context
4. Provides intelligent code assistance responses