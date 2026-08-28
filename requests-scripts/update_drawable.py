import sys
import re

drawable_path = sys.argv[1]
changed_ids = sys.argv[2].split() if len(sys.argv) > 2 and sys.argv[2] else []
drawable_lines_raw = sys.argv[3].strip().split('\n') if len(sys.argv) > 3 and sys.argv[3].strip() else []
was_version_bumped = sys.argv[4].lower() == "true" if len(sys.argv) > 4 else False

id_to_item = {}
for line in drawable_lines_raw:
    line = line.strip()
    if not line:
        continue
    match = re.search(r'drawable="([^"]+)"', line)
    if match:
        icon_id = match.group(1)
        id_to_item[icon_id] = line

with open(drawable_path, 'r', encoding='utf-8') as f:
    content = f.read()

def get_category_title(item_str, icon_id):
    name_match = re.search(r'name="([^"]+)"', item_str)
    if name_match:
        target_str = name_match.group(1).strip()
    else:
        target_str = icon_id[1:] if icon_id.startswith('_') else icon_id

    if not target_str:
        return "#"

    first_char = target_str[0]
    
    if first_char.isdigit():
        return "#"
    elif first_char.isalpha():
        return first_char.upper()
    else:
        return "#"

# 1. New Icons leeren, FALLS die Version erhöht wurde (bevor die neuen reinkommen)
if was_version_bumped:
    content = re.sub(
        r'(<category title="New Icons"\s*/?>)([\s\S]*?)(?=<category title=|\s*</resources>)',
        r'\1\n',
        content,
        count=1
    )
    print("  [✓] Cleared 'New Icons' category (version incremented).")

# 2. New Icons befüllen (Geänderte & Neue Icons einfügen)
for icon_id in changed_ids:
    item_str = id_to_item.get(icon_id, f'<item drawable="{icon_id}"/>')
    
    pattern_exist = rf'(<category title="New Icons"\s*/?>[\s\S]*?)({re.escape(item_str)}|drawable="{re.escape(icon_id)}")(.*?<category)'
    if not re.search(pattern_exist, content):
        cat_pattern = r'(<category title="New Icons"\s*/?>)'
        content = re.sub(cat_pattern, rf'\1\n    {item_str}', content, count=1)

# 3. Neue/Fehlende Icons in ihre Buchstabensektion (#, A-Z) einfügen
for icon_id in changed_ids:
    item_str = id_to_item.get(icon_id, f'<item drawable="{icon_id}"/>')
    clean_id = icon_id[1:] if icon_id.startswith('_') else icon_id
    
    first_letter_cat = re.search(r'<category title="(#|[A-Z])"\s*/?>', content)
    already_in_letters = False
    if first_letter_cat:
        rest_content = content[first_letter_cat.start():]
        if item_str in rest_content or f'drawable="{icon_id}"' in rest_content or f'drawable="{clean_id}"' in rest_content:
            already_in_letters = True
            
    if not already_in_letters:
        target_cat = get_category_title(item_str, icon_id)
        cat_tag = f'<category title="{target_cat}"/>'
        
        if cat_tag in content:
            content = content.replace(cat_tag, f'{cat_tag}\n    {item_str}', 1)
        else:
            new_cat_block = f'    {cat_tag}\n    {item_str}\n'
            content = content.replace('</resources>', f'{new_cat_block}</resources>', 1)

with open(drawable_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("  [✓] 'drawable.xml' updated successfully.")