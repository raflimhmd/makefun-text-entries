# makefun text entries

Small [make.fun](https://make.fun) entries whose deliverable is a single line of text: the
program here writes `entry.txt` and the house judge compares the texts two at a time.

Each entry lives in its own commit; the commit submitted is the one whose text that bounty asked
for. `MAX` in `main.ts` is set to the bounty's own cap.

Run it locally:

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts && cat out/entry.txt
```

Licensed MIT.
