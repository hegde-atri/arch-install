#!/bin/sh

source="$1"
target="$2"

# Extract the shebang from README.org and write it to new file.
grep ':shebang' "$source" | cut -d \" -f2 > "$target"

# Extract all '#+begin/end_src' blocks from README.org and append them to file;
awk '/^#\+begin_src/{flag=1;next}/^#\+end_src/{flag=0;print ""}flag' \
    "$source" | head -n -1 >> "$target"

# Make the new file executable
chmod +x "$target"
