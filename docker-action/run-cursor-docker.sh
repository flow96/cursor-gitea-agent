#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.cursor"
echo "{\"mcpServers\": {\"gitea\": {\"command\": \"/tmp/gitea-mcp/gitea-mcp\", \"args\": [\"-t\", \"stdio\"], \"env\": {\"GITEA_HOST\": \"${GITEA_BASE_URL}\", \"GITEA_ACCESS_TOKEN\": \"${GITEA_ACCESS_TOKEN}\"}}}}" >> "$HOME/.cursor/mcp.json"

# Enable Gitea MCP server
agent mcp enable gitea


if [ -z "$COMMENT_CONTENT" ]; then
    echo "Error: COMMENT_CONTENT environment variable not set"
    exit 1
fi

if [ -z "$CONTEXT_JSON" ]; then
    echo "Error: CONTEXT_JSON environment variable not set"
    exit 1
fi

echo "$COMMENT_CONTENT" > comment.txt
echo "$CONTEXT_JSON" > context.json

# Extract the user's request (everything after @cursor)
COMMENT=$(cat comment.txt | sed 's/.*@cursor//')
CONTEXT=$(cat context.json)

# Build the context-rich prompt
PROMPT="You are an autonomous software engineering agent called cursor for repository: $REPO_FULL_NAME

## CONTEXT INFORMATION
$CONTEXT

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

echo "=================== RUNNING CURSOR AGENT (Model: ${AI_MODEL}) ==================="

# Run Cursor headless with the rich context
agent -p "$PROMPT" --force --model ${AI_MODEL} --output-format=text

echo "=================== CURSOR AGENT COMPLETED ==================="