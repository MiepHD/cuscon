import sys
import re

xml_path = sys.argv[1]
version_name = sys.argv[2]
today_date = sys.argv[3]
added = sys.argv[4]
updated = sys.argv[5]
fixed = sys.argv[6]
improved = sys.argv[7]

with open(xml_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(
    r'(<string name="changelog_date">)[^<]+(</string>)',
    rf'\g<1>{today_date}\g<2>',
    content
)

version_tag = f"<item>{version_name}:</item>"

updates = [
    ("Added", added),
    ("Updated", updated),
    ("Fixed", fixed),
    ("Improved", improved)
]

if version_tag in content:
    for category, items in updates:
        if not items:
            continue
        
        pattern = rf'({re.escape(version_tag)}[\s\S]*?<item>{category}\s+)([^<]+)(</item>)'
        match = re.search(pattern, content)
        
        if match:
            content = re.sub(
                pattern,
                rf'\g<1>\g<2>, {items}\g<3>',
                content,
                count=1
            )
        else:
            new_line = f"        <item>{category} {items}</item>\n"
            content = content.replace(version_tag, f"{version_tag}\n{new_line}", 1)
            
    print(f"  [✓] Expanded existing entry for v{version_name} in changelog.xml.")

else:
    new_version_lines = [f"        <item>{version_name}:</item>"]
    for category, items in updates:
        if items:
            new_version_lines.append(f"        <item>{category} {items}</item>")
    
    insert_block = "\n" + "\n".join(new_version_lines) + "\n"
    content = re.sub(
        r'(<string-array name="changelog">)',
        rf'\1{insert_block}',
        content,
        count=1
    )
    print(f"  [✓] Created new entry for v{version_name} in changelog.xml.")

with open(xml_path, 'w', encoding='utf-8') as f:
    f.write(content)