#!/usr/bin/env bash
set -e

if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found. Installing..."
    # Try to install jq based on available package manager
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y jq
    elif command -v apk &> /dev/null; then
        apk add --no-cache jq
    elif command -v yum &> /dev/null; then
        yum install -y jq
    else
        echo "Error: Could not install jq. Please install it manually."
        exit 1
    fi
fi

# Enable Gitea MCP server
agent mcp enable gitea

# Verify required files exist
if [ ! -f "comment.txt" ]; then
    echo "Error: comment.txt not found"
    exit 1
fi

if [ ! -f "context.json" ]; then
    echo "Error: context.json not found"
    echo "This file should be created by the 'Check Comment and Capture Context' step"
    exit 1
fi

# Extract the user's request (everything after @cursor)
COMMENT=$(cat comment.txt | sed 's/.*@cursor//')

# Parse context using jq
ISSUE_NUMBER=$(jq -r '.issue.number' context.json)
ISSUE_TITLE=$(jq -r '.issue.title' context.json)
ISSUE_BODY=$(jq -r '.issue.body // "No description provided"' context.json)
ISSUE_STATE=$(jq -r '.issue.state' context.json)
ISSUE_URL=$(jq -r '.issue.html_url' context.json)
IS_PR=$(jq -r '.issue.is_pull_request' context.json)
REPO_FULL_NAME=$(jq -r '.repository.full_name' context.json)
REPO_OWNER=$(jq -r '.repository.owner' context.json)
REPO_NAME=$(jq -r '.repository.name' context.json)
COMMENT_USER=$(jq -r '.comment.user' context.json)
COMMENT_URL=$(jq -r '.comment.html_url' context.json)
ISSUE_AUTHOR=$(jq -r '.issue.user' context.json)
LABELS=$(jq -r '.issue.labels | map(.name) | join(", ")' context.json)

# Determine if this is an issue or PR
if [ "$IS_PR" = "true" ]; then
  ISSUE_TYPE="Pull Request"
else
  ISSUE_TYPE="Issue"
fi

# Build the context-rich prompt
PROMPT="You are an autonomous software engineering agent for repository: $REPO_FULL_NAME

## CONTEXT INFORMATION

**Repository:** $REPO_FULL_NAME
**${ISSUE_TYPE} #${ISSUE_NUMBER}:** $ISSUE_TITLE
**Status:** $ISSUE_STATE
**Author:** $ISSUE_AUTHOR
**Labels:** ${LABELS:-None}
**URL:** $ISSUE_URL

**${ISSUE_TYPE} Description:**
$ISSUE_BODY

**Comment by @${COMMENT_USER}:**
$COMMENT_URL

## USER REQUEST

@${COMMENT_USER} has requested:
$COMMENT

## AVAILABLE TOOLS

You have full access to Gitea via MCP tools. Use them to:
- Fetch all comments on this $ISSUE_TYPE to understand the full conversation history
- If this is a PR: get the diff, changed files, and commits
- Read files from the repository to understand the codebase
- Create branches, make commits, and create pull requests
- Post comments with your findings or questions

## YOUR INSTRUCTIONS


1. **Gather More Context (if needed):**
   - Let the user know you've received the request and that you now start working on it.
   - Use MCP tools to fetch all comments on ${ISSUE_TYPE} #${ISSUE_NUMBER} to understand the discussion
   - If this is a PR, use MCP tools to get the PR details, diff, and changed files
   - Read relevant files from the codebase if needed to understand the context

2. **Analyze the Request:**
   - Understand what the user is asking for
   - Consider the context of the $ISSUE_TYPE and previous discussion
   - If the request is unclear, ask for clarification via a comment

3. **Take Action:**
   - If implementing code: create a feature branch and open a pull request
   - If reviewing code: post a structured review in the pull request
   - If answering questions: provide helpful, accurate information
   - If the request is not feasible or safe: explain why and suggest alternatives
   - Use the MCP tool to create a Pull Request if needed

4. **Let the user know you've completed the request**
    - Post your response as a comment on the ${ISSUE_TYPE}
    - If the request is not feasible or safe: explain why and suggest alternatives

## SAFETY RULES

- NEVER push directly to protected branches (main, master, etc.)
- Always use MCP tools for Gitea interactions
- Be minimal, precise, and safe in your actions"


echo "=================== PROMPT ==================="
echo "$PROMPT"
echo "=================== PROMPT END ==================="

echo "=================== RUNNING CURSOR AGENT ==================="
# Run Cursor headless with the rich context
agent -p "$PROMPT" --force --model grok --output-format=text

echo "=================== CURSOR AGENT COMPLETED ==================="