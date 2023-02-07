local CoolUtil = {}

function CoolUtil.lerp(a, b, t)
    return a + (b - a) * t
end

function CoolUtil.clamp(x, min, max)
    return math.min(math.max(x, min), max)
end

return CoolUtil