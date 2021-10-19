if !has('python3')
  echo "Error: Required vim compiled with +python3"
  finish
endif

function! WrapString() range

python3 << EOF

import vim

(l1, c1) = vim.current.buffer.mark("<")
(l2, c2) = vim.current.buffer.mark(">")

text = ""
shift = vim.current.buffer[l1 - 1].find('"')

is_fix_str = vim.current.buffer[l1 - 1].find("8=FIX") > 0

print(is_fix_str)

for l in range(l1, l2 + 1):
   if is_fix_str:
      text += vim.current.buffer[l - 1].strip(" ")
   else:
      text += "{} ".format(vim.current.buffer[l - 1].strip("\" "))

if is_fix_str:
   text = text.replace('\"\"', '').replace('=\"M', '=\" M').lstrip('\"')

tokens = text.split(';') if is_fix_str else text.split(' ')

lines=[]

line=''

for t in tokens:
   if not len(t):
      continue
   if len(line) == 0:
      line = ' ' * shift + '\"'
   if len(line) + len(t) > 118:
      line += '"'
      lines.append(line)
      line = ' ' * shift + '\"' + t + (';' if is_fix_str else ' ')
   else:
      line += "{}{}".format(t, ';' if is_fix_str else ' ')

if len(line):
   lines.append(line.rstrip(" "))

i = 0
for l in range(l1, l2 + 1):
   if i < len(lines):
      vim.current.buffer[l - 1] = lines[i].rstrip(" ")
      i += 1
   else:
      del vim.current.buffer[l - 1]

k = l2
for j in range(i, len(lines)):
   vim.current.buffer.append(lines[j], k)
   k += 1

EOF

endfunction
