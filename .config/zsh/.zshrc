# shellcheck disable=SC2148

# sheldon
eval "$(sheldon source)"

# gcloud
if [ -f '/Users/chikafumi/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/chikafumi/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/chikafumi/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/chikafumi/google-cloud-sdk/completion.zsh.inc'; fi

# iterm2
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh" || true
