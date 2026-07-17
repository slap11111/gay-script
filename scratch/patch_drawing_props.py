import os

def patch_file(filepath):
    print(f"Patching {filepath}...")
    if not os.path.exists(filepath):
        print(f"File {filepath} not found!")
        return False
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Apply exact drawing properties from user's code
    target_drawing = """\t\tif not data.drawingHealthOutline then
\t\t\tdata.drawingHealthOutline = NAmanage.DrawingCreateSquare(Color3.new(0, 0, 0), 0, {
\t\t\t\tfilled = true;
\t\t\t\tthickness = 1;
\t\t\t})
\t\tend
\t\tif not data.drawingHealthBar then
\t\t\tdata.drawingHealthBar = NAmanage.DrawingCreateSquare(Color3.new(0, 1, 0), 0, {
\t\t\t\tfilled = true;
\t\t\t\tthickness = 1;
\t\t\t})
\t\tend"""

    replacement_drawing = """\t\tif not data.drawingHealthOutline then
\t\t\tpcall(function()
\t\t\t\tlocal sq = Drawing.new("Square")
\t\t\t\tsq.Visible = false
\t\t\t\tsq.Transparency = 1
\t\t\t\tsq.Thickness = 0
\t\t\t\tsq.Filled = true
\t\t\t\tsq.Color = Color3.new(0, 0, 0)
\t\t\t\tsq.ZIndex = 1
\t\t\t\tdata.drawingHealthOutline = sq
\t\t\tend)
\t\tend
\t\tif not data.drawingHealthBar then
\t\t\tpcall(function()
\t\t\t\tlocal sq = Drawing.new("Square")
\t\t\t\tsq.Visible = false
\t\t\t\tsq.Transparency = 1
\t\t\t\tsq.Thickness = 0
\t\t\t\tsq.Filled = true
\t\t\t\tsq.Color = Color3.new(0, 1, 0)
\t\t\t\tsq.ZIndex = 2
\t\t\t\tdata.drawingHealthBar = sq
\t\t\tend)
\t\tend"""

    if target_drawing in content:
        content = content.replace(target_drawing, replacement_drawing, 1)
        print("-> Applied user's exact Drawing.new properties with ZIndex")
    else:
        target_drawing_rn = target_drawing.replace('\n', '\r\n')
        replacement_drawing_rn = replacement_drawing.replace('\n', '\r\n')
        if target_drawing_rn in content:
            content = content.replace(target_drawing_rn, replacement_drawing_rn, 1)
            print("-> Applied user's exact Drawing.new properties with ZIndex (CRLF)")
        else:
            print("-> Target drawing objects not found")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Done patching.")
    return True

patch_file('Source.lua')
patch_file('NA testing.lua')
