return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("city/newGf")), -- Do not add the .png extension
	{
		{x = 0, y = 0, width = 531, height = 753, offsetX = 0, offsetY = -5, offsetWidth = 531, offsetHeight = 758}, -- 1: left0000
		{x = 531, y = 0, width = 531, height = 753, offsetX = 0, offsetY = -5, offsetWidth = 531, offsetHeight = 758}, -- 2: left0001
		{x = 1062, y = 0, width = 508, height = 745, offsetX = -22, offsetY = -13, offsetWidth = 531, offsetHeight = 758}, -- 3: left0002
		{x = 1570, y = 0, width = 496, height = 750, offsetX = -30, offsetY = -6, offsetWidth = 531, offsetHeight = 758}, -- 4: left0003
		{x = 2066, y = 0, width = 496, height = 751, offsetX = -29, offsetY = -4, offsetWidth = 531, offsetHeight = 758}, -- 5: left0004
		{x = 2562, y = 0, width = 496, height = 754, offsetX = -29, offsetY = 0, offsetWidth = 531, offsetHeight = 758}, -- 6: left0005
		{x = 3058, y = 0, width = 496, height = 754, offsetX = -29, offsetY = 0, offsetWidth = 531, offsetHeight = 758}, -- 7: left0006
		{x = 0, y = 754, width = 556, height = 777, offsetX = -40, offsetY = 0, offsetWidth = 556, offsetHeight = 786}, -- 8: right0000
		{x = 556, y = 754, width = 543, height = 775, offsetX = -42, offsetY = 7, offsetWidth = 556, offsetHeight = 786}, -- 9: right0001
		{x = 1099, y = 754, width = 529, height = 771, offsetX = -43, offsetY = 9, offsetWidth = 556, offsetHeight = 786}, -- 10: right0002
		{x = 1628, y = 754, width = 521, height = 766, offsetX = -43, offsetY = 3, offsetWidth = 556, offsetHeight = 786}, -- 11: right0003
		{x = 2149, y = 754, width = 514, height = 765, offsetX = -43, offsetY = 1, offsetWidth = 556, offsetHeight = 786}, -- 12: right0004
		{x = 2663, y = 754, width = 514, height = 765, offsetX = -43, offsetY = 1, offsetWidth = 556, offsetHeight = 786} -- 13: right0005
	},
	{
		["idle"] = {start = 1, stop = 13, speed = 0, offsetX = 0, offsetY = 0}
	},
	"idle", -- set to default animation
	false -- If the sprite repeats
)
