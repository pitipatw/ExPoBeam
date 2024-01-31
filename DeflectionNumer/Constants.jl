const fc′ = 28.0
const δϵc = 100e-6
const Ec = 4700*sqrt(fc′)
const fr = 0.63*sqrt(fc′)
const Es = 200_000

println("####################
Constants.jl defines the following:
 Concrete's properties
    fc′ : $fc′ Concrete strength [MPa]
    δϵc : $δϵc Strain increment for concrete [-]
    fr  : $fr Tensile strength of concrete [MPa]
    Ec  : $Ec Modulus of elasticity of concrete [MPa]
 Steel's properties
    Es  : $Es Modulus of elasticity of steel [MPa]")


