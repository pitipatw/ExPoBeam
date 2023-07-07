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
"""
Notes
Shaer strength depends on the current applied axial force
Therefore, shear will depend on the axial and will decresase if the applied axial force decreases.
"""


using Printf

#Concrete information
fc′ = 133.7
ftension = 0.17*sqrt(fc′)
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
ac = 1000.0 #Total concrete area
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
ptforce = pu #[kN]
@printf "The pure compression capacity is %.3f [kN]\n" pu

#Pure Moment Capacity
fps  =Fps
acomp = aps*fps/(0.85*fc′)
arm = d - c
mn_steel = aps*fps*arm/1e6

mn_conc = 0.0 #***NEED WORK***
#check if mn_conc is possible.

mu = Φ(ϵ)*mn_steel #[kNmm]

@printf "The pure moment capacity is %.3f [kNmm]\n" mu

#Shear Calculation
ashear = ap*shear_ratio
fctk = ftension
ρs = aps/ashear
k = clamp(sqrt(200.0/d),0,2.)
fFts = 0.45*fR1
wu = 1.5
CMOD3 = 1.5
ned = ptforce
σcp1 = ned/ac
σcp2 = 0.2*fc′
σcp = clamp(σcp1, 0.0, σcp2)
fFtu = get_fFtu(fFts, wu, CMOD3, fR1, fR3)
vn = ashear*get_v(ρs, fc′,fctk, fFtu, 1.0, σcp1, k) #kN
vu = 0.75*vn 

@printf "The shear capacity is %.3f [kN]\n" vu


#Constraint check
#Deflection limit
#get from the march test model.

δmid = 0.5 #(will have to work on this)

δlimit = l/240.0 #[mm]

#first constraint, deflection limit (1)
c1 = δlimit > δmid 

#second constraint, stress limit
#Initial (Post tensioning) stage (2)
#tensionlimit
ftopinit = -pi/ac + pi*e/st - mdead/st
c2t = ftopinit <= somenuber
#compression limit
fbotinit = -pi/ac - pi*e/st + mdead/sb
c2c = fbotinit <= somenumber

#Service stage (3)
#compression limit
ftopservice = -pi/ac + pi*e/st - mt/st
c3 = 