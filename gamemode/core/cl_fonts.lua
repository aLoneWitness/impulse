-- Font's are still a bit squiffy, they will all be scaled properly soon. Also - please name none specific fonts 'Impulse-Elements<description>'

surface.CreateFont("Impulse-Elements18", {
	font = "Arial",
	size = 18,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements18-Shadow", {
	font = "Arial",
	size = 18,
	weight = 900,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements20-Shadow", {
	font = "Arial",
	size = 18,
	weight = 900,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-CharacterInfo", {
	font = "Arial",
	size = 34,
	weight = 900,
	antialias = true,
	shadow = true,
	outline = true
} )

surface.CreateFont("Impulse-CharacterInfo-NO", {
	font = "Arial",
	size = 34,
	weight = 900,
	antialias = true,
	shadow = true,
	outline = false
} )

surface.CreateFont("Impulse-Elements13", {
	font = "Arial",
	size = 18,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements23", {
	font = "Arial",
	size = 23,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements32", {
	font = "Arial",
	size = 32,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements48", {
	font = "Arial",
	size = 48,
	weight = 1000,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-ChatSmall", {
	font = "Arial",
	size = 16,
	weight = 700,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-ChatSmall-Radio", {
	font = "Consolas",
	size = ScreenScale(7),
	weight = 700,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-ChatMedium", {
	font = "Arial",
	size = ScreenScale(7),
	weight = 700,
	antialias = false,
	shadow = false,
} )

surface.CreateFont("Impulse-ChatLarge", {
	font = "Arial",
	size = ScreenScale(7),
	weight = 700,
	antialias = false,
	shadow = false,
} )

surface.CreateFont("Impulse-Ui-SmallFont", {
	font = "Arial",
	size = math.max(ScreenScale(6), 17),
	extended = true,
	weight = 500
})
