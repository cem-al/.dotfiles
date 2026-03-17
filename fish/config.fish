# ── Environment variables (all shells) ──────────────────────────────

set -gx EDITOR hx
set -gx EZA_CONFIG_DIR "$HOME/.config/eza"
set -gx BAT_THEME Dracula
set -gx HELIX_RUNTIME ~/.config/helix/runtime
set -gx NVM_DEFAULT_VERSION 21

set -gx GOPATH $HOME/go
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PNPM_HOME "$HOME/Library/pnpm"

# FFF file manager
set -gx FFF_LS_COLORS 1
set -gx FFF_COL2 5
set -gx FFF_COL3 2
set -gx FFF_COL4 1
set -gx FFF_COL5 8
set -gx FFF_STAT_CMD stat
set -gx FFF_CD_ON_EXIT 0
set -gx FFF_CD_FILE ~/.fff_d
set -gx FFF_TRASH_CMD trash

# ── PATH (fish_add_path deduplicates automatically) ────────────────

fish_add_path ~/.cargo/bin
fish_add_path $GOPATH/bin
fish_add_path ~/Go/bin
fish_add_path $BUN_INSTALL/bin
fish_add_path $PNPM_HOME
fish_add_path "$HOME/.rd/bin"
fish_add_path "$HOME/.codeium/windsurf/bin"
fish_add_path ~/.local/bin
fish_add_path ~/bin

# ── Tool init (all shells) ─────────────────────────────────────────

source /opt/homebrew/opt/asdf/libexec/asdf.fish
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Secrets (outside this repo, not tracked by git)
test -f ~/.secrets.fish; and source ~/.secrets.fish

# ── Interactive shell only ─────────────────────────────────────────

if status is-interactive
    # Abbreviations
    abbr -a L lazygit
    abbr -a ls 'eza -alh --group-directories-first --sort=type --no-permissions --no-user'
    abbr -a cat bat
    abbr -a zz zi
    abbr -a cc claude
    abbr -a ccw 'claude --worktree'
    abbr -a td 'hx ~/code/notes/todo.md'
    abbr -a todo 'hx ~/code/notes/todo.md'

    alias rm="trash"

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
    bind yy fish_clipboard_copy
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
