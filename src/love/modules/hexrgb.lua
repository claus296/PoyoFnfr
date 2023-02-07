local hexrgb = {}

function hexrgb.hex2rgb(hex)
  hex = hex:gsub("#","") -- remove the #
  local r = hex:sub(1,2) 
  local g = hex:sub(3,4)
  local b = hex:sub(5,6)

  hexR = tonumber("0x".. r)
  hexG = tonumber("0x".. g)
  hexB = tonumber("0x".. b)
  return {hexR/255, hexG/255, hexB/255}
  
end

function hexrgb.rgb2hex(r,g,b)
  str = string.format("#%02x%02x%02x", r*255, g*255, b*255)
  return string.upper(str)
end

return hexrgb