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

Notes
Shaer strength depends on the current applied axial force
Therefore, shear will depend on the axial and will decresase if the applied axial force decreases.
"""


using Printf

include("pixelgeo.jl")
include("ptFunc.jl")

begin
#Concrete information
fc′ = 133.7
# ============= 
ftension = 0.17*sqrt(fc′)
ρc = 2400.0 # concrete density
Ec = 4700.0*fc′^0.5 # concrete modulus of elasticity

#PT steel information
rps = 60.0 #[mm] radius of the strand
aps = 2* pi*rps^2 #[mm^2] area of the strand X 2 (2 sides)
fpe = 119.753 #[MPa] effective prestress stress (after losses)
e   = 0.77 #[-] eccentricity % of L (leg) from centroid (0,0)
steelpos = -L*e #[mm] position of the steel from the centroid of the section, y coordinate.
Ep = 200_000.0 #[MPa] modulus of elasticity of the strand


#Shear information
shear_ratio = 0.3 #ratio of the section that resists shear to the total area.

#Fiber information
fR1 = 4.0
fR3 = 3.5

#Serviceability parameters
# bay sizes
dl = 0.007 #[N/mm2] pressure dead load
ll = 0.0048 #[N/mm2] pressure live load
baydepth = 2000.0 #[mm] bay depth
l = 1500.0 #[mm] length of the beam

#Load information
w_d = dl*baydepth #[N/mm] uniformly distributed dead load
w_l = ll*baydepth #[N/mm] uniformly distributed live load
w_tot = w_d + w_l #[N/mm] total uniformly distributed load

mdead = w_d*l^2/8.0 #[Nmm] moment from the dead load
mtotal = w_tot*l^2/8.0 #[Nmm] moment from the total load

end
"""
need work
"""
#PixelFrame Section properties
L = 300.0; # [mm] length of the pixel frame
t = 10.0; # [mm] thickness of the pixel frame
Lc = 30.0; # [mm] length of the straight.
dx = 0.1; 
dy = 0.1;
pts = fullpixel(L, t, Lc);
ytop = maximum(pts[:,2])
ybot = minimum(pts[:,2])

gridpts = fillpoints(pts, dx, dy)
pixelpts = gridpts[pointsinpixel(pts, gridpts),:]

ac = size(pixelpts)[1]*dx*dy #[mm^2] #Total concrete area
d = ytop - ybot #beamdepth
ds = ytop - steelpos #depth of the steel from the top of the beam.

#Calculation starts here.


#Pure Compression Capacity
ccn = 0.85*fc′*ac
#need a justification on 0.003 Ep
pn = (ccn - (fpe - 0.003*Ep)*aps) / 1000 #[kN]
pu = 0.65*0.8*pn #[kN]
ptforce = pu #[kN]
@printf "The pure compression capacity is %.3f [kN]\n" pu
println("#"^50)

#Pure Moment Capacity

#From ACI318M-19 Table: 20.3.2.4.1
ρ = aps/ac #reinforcement ratio (Asteel/Aconcrete)
fps1 = fpe + 70+ fc′/(100*ρ) #
fps2 = fpe + 420
fps3 = 1300.0 #Yield str of steel from ASTM A421
fps  = minimum([fps1, fps2, fps3])

#concrete compression area balanced with steel tension force.
acomp = aps*fps/(0.85*fc′)
#get the depth of the compression area, in the form of y coordinate.
depth, chk = getdepth(pixelpts, acomp, [ytop,ybot])

#set of points that represent the compression area.
ptscomp = pixelpts[chk,:]

#calculate the moment arm.
#get cgy of the compression area.
~, cgcomp = secprop(ptscomp,0.0)
#moment arm of the section is the distance between the centroid of the compression area and the steel.
arm = cgcomp - steelpos 
mn_steel = aps*fps*arm/1e6 #[kNm]

#Recheck with concrete.
#check compression strain, make sure it's not more than 0.003
c = depth;
ϵs = fps/Ep;
ϵc = c*ϵs/(ds - c);

if ϵc > 0.003 
    println("Compression strain is more than 0.003")
    println("Please rework with the section")
end


mu = Φ(ϵs)*mn_steel #[kNmm]

@printf "The pure moment capacity is %.3f [kNm]\n" mu
println("#"^50)




#Shear Calculation
ashear = ac*shear_ratio;
fctk = ftension;
ρs = aps/ashear;
k = clamp(sqrt(200.0/d),0,2.);
fFts = 0.45*fR1;
wu = 1.5;
CMOD3 = 1.5;
ned = ptforce;# can be different
σcp1 = ned/ac;
σcp2 = 0.2*fc′;
σcp = clamp(σcp1, 0.0, σcp2);
fFtu = get_fFtu(fFts, wu, CMOD3, fR1, fR3);
vn = ashear*get_v(ρs, fc′,fctk, fFtu, 1.0, σcp1, k) ;#kN
vu = 0.75*vn ;

println("#"^50)
@printf "The shear capacity is %.3f [kN]\n" vu


#Constraint check
#Deflection limit
#get from the march test model.

δmid = 0.5 #(will have to work on this)

δlimit = l/240.0 #[mm]

#first constraint, deflection limit (1)
c1 = δlimit > δmid 

#second constraint, stress limit
tenlim = -0.6*sqrt(fc′)
comlim = 0.25*sqrt(fc′)

#Initial (Post tensioning) stage (2)
#tensionlimit
ftopinit = -pi/ac + pi*e/st - mdead/st

c2t = ftopinit <= 1
#compression limit
fbotinit = -pi/ac - pi*e/st + mdead/sb
c2c = fbotinit <= somenumber

#Service stage (3)
#compression limit
ftopservice = -pi/ac + pi*e/st - mt/st
c3 = 