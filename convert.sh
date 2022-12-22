#!bin/sh

filename="$1"
[ -z "$1" ] && filename='archinstall-wayland'

# Extract the shebang from README.org and write it to new file.
grep ':shebang' README.org | cut -d \" -f2 > "$filename"

# Extract all '#+begin/end_src' blocks from README.org and append them to file;
awk '/^#\+begin_src/{flag=1;next}/^#\+end_src/{flag=0;print ""}flag' \
    README.org | head -n -1 >> "$filename"

# Make the new file executable
chmod +x "$filename" 
