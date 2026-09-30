# AI dev team - sandboxed Claude Code environment.
# Runs the agent team against a project mounted at /workspace, so AI-written code
# and tests execute inside the container, not on your machine.
FROM node:22-bookworm-slim

ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates curl gnupg bash less procps python3 \
 && mkdir -p -m 755 /etc/apt/keyrings \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update && apt-get install -y --no-install-recommends gh \
 && npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} pnpm yarn \
 && npm cache clean --force \
 && rm -rf /var/lib/apt/lists/*

# The plugin itself (agents, commands, hooks), installed into Claude Code on first start.
COPY --chown=node:node .claude-plugin /opt/ai-dev-team/.claude-plugin
COPY --chown=node:node agents /opt/ai-dev-team/agents
COPY --chown=node:node commands /opt/ai-dev-team/commands
COPY --chown=node:node hooks /opt/ai-dev-team/hooks
COPY --chown=node:node settings /opt/ai-dev-team/settings
COPY --chmod=755 docker/entrypoint.sh /usr/local/bin/ai-dev-team-entrypoint

# Starts as root only to match the container user to the owner of /workspace
# (so bind-mounted projects are writable on Linux), then drops to that user.
ENV HOME=/home/node
WORKDIR /workspace
ENTRYPOINT ["ai-dev-team-entrypoint"]
CMD ["claude"]
