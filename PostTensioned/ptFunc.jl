function β1(fc′::Float64)
    out = clamp(0.85 - 0.05*(fc′-28.0)/7, 0.65, 0.85)
    return out 
end


function Φ(ϵ::Float64)
    out = clamp(0.65 + 0.25*(ϵ-0.002)/0.003, 0.65, 0.90)
    return out
end

function ρₚ(Aps::Float64, Ac::Float64)
    out = Aps/Ac
    return out
end

"""
fpy is based on ASTM A421
"""
function fps(fpe::Float64, fc′::Float64,ρₚ::Float64; fpy::Float64 = 1300.0)
    out = minimum(fpe + 70.0 + fc′/(100.0*ρₚ), fpe + 420.0, fpy)
    return out
end

