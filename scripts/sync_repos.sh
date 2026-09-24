#! /usr/bin/env bash

set -uo pipefail

APPLY=1
[ "${1:-}" = "-n" ] && APPLY=0

GIT_ROOT="$HOME/git"
export GIT_TERMINAL_PROMPT=0

IGNORES=(.claude .DS_Store)

read -r -d '' ATTRS <<'EOF'
* text=auto eol=lf
*.py    text eol=lf
*.tf    text eol=lf
*.yaml  text eol=lf
*.yml   text eol=lf
*.sh    text eol=lf
*.nix   text eol=lf
*.md    text eol=lf
*.json  text eol=lf
*.toml  text eol=lf
*.png   binary
*.jpg   binary
*.pdf   binary
*.zip   binary
EOF

r='\033[0;31m'; y='\033[1;33m'; g='\033[0;32m'; b='\033[0;34m'; nc='\033[0m'
note() { echo -e "  ${g}[+]${nc} $*"; }
warn() { echo -e "  ${y}[!]${nc} $*"; }
fail() { echo -e "  ${r}[x]${nc} $*"; }
would() { echo -e "  ${b}would:${nc} $*"; }

repos=()
for d in "$GIT_ROOT"/*/; do
    d="${d%/}"
    if [ -e "$d/.git" ]; then
        repos+=("$d")
    else
        for sub in "$d"/*/; do
            [ -e "${sub}.git" ] && repos+=("${sub%/}")
        done
    fi
done

for repo in "${repos[@]}"; do
    echo "── ${repo#"$GIT_ROOT"/}"

    if ! git -C "$repo" rev-parse --abbrev-ref '@{u}' &>/dev/null; then
        warn "no upstream, not pulled"
    elif [ $APPLY -eq 0 ]; then
        would "git pull --ff-only"
    elif out=$(git -C "$repo" pull --ff-only 2>&1); then
        case "$out" in *"Already up to date"*) ;; *) note "pulled" ;; esac
    else
        why=$(grep -m1 -iE '^(error|fatal)' <<<"$out" || tail -n1 <<<"$out")
        fail "pull failed: $why"
    fi

    while IFS= read -r nested; do
        warn "nested .claude: ${nested#"$repo"/}"
    done < <(find "$repo" -mindepth 2 \
        \( -name .git -o -name node_modules -o -name .direnv -o -name target \) -prune \
        -o -name .claude -print 2>/dev/null)


    while IFS= read -r tracked; do
        warn "tracked, needs git rm -r --cached: $tracked"
    done < <(git -C "$repo" ls-files | grep -E '(^|/)(\.claude|\.DS_Store)(/|$)')

    gi="$repo/.gitignore"
    for pat in "${IGNORES[@]}"; do
        re="^(/|\*\*/)?${pat//./\\.}/?[[:space:]]*$"
        [ -f "$gi" ] && grep -qE "$re" "$gi" && continue
        if [ $APPLY -eq 0 ]; then
            would "add $pat to .gitignore"
            continue
        fi
        [ -s "$gi" ] && [ -n "$(tail -c1 "$gi")" ] && echo >>"$gi"
        echo "$pat" >>"$gi"
        note "added $pat to .gitignore"
    done

    ga="$repo/.gitattributes"
    if [ ! -f "$ga" ] || [ "$(cat "$ga")" != "$ATTRS" ] || [ -n "$(tail -c1 "$ga")" ]; then
        if [ -f "$ga" ]; then now=rewrite; did=rewrote; else now=create; did=created; fi
        if [ $APPLY -eq 0 ]; then
            would "$now .gitattributes"
        else
            printf '%s\n' "$ATTRS" >"$ga"
            note "$did .gitattributes"
        fi
    fi
done

# Context: exactly one CLAUDE.md per project, at ~/git/<project>/ — never in a
# subdirectory, never in a nested repo. See ~/CLAUDE.md, "Claude context".
echo "── context"
for proj in "$GIT_ROOT"/*/; do
    proj="${proj%/}"
    name="${proj#"$GIT_ROOT"/}"

    if [ ! -f "$proj/CLAUDE.md" ] && [ ! -f "$proj/CLAUDE.local.md" ]; then
        warn "$name: no CLAUDE.md"
    fi

    while IFS= read -r nested; do
        warn "$name: nested ${nested#"$proj"/} — context belongs at the project root"
    done < <(find "$proj" -mindepth 2 \
        \( -name .git -o -name node_modules -o -name .direnv -o -name target \) -prune \
        -o \( -name CLAUDE.md -o -name CLAUDE.local.md \) -print 2>/dev/null)
done
