#!/usr/bin/env bash
# docker_cmd.sh — deep module: build the Claude execution command.
#
# Provides: build_claude_cmd()
# When --docker is active, constructs `docker sandbox run claude` with bind mounts.
# When not active, uses plain `claude`.
# Respects RALPH_CLAUDE_CMD override in both modes.

# build_claude_cmd <use_docker> <use_brave> <repo_dir> <prompt_args>
# Prints the full command string to stdout.
build_claude_cmd() {
  local use_docker="$1" use_brave="$2" repo_dir="$3" prompt_args="$4"
  local brave_flag=""
  [ "$use_brave" -eq 1 ] && brave_flag="--dangerously-skip-permissions"

  if [ -n "${RALPH_CLAUDE_CMD:-}" ]; then
    echo "$RALPH_CLAUDE_CMD${brave_flag:+ $brave_flag} $prompt_args"
    return
  fi

  if [ "$use_docker" -eq 1 ]; then
    local home="${HOME:-/root}"
    echo "docker sandbox run" \
      "-v ${repo_dir}:${repo_dir}" \
      "-v ${home}/.gitconfig:${home}/.gitconfig:ro" \
      "-v ${home}/.config/gh/:${home}/.config/gh/:ro" \
      "-v ${home}/.claude/:${home}/.claude/:ro" \
      "claude${brave_flag:+ $brave_flag} $prompt_args"
  else
    echo "claude${brave_flag:+ $brave_flag} $prompt_args"
  fi
}
