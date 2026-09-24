#!/usr/bin/env bash
set -uo pipefail

hdisp() { hyprctl dispatch "$1" >/dev/null 2>&1; }
heval() { hyprctl eval     "$1" >/dev/null 2>&1; }

dwindle() { heval "hl.config({ dwindle = { $1 } }) hl.exec_scheduled_prop_refresh_immediately()"; }

TERMCLASS=sess.ghostty

DRY=0
FORCEWS=
PICKED=0

context_sarten() {
    DESC='server config'
    pane 50 "$(term ~/git/flakes nvim)"
    pane 50 "$(term ~/git/flakes ssh sarten)"
    ws
    pane 100 "$(browse \
        https://wazuh.tailfdd252.ts.net/ \
        https://grafana.tailfdd252.ts.net/ \
        http://sarten:8082)"
}

context_sec() {
    DESC='pentest + SOC'
    pane 50 "$(term ~/git/notes/study nvim)"
    pane 50 "$(term ~/git/notes/study)"
    ws
    pane 100 "$(browse \
        https://tryhackme.com/dashboard \
        https://app.hackthebox.com/ \
        https://wazuh.tailfdd252.ts.net/)"
    ws
    pane 100 burpsuite
}

context_data() {
    DESC='job hunt'
    pane 70 "$(browse \
        https://www.linkedin.com/jobs/ \
        https://www.getonbrd.com/jobs/data-science-analytics \
        https://www.computrabajo.cl/)"
    pane 30 "$(term ~/git/notes nvim work.md)"
}

