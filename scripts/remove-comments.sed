# Deletes comments and collapses whitespace in ##-packages files

# Append (N)ext line to buffer
# if (!)not ($)buffer is EOF, (b)ranch to (:)label loop
:loop
N
$ !b loop

# Buffer is "line1\nline2\n...lineN", del comments and collapse whitespace
s/#[^\n]*//g
s/[[:space:]]\{1,\}/ /g
