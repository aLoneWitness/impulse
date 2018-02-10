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

surface.CreateFont("Impulse-ChatSmall", {
	font = "Arial",
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
