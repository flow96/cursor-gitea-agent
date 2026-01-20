# Cursor Gitea Agent

A Gitea Action for self-hosted Action Runners that enables Cursor AI assistance in your Gitea repository. Mention `@cursor` in an issue or pull request comment to get AI-powered help.

## Prerequisite

Action Runners must be setup and working on your gitea instance.

## Setup

1. **Create a "cursor" user** in your Gitea instance. The name must be "cursor" since that will be the trigger word.
2. **Login as the cursor user** and create an API token with repository access permissions. Store that token, and logout again.
3. **Add the new cursor user as a member** to repositories where you want AI assistance.
4. **Create the cursor workflow** file in your repository's `.gitea/workflows/` directory.

## Workflow File

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
- `cursor_api_key` (required): Your Cursor API key. Store that as a secret in your project.
- `gitea_token` (required): Gitea API token created from the new cursor account with repository access.  Store that as a secret in your project.
- `gitea_base_url` (required): Your Gitea instance URL
- `ai_model` (required): AI model to use (default: `sonnet-4.5`, available models: `auto, composer-1, gpt-5.2-codex, gpt-5.2-codex-high, gpt-5.2-codex-low, gpt-5.2-codex-xhigh, gpt-5.2-codex-fast, gpt-5.2-codex-high-fast, gpt-5.2-codex-low-fast, gpt-5.2-codex-xhigh-fast, gpt-5.1-codex-max, gpt-5.1-codex-max-high, gpt-5.2, opus-4.5-thinking, gpt-5.2-high, gemini-3-pro, opus-4.5, sonnet-4.5, sonnet-4.5-thinking, gpt-5.1-high, gemini-3-flash, grok`)

## How it works

Tagging the newly created `@cursor` user on an issue or pull request will trigger the cursor action and execute the following:
1. Check if @cursor has been mentioned in the comment.
2. Capture the full context (issue/PR details, repository info).
3. Run Cursor AI with the given comment and context.
4. Provides intelligent code assistance responses.

You can ask Cursor to review a PR, plan out a feature by filling out issue details or ask it to implement a specific feature and create a PR.