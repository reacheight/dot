set -g fish_greeting

set -gx EDITOR nvim
set -gx VISUAL nvim

if status is-interactive
    if command -q zoxide
        zoxide init fish | source
    end

    if command -q fzf
        fzf --fish 2>/dev/null | source
    end
end

# cd into the directory yazi was on when it exits (official yazi snippet)
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
