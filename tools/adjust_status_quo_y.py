import re
import sys
from pathlib import Path

file_path = Path(r"c:\Users\gabes\Documents\Paradox Interactive\Hearts of Iron IV\mod\NovumVGC\NovumVGC\common\national_focus\usa.txt")
start_id = 'USA_status_quo'
end_id = 'USA_political_reform'

text = file_path.read_text(encoding='utf-8')
start_idx = text.find('\nid = ' + start_id)
if start_idx == -1:
    # try without leading newline
    start_idx = text.find('id = ' + start_id)
if start_idx == -1:
    print('start id not found')
    sys.exit(1)
# find position of the next occurrence of '\nid = ' + end_id after start_idx
end_idx = text.find('\nid = ' + end_id, start_idx+1)
if end_idx == -1:
    end_idx = text.find('id = ' + end_id, start_idx+1)
if end_idx == -1:
    print('end id not found')
    sys.exit(1)

prefix = text[:start_idx]
block = text[start_idx:end_idx]
suffix = text[end_idx:]

# regex to find lines that contain 'y = <number>' capturing indentation
pattern = re.compile(r"^(?P<indent>\s*)y\s*=\s*(?P<num>-?\d+)(?P<tail>\s*)$", re.MULTILINE)

changes = []

def repl(m):
    orig = m.group(0)
    indent = m.group('indent')
    num = int(m.group('num'))
    newnum = num + 1
    new = f"{indent}y = {newnum}{m.group('tail')}"
    changes.append((orig, new))
    return new

new_block = pattern.sub(repl, block)

if not changes:
    print('No y= lines found in block; no changes made')
    sys.exit(0)

# backup
bak = file_path.with_suffix(file_path.suffix + '.bak')
file_path.replace(bak)
# write new file
new_text = prefix + new_block + suffix
file_path.write_text(new_text, encoding='utf-8')
print(f'Updated {len(changes)} y values between {start_id} and {end_id}. Backup at {bak}')
