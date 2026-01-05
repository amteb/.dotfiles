# External Tool Integrations
# This file contains initialization for third-party CLI tools

# jj (Jujutsu VCS) completion
if command -v jj &> /dev/null; then
    source <(COMPLETE=zsh jj)
fi

# Starship prompt
eval "$(starship init zsh)"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Atuin (shell history)
eval "$(atuin init zsh --disable-up-arrow)"

# Opam (OCaml package manager)
# This section can be safely removed if not using OCaml
[[ ! -r '~/.opam/opam-init/init.zsh' ]] || source '~/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