context_book() {
    local dir
    dir=$(book_dir "${1:-}") || return 1
    DESC=${dir##*/}; DESC=${DESC#[0-9][0-9][0-9][0-9]_}; DESC=${DESC//_/ }

    if [ ! -f "$dir/book.pdf" ] && ((!DRY)); then
        say "building $dir/book.pdf for the first time"
        ( cd "$dir" && typst compile book.typ ) || warn "first build failed; zathura may open empty"
    fi

    pane 10 "$(term "$dir" typst watch book.typ)"
    pane 40 "$(term "$dir" nvim book.typ)"
    pane 50 "zathura $dir/book.pdf"
}

book_dir() {
    local sakuhin=$HOME/git/sakuhin name
    local -a books=()
    mapfile -t books < <(
        for d in "$sakuhin"/[0-9][0-9][0-9][0-9]_*/; do
            [ -d "$d" ] || continue
            name=${d%/}; name=${name##*/}
            [ "$name" = 0000_examples ] && continue
            printf '%s\t%s\n' "$(stat -c %Y "$d")" "$name"
        done | sort -rn | cut -f2
    )
    ((${#books[@]})) || { warn "no books under $sakuhin"; return 1; }

    if [ -n "${1:-}" ]; then
        for name in "${books[@]}"; do
            case $name in *"$1"*) printf '%s/%s' "$sakuhin" "$name"; return 0 ;; esac
        done
        warn "no book matching '$1' under $sakuhin"
        return 1
    fi

    if ((PICKED)); then
        name=$(printf '%s\n' "${books[@]}" | fuzzel --dmenu --prompt 'book: ') || return 1
        [ -n "$name" ] || return 1
    else
        name=${books[0]}
    fi
    printf '%s/%s' "$sakuhin" "$name"
}

term() {    # term <cwd> [command...]
    local cwd=$1; shift
    local out="ghostty --class=$TERMCLASS --working-directory=$cwd"
    (($#)) && out="$out -e $*"
    printf '%s' "$out"
}

browse() {  # browse <url> [url...] -- one window, the rest as tabs
    local out="firefox --new-window $1"; shift
    local u
    for u; do out="$out --new-tab $u"; done
    printf '%s' "$out"
}

CONTEXTS=(sarten sec data book)
PLAN=()
GROUP=0
DESC=

say()  { printf 'session: %s\n' "$*"; }
warn() { printf 'session: %s\n' "$*" >&2; }

die() {
    warn "$*"
    command -v notify-send >/dev/null && notify-send -u critical 'session' "$*"
    exit 1
}

ws()   { GROUP=$((GROUP + 1)); }
pane() { PLAN+=("$GROUP|$1|$2"); }

empty_workspaces() {
    local used ws
    used=$(hyprctl clients -j | jq -r '.[].workspace.id' | sort -un)
    for ws in 3 4 5 6 7 8; do
        grep -qx "$ws" <<<"$used" || printf '%s\n' "$ws"
    done
}

addrs_on() {  # addresses of the windows on workspace $1
    hyprctl clients -j | jq -r --argjson w "$1" '.[]|select(.workspace.id==$w)|.address'
}

wait_new() {  # wait_new <ws> <addresses before the launch>
    local wsid=$1 before=$2 i active
    for ((i = 0; i < 100; i++)); do
        active=$(hyprctl activewindow -j 2>/dev/null | jq -r 'select(.workspace.id == '"$wsid"') | .address // empty')
        if [ -n "$active" ] && ! grep -qxF "$active" <<<"$before"; then
            sleep 0.25
            return 0
        fi
        sleep 0.15
    done
    return 1
}

esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

usage() { printf 'usage: session.sh [-n] [-w N] [context] [arg]\ncontexts: %s\n' "${CONTEXTS[*]}"; }

layout_group() {
    local wsid=$1; shift
    local -a pcts=() cmds=()
    local entry
    for entry in "$@"; do
        pcts+=("${entry%%|*}")
        cmds+=("${entry#*|}")
    done

    local n=${#pcts[@]} i rem=100 ratio total=0
    for ((i = 0; i < n; i++)); do total=$((total + pcts[i])); done
    ((total == 100)) || warn "workspace $wsid: panes sum to $total%, not 100"

    hdisp "hl.dsp.focus({ workspace = $wsid })"
    dwindle 'force_split = 2'

    for ((i = 0; i < n; i++)); do
        if ((i > 0)); then
            ratio=$(awk -v p="${pcts[i-1]}" -v r="$rem" 'BEGIN{v=2*p/r; if(v<0.1)v=0.1; if(v>1.9)v=1.9; printf "%.4f", v}')
            dwindle "force_split = 2, default_split_ratio = $ratio"
            rem=$((rem - pcts[i-1]))
        fi
        say "ws $wsid  ${pcts[i]}%  ${cmds[i]}"
        local before=
        ((n > 1)) && before=$(addrs_on "$wsid")
        hdisp "hl.dsp.exec_cmd(\"[workspace $wsid] $(esc "${cmds[i]}")\")"
        if ((n > 1)); then
            wait_new "$wsid" "$before" || warn "ws $wsid: pane $((i + 1)) never took focus; layout may be off"
        fi
    done
}

restore() { dwindle 'force_split = 0, default_split_ratio = 1.0'; }

main() {
    while (($#)); do
        case $1 in
            -n|--dry-run) DRY=1; shift ;;
            -w|--workspace) FORCEWS=${2:-}; shift 2 ;;
            -h|--help) usage; return 0 ;;
            -*) warn "unknown flag: $1"; usage >&2; return 2 ;;
            *) break ;;
        esac
    done

    local ctx=${1:-}
    if [ -z "$ctx" ]; then
        ctx=$(printf '%s\n' "${CONTEXTS[@]}" | fuzzel --dmenu --prompt 'session: ') || return 0
        [ -n "$ctx" ] || return 0
        PICKED=1
    else
        shift
    fi
    case " ${CONTEXTS[*]} " in
        *" $ctx "*) ;;
        *) warn "no such context: $ctx"; usage >&2; return 2 ;;
    esac

    "context_$ctx" "$@" || return 1
    ((${#PLAN[@]})) || die "$ctx: nothing to launch"

    local -a groups=() targets=()
    local entry g
    for entry in "${PLAN[@]}"; do
        g=${entry%%|*}
        case " ${groups[*]-} " in *" $g "*) ;; *) groups+=("$g") ;; esac
    done
    if [ -n "$FORCEWS" ]; then
        targets=("$FORCEWS")
        ((${#groups[@]} > 1)) && warn "-w sets the first workspace; the rest go to empty ones"
    fi
    local avail
    mapfile -t avail < <(empty_workspaces)
    local need=$((${#groups[@]} - ${#targets[@]}))
    ((${#avail[@]} >= need)) || die "$ctx needs $need free workspace(s), ${#avail[@]} available"
    targets+=("${avail[@]:0:$need}")

    if ((DRY)); then
        local idx=0
        for g in "${groups[@]}"; do
            for entry in "${PLAN[@]}"; do
                [ "${entry%%|*}" = "$g" ] || continue
                entry=${entry#*|}
                printf 'ws %-2s  %3s%%  %s\n' "${targets[idx]}" "${entry%%|*}" "${entry#*|}"
            done
            idx=$((idx + 1))
        done
        return 0
    fi

    trap restore EXIT
    local idx=0
    for g in "${groups[@]}"; do
        local -a entries=()
        for entry in "${PLAN[@]}"; do
            [ "${entry%%|*}" = "$g" ] && entries+=("${entry#*|}")
        done
        layout_group "${targets[idx]}" "${entries[@]}"
        idx=$((idx + 1))
    done
    restore

    hdisp "hl.dsp.focus({ workspace = ${targets[0]} })"
    command -v notify-send >/dev/null && notify-send "$ctx session - $DESC"
}

main "$@"
