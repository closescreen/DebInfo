module DebInfo


export debinfofun
debinfofun(on::Bool) = on ? (x...)->info(x...) : (x...)->nothing

export statinfofun
statinfofun(on::Bool) = on ? (x...)->info(x...) : (x...)->nothing




end # module