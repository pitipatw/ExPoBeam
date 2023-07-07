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
function Fps(fpe::Float64, fc′::Float64,ρₚ::Float64; fpy::Float64 = 1300.0)
    out = min(fpe + 70.0 + fc′/(100.0*ρₚ), fpe + 420.0, fpy)
    return out
end

function Get_fFtu(fFts::Float64, wu::Float64, CMOD3::Float64,fR1::Float64, fR3::Float64)
    out = fFts - wu/CMOD3*(fFts-0.5*fR3 + 0.2*fR1)
    return out 
end
"""
fFtuk = fFtu
fck = fc′
"""
function V(ρs::Float64, fck::Float64, fFtuk::Float64, γc::Float64, scp::Float64, k::Float64)
    out = 0.18/γc*k*(100.0*ρs *(1.0 + 7.5*fFtuk/fctk)* fck)^(1/3)+0.15*scp
return out/1000.
