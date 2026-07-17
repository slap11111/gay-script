import os

def patch_file(filepath):
    print(f"Patching {filepath}...")
    if not os.path.exists(filepath):
        print(f"File {filepath} not found!")
        return False
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Replacement 5: ESP_HideDrawingElements
    target_5 = """\tif type(data.drawingCornerOutlineLines) == "table" then
\t\tfor i = 1, #data.drawingCornerOutlineLines do
\t\t\thide(data.drawingCornerOutlineLines[i])
\t\tend
\tend
end"""

    replacement_5 = """\tif type(data.drawingCornerOutlineLines) == "table" then
\t\tfor i = 1, #data.drawingCornerOutlineLines do
\t\t\thide(data.drawingCornerOutlineLines[i])
\t\tend
\tend
\thide(data.drawingHealthOutline)
\thide(data.drawingHealthBar)
end"""

    if target_5 in content:
        content = content.replace(target_5, replacement_5, 1)
        print("-> Applied Replacement 5 (HideDrawingElements)")
    else:
        target_5_rn = target_5.replace('\n', '\r\n')
        replacement_5_rn = replacement_5.replace('\n', '\r\n')
        if target_5_rn in content:
            content = content.replace(target_5_rn, replacement_5_rn, 1)
            print("-> Applied Replacement 5 (HideDrawingElements, CRLF)")
        else:
            print("-> Replacement 5 already applied or target not found")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Done patching.")
    return True

patch_file('Source.lua')
patch_file('NA testing.lua')
