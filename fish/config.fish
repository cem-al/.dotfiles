# ── Environment variables (all shells) ──────────────────────────────

set -gx EDITOR hx
set -gx BAT_THEME Dracula
set -gx GOPATH $HOME/go

# ── PATH (fish_add_path deduplicates automatically) ────────────────

fish_add_path ~/.cargo/bin
fish_add_path $GOPATH/bin
fish_add_path ~/.local/bin
fish_add_path ~/bin

# ── Tool init (all shells) ─────────────────────────────────────────

# mise activates automatically for fish via Homebrew shim
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Secrets (outside this repo, not tracked by git)
test -f ~/.secrets.fish; and source ~/.secrets.fish

# ── Interactive shell only ─────────────────────────────────────────

if status is-interactive
    # Abbreviations
    alias ls='eza -alh --group-directories-first --sort=type --no-permissions --no-user'
    alias cat='bat'
    alias rm='trash'
    alias L='lazygit'
    alias zz='zi'
    alias cc='claude --effort max'
    alias ccw='claude --worktree --effort max'
    alias td='hx ~/code/notes/todo.md'
    alias todo='hx ~/code/notes/todo.md'

    # Atuin shell history (regenerate with: atuin init fish > ~/.config/fish/cache/atuin.fish)
    set -gx ATUIN_NOBIND true
    source ~/.config/fish/cache/atuin.fish 2>/dev/null
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
    bind \e\[A _atuin_bind_up
    bind -M insert \e\[A _atuin_bind_up

    # Zoxide (regenerate with: zoxide init fish > ~/.config/fish/cache/zoxide.fish)
    source ~/.config/fish/cache/zoxide.fish 2>/dev/null

    # Clipboard bindings
    bind Y fish_clipboard_copy
    bind p fish_clipboard_paste

    # Yazi file manager with cd-on-exit
    function yy
        set tmp (mktemp -t "yazi-cwd.XXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            cd -- "$cwd"
        end
        command rm -f -- "$tmp"
    end

    # Restart AeroSpace
    function aero
        osascript -e 'quit app "AeroSpace"' && open -a AeroSpace
    end
end
