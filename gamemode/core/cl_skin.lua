local blur = Material( "pp/blurscreen" )


local surface = surface
local draw = draw
local Color = Color

SKIN = {}

SKIN.PrintName 		= "impulse"
SKIN.Author 		= "TheVingard"
SKIN.DermaVersion	= 1
SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)
SKIN.Colours.Window.TitleActive = Color(0, 0, 0)
SKIN.Colours.Window.TitleInactive = Color(255, 255, 255)
 
SKIN.Colours.Button.Normal = Color(255, 255, 255)
SKIN.Colours.Button.Hover = Color(255, 255, 255)
SKIN.Colours.Button.Down = Color(180, 180, 180)
SKIN.Colours.Button.Disabled = Color(0, 0, 0, 100)

function SKIN:PaintFrame(panel, w, h)
    impulse.blur( panel, 10, 20, 255 )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) ) -- this is the body of the frame
    draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) ) -- this is the "top bar" of the derma frame
end



function SKIN:PaintButton(panel) -- button skin from ns edited
	if (panel:GetPaintBackground()) then
		local w, h = panel:GetWide(), panel:GetTall()
		local alpha = 150

    	if (panel:GetDisabled()) then
			alpha = 10
		elseif (panel.Depressed) then
			alpha = 190
		elseif (panel.Hovered) then
			alpha = 170
		end
		surface.SetDrawColor(46, 139, 232, alpha)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawOutlinedRect(0, 0, w, h)
		surface.SetDrawColor(180, 180, 180, 2)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	end
end

function SKIN:PaintWindowMinimizeButton( panel, w, h ) -- dont need these
    
end

function SKIN:PaintWindowMaximizeButton( panel, w, h )
    
end


function SKIN:DrawGenericBackground(x, y, w, h)
	surface.SetDrawColor(45, 90, 45, 240)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetDrawColor(100, 100, 100, 25)
	surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2)
end

derma.DefineSkin("impulse", "Skin made by TheVingard. A nice new lick of paint for BMRP's interfaces.", SKIN)
derma.RefreshSkins()