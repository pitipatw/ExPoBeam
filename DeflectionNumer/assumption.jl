"""
Assumptions
1. Plane sections before the load are plane after the load
    ***This might be not true for PixelFrame due to the fact that the section is cracked which no force/stress would keep it plane.

2. The stress in the unbonded tendon is constant
    ***This means there is no friction between the tendon and deviators (frictionless roller)

3. 



"""


Ec = 4700*sqrt(fc′)
fr = 0.63*sqrt(fc′)

#post-tnsioning tendons by Menegotto and Pinto
