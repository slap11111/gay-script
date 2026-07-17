import os

def patch_file(filepath):
    print(f"Patching {filepath}...")
    if not os.path.exists(filepath):
        print(f"File {filepath} not found!")
        return False
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Revert DrawingUpdateSquare to use NAgui.getInstanceViewportBounds
    target_drawing = """NAmanage.DrawingUpdateSquare = function(square, inst, color, fillTransparency, options)
	if not square then return false end
	local minX, minY, width, height = NAmanage.GetPreciseViewportBounds(inst)
	if not minX then
		pcall(function()
			square.Visible = false
		end)
		return true
	end
	local alpha = NAgui.toDrawingTransparency(fillTransparency or 0.7)
	local thickness = math.max(1, tonumber(options and options.thickness) or 1)"""

    replacement_drawing = """NAmanage.DrawingUpdateSquare = function(square, inst, color, fillTransparency, options)
	if not square then return false end
	local minX, minY, width, height = NAgui.getInstanceViewportBounds(inst)
	if not minX then
		pcall(function()
			square.Visible = false
		end)
		return true
	end
	local alpha = NAgui.toDrawingTransparency(fillTransparency or 0.7)
	local thickness = math.max(1, tonumber(options and options.thickness) or 1)"""

    if target_drawing in content:
        content = content.replace(target_drawing, replacement_drawing, 1)
        print("-> Fixed DrawingUpdateSquare to use getInstanceViewportBounds")
    else:
        target_drawing_rn = target_drawing.replace('\n', '\r\n')
        replacement_drawing_rn = replacement_drawing.replace('\n', '\r\n')
        if target_drawing_rn in content:
            content = content.replace(target_drawing_rn, replacement_drawing_rn, 1)
            print("-> Fixed DrawingUpdateSquare (CRLF)")
        else:
            print("-> DrawingUpdateSquare target not found")

    # 2. Update ESP_UpdateDrawingBox to use NAmanage.GetPreciseViewportBounds
    target_update_box = """NAmanage.ESP_UpdateDrawingBox = function(data, inst, color, fillTransparency)
	if not data then
		return false
	end
	local minX, minY, width, height = NAgui.getInstanceViewportBounds(inst)
	if not minX then
		NAmanage.ESP_HideDrawingElements(data)
		return true
	end"""

    replacement_update_box = """NAmanage.ESP_UpdateDrawingBox = function(data, inst, color, fillTransparency)
	if not data then
		return false
	end
	local minX, minY, width, height = NAmanage.GetPreciseViewportBounds(inst)
	if not minX then
		NAmanage.ESP_HideDrawingElements(data)
		return true
	end"""

    if target_update_box in content:
        content = content.replace(target_update_box, replacement_update_box, 1)
        print("-> Fixed ESP_UpdateDrawingBox to use GetPreciseViewportBounds")
    else:
        target_update_box_rn = target_update_box.replace('\n', '\r\n')
        replacement_update_box_rn = replacement_update_box.replace('\n', '\r\n')
        if target_update_box_rn in content:
            content = content.replace(target_update_box_rn, replacement_update_box_rn, 1)
            print("-> Fixed ESP_UpdateDrawingBox (CRLF)")
        else:
            print("-> ESP_UpdateDrawingBox target not found")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Done patching.")
    return True

patch_file('Source.lua')
patch_file('NA testing.lua')
