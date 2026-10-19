#!/usr/bin/env bash
# Archives the "live" (actively re-fetched) subfolders of ~/ben/backup into a
# timestamped tar.gz under ~/ben/backup/archive, with a basic sanity check on
# file sizes (catches empty/truncated exports before they get archived) and
# rotation that keeps only the last N archives.
#
# Does NOT touch the static one-time dumps (phone, reddit, bookmarks,
# tandem_json) — those aren't refreshed by any script, so re-archiving them
# every run would be wasteful. Add a folder name to SOURCES below once a
# script actively maintains it (e.g. "maps" once the Maps-pins exporter exists).
set -euo pipefail

BACKUP_ROOT="/home/meow/ben/backup"
ARCHIVE_DIR="${BACKUP_ROOT}/archive"
SIZES_FILE="${ARCHIVE_DIR}/.last_sizes.tsv"
KEEP=4
# Folders actually maintained by a fetch script. Only existing ones are archived.
SOURCES=(calendar maps)

mkdir -p "$ARCHIVE_DIR"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE_FILE="${ARCHIVE_DIR}/backup_${TIMESTAMP}.tar.gz"

present=()
for s in "${SOURCES[@]}"; do
    if [ -d "${BACKUP_ROOT}/${s}" ]; then
        present+=("$s")
    fi
done

if [ "${#present[@]}" -eq 0 ]; then
    echo "No live backup folders found under ${BACKUP_ROOT} (looked for: ${SOURCES[*]}); nothing to archive." >&2
    exit 1
fi

echo "Archiving: ${present[*]}"

# --- Size sanity check -------------------------------------------------
# Flags empty files, and files that shrank a lot vs the previous run
# (manifest is a simple "path<TAB>size" file, one entry per archived file).
new_sizes="$(mktemp)"
trap 'rm -f "$new_sizes"' EXIT

warnings=0
while IFS= read -r -d '' f; do
    size=$(stat -c%s "$f")
    rel="${f#"$BACKUP_ROOT"/}"
    printf '%s\t%s\n' "$rel" "$size" >> "$new_sizes"
    if [ "$size" -eq 0 ]; then
        echo "WARNING: ${rel} is 0 bytes" >&2
        warnings=$((warnings + 1))
    fi
done < <(for s in "${present[@]}"; do find "${BACKUP_ROOT}/${s}" -type f -print0; done)

if [ -f "$SIZES_FILE" ]; then
    while IFS=$'\t' read -r rel old_size; do
        new_size=$(awk -F'\t' -v r="$rel" '$1==r {print $2}' "$new_sizes")
        if [ -n "$new_size" ] && [ "$old_size" -gt 0 ]; then
            # Warn if the file shrank by more than 50%.
            threshold=$((old_size / 2))
            if [ "$new_size" -lt "$threshold" ]; then
                echo "WARNING: ${rel} shrank from ${old_size} to ${new_size} bytes" >&2
                warnings=$((warnings + 1))
            fi
        fi
    done < "$SIZES_FILE"
fi

mv "$new_sizes" "$SIZES_FILE"
trap - EXIT

if [ "$warnings" -gt 0 ]; then
    echo "Proceeding with archive despite ${warnings} size warning(s) above." >&2
fi

# --- Archive ------------------------------------------------------------
tar -czf "$ARCHIVE_FILE" -C "$BACKUP_ROOT" "${present[@]}"
echo "Created ${ARCHIVE_FILE} ($(du -h "$ARCHIVE_FILE" | cut -f1))"

# --- Rotate: keep only the last $KEEP archives --------------------------
mapfile -t old_archives < <(ls -1t "${ARCHIVE_DIR}"/backup_*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)))
for old in "${old_archives[@]:-}"; do
    [ -n "$old" ] || continue
    echo "Removing old archive: $old"
    rm -f "$old"
done

echo "Done. $(ls -1 "${ARCHIVE_DIR}"/backup_*.tar.gz 2>/dev/null | wc -l) archive(s) kept."
