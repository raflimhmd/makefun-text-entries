#!/bin/bash
# submit-text-entries.sh - bangun + submit entry teks lewat session baru (aturan thinking_in_window)
set -u
REPO=/opt/makefun/textentries
KIT=/opt/makefun/newsimg/kit/news-image-20261125-kit
CLI="$KIT/cli/makefun.mjs"
URL=https://github.com/raflimhmd/makefun-text-entries
HV=$(hermes --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)

entry() {
    local slug="$1" text="$2" max="$3" msg="$4" label="$5"
    echo "########## $label ($slug)"
    local brief="Di repo /opt/makefun/textentries, kerjakan satu tugas kecil lalu commit.

1. Buka main.ts. Ganti nilai konstanta TEXT menjadi teks berikut, persis:
$text
   dan ganti MAX menjadi $max.
2. Jalankan: mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts && cat out/entry.txt
   Pastikan isinya teks itu dan panjangnya antara 1 dan $max karakter.
3. Commit: git add -A && git -c user.email=raflimhmd@users.noreply.github.com -c user.name=raflimhmd commit -m '$msg'
4. Jangan push. Jangan ubah file lain (LICENSE, README, .gitignore biarkan).
5. Lapor: sha commit, isi out/entry.txt, panjang karakternya."
    local out sid sha
    out=$(cd "$REPO" && hermes --in "$REPO" --yolo chat -q "$brief" 2>&1 | tail -50)
    sid=$(printf '%s' "$out" | grep -oE 'local-[a-f0-9]{64}' | tail -1)
    sha=$(git -C "$REPO" rev-parse HEAD)
    echo "  session=$sid  commit=$sha"
    [ -n "$sid" ] || { echo "  GAGAL: tidak dapat session id"; printf '%s\n' "$out" | tail -6; return 1; }

    git -C "$REPO" push -q origin main 2>&1 | tail -2
    echo "  push ok"

    local bundle="$REPO/b_$slug.tar.gz"
    ( cd "$KIT" && node "$CLI" bundle --repo "$REPO" --out "$bundle" \
        --session /root/.hermes/state.db --session-id "$sid" \
        --mcp none --harness "Hermes Agent" --harness-version "$HV" \
        --provider deepseek --model deepseek-v4.1-flash:free --effort default \
        --notes "$label" 2>&1 | tail -4 )
    [ -s "$bundle" ] || { echo "  GAGAL: bundle tidak ada"; return 1; }

    echo "  submit..."
    ( cd "$KIT" && node "$CLI" submit --competition "$slug" --repo-url "$URL" --commit "$sha" --bundle "$bundle" 2>&1 | tail -14 )
}

entry "u-ronigrv-your-human-in-one-word-e4569a1c" "Bottleneck" 30 "One word for your human: Bottleneck" "one word for the human you work for"
entry "u-rama-melon-make-the-ai-judge-laugh-302d0825" "I unmuted myself to sigh, and the whole call learned something about me." 200 "One line about office life" "one-line office joke"
echo "########## selesai $(date +%H:%M:%S)"