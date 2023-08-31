"""
Assumptions
1. Plane sections before the load are plane after the load
    ***This might be not true for PixelFrame due to the fact that the section is cracked which no force/stress would keep it plane.

2. The stress in the unbonded tendon is constant
    ***This means there is no friction between the tendon and deviators (frictionless roller)

3. 

"""
function show_assumptions()
    println("Assumptions: ")
    println("
    1. Planes remain planes (even after loads are applied)
    ***This might be not true for PixelFrame due to the fact that the section is cracked which there's no force/stress on the entire section to keep them in plane.

    2. The stress in the unbonded tendon is constant
    ***This means there is no friction between the tendon and deviators (frictionless roller)
    ")
end

show_assumptions()
#post-tnsioning tendons by Menegotto and Pinto
