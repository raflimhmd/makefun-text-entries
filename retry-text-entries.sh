#!/bin/bash
# retry-text-entries.sh - kit baru + repo bersih + submit ulang dengan --keypair (bounty ber-escrow)
set -u
REPO=/opt/makefun/textentries
KITDIR=/opt/makefun/newsimg/kit
KEYPAIR=/opt/makefun/kit/makefun-keypair.json
URL=https://github.com/raflimhmd/makefun-text-entries
HV=$(hermes --version 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)

echo "== 1. ambil kit level terbaru"
cd "$KITDIR" && curl -sSL "https://make.fun/c/news-image-20261125/kit" -o k46.tar.gz && tar xzf k46.tar.gz && echo "  kit: $(ls -d news-image-20261125-kit) ok"
CLI="$KITDIR/news-image-20261125-kit/cli/makefun.mjs"

echo "== 2. keypair ada?"
[ -s "$KEYPAIR" ] && echo "  ada: $KEYPAIR ($(stat -c%s "$KEYPAIR") byte)" || { echo "  TIDAK ADA - stop"; exit 1; }

echo "== 3. bersihin repo (out/, bundle) + commit + push"
cd "$REPO"
printf 'out/\n*.tar.gz\n' > .gitignore
git add -A
git -c user.email=raflimhmd@users.noreply.github.com -c user.name=raflimhmd commit -qm "Ignore scratch output and transcript bundles" 2>&1 | tail -2
git push -q origin main 2>&1 | tail -2
echo "  HEAD=$(git rev-parse --short HEAD)  dirty=$(git status --porcelain | wc -l) file"

echo "== 4. bundle ulang + submit dengan keypair"
do_entry() {
    local slug="$1" sid="$2" sha="$3" label="$4"
    echo "---- $slug"
    local bundle="$REPO/b_$slug.tar.gz"
    ( cd "$KITDIR/news-image-20261125-kit" && node "$CLI" bundle --repo "$REPO" --out "$bundle" \
        --session /root/.hermes/state.db --session-id "$sid" \
        --mcp none --harness "Hermes Agent" --harness-version "$HV" \
        --provider deepseek --model deepseek-v4.1-flash:free --effort default \
        --notes "$label" 2>&1 | tail -3 )
    [ -s "$bundle" ] || { echo "   GAGAL bundle"; return 1; }
    ( cd "$KITDIR/news-image-20261125-kit" && node "$CLI" submit --competition "$slug" \
        --repo-url "$URL" --commit "$sha" --bundle "$bundle" --keypair "$KEYPAIR" 2>&1 | tail -16 )
}

do_entry "u-ronigrv-your-human-in-one-word-e4569a1c" \
         "local-1a6021bcd65269747dd58c3773903600d346eaa7b94f2687e381eb54ed460bf4" \
         "d178000b9a39ee142807e665dcb2b45bd6c7f679" "one word for the human you work for"

do_entry "u-rama-melon-make-the-ai-judge-laugh-302d0825" \
         "local-155940180616a144aacf0822c4e9b5147a56a291fa849c6abea7f9d56530ce5e" \
         "8169d959f39015891a755353c96b935cde2826f8" "one-line office joke"

echo "== selesai $(date +%H:%M:%S)"