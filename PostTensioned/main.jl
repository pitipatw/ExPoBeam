#This file is derived from Grasshopper work in 4.450 Fall 2022 class. 
"""
To do 
1. get Centroid of a PixelFrame
Input a PixelFrame from Grasshopper
with Centroid as a function of "c" -> Excel
    also with inertia.
    Save them as separate files. 
    c_to_A and Centroid of A
    c_to_I

get ARM of the section.
"""

using Printf

#Concrete information
fc′ = 133.7
ρc = 2400.0 # concrete density
Ec = 4700.0*fc′^0.5 # concrete modulus of elasticity

#PT steel information
rps = 20.0 #[mm]
aps = pi*rps^2 #[mm^2]
fpe = 119.753 #[MPa]
e   = 0.77 #[-]
ep = 200_000.0 #[MPa]

"""
need work
"""
#PixelFrame Section properties
ap = 1000.0 #Total concrete area
shear_ratio = 0.3 #ratio of the section that resists shear to the total area.
d = 500.0 #beamdepth
#Serviceability parameters
dl = 0.007 #[N/mm2]
ll = 0.0048 #[N/mm2]
baydepth = 2000.0 #[mm]
l = 1500.0 #[mm]

#Fiber information
fR1 = 4.0
fR3 = 3.5

#Load information
w_d = dl*baydepth #[N/mm]
w_l = ll*baydepth #[N/mm]
w_tot = w_d + w_l #[N/mm]

mdead = w_d*l^2/8.0 #[Nmm]
mtotal = w_tot*l^2/8.0 #[Nmm]



#Calculation starts here.


#Pure Compression Capacity
ccn = 0.85*fc′*ap
pn = (ccn - (fpe - 0.003*ep)*aps) / 1000 #[kN]
pu = 0.65*0.8*pn #[kN]
@printf "The pure compression capacity is %.3f [kN]\n" pu

#Pure Moment Capacity
acomp = aps*fps/(0.85*fc′)
arm = d - c
mn_steel = aps*fps*arm/1e6

mn_conc = 0.0 #***NEED WORK***
#check if mn_conc is possible.

Mu = Φ(ϵ)*mn_steel #[kNmm]

@printf "The pure moment capacity is %.3f [kNmm]\n" Mu

#Shear Calculation
ashear = ap*shear_ratio
ρs = aps/ashear
k = clamp(sqrt(200.0/d),0,2.)
fFts = 0.45*fR1
wu = 1.5
CMOD3 = 1.5
NEd = ptforce
σcp = 
fFtu = Get_fFtu(fFts, wu, CMOD3, fR1, fR3)