/*
Original Code by Joerg Scheuermann: https://www.thingiverse.com/Joerg
Original on Thingiverse: https://www.thingiverse.com/thing:8239

Clip module, Toothpick diameter Variable,
OpenSCAD/Thingiverse Customizer optimization,
Multicolor Modifier Block and extra comments
added by Gasol1n (Christian Riedl): https://www.gasol1n.com/
                                                        https://www.thingiverse.com/Gasolin

Licensed under CC BY-SA 3.0
https://creativecommons.org/licenses/by-sa/3.0/
*/

/* [Size] */
// Width of the Chain Link
width= 14;
// Length of the Chain Link
length=17;
// Height of the Chain Link
height=10;

/* [Hidden] */
// Hard cap on articulation angle to prevent links from locking or colliding
max_angle = 50;

/* [Angles] */
// Max angle the chain can bend downward (toward the base)
under_angle=0; // [50]
// Max angle the chain can bend upward (away from the base)
over_angle=30; // [50]

/* [Variant] */
// true: pivot pins point inward (female outer shell); false: pins point outward (male outer shell)
// Must alternate or match between linked pairs — mixing produces the male/female joint
inner_axis=0; // [1:true, 0:false]
// true: top is solid (no cable access slot or clip); false: open top for cable insertion
closed=0; // [1:true, 0:false]
// true: use snap-in clip to close the top; false: use a toothpick/pin through a drilled hole
// Only applies when closed=false. Clip is printed as a separate piece beside the link.
clip=1; // [1:true, 0:false]

/* [Further Settings] */
// Extra clearance on mating surfaces to account for FDM dimensional variance
tolerance = 0.2;
// Diameter of the toothpick or pin used to close the link (only used when clip=false)
toothpick = 2.1;
// Generate Modifier Block for Multicolor Stripe
multicolor_block=0; // [1:true, 0:false]
//Height of the Modifier (Multicolor) Block
mcb_height=2;

// Builds the outer shell of one link: a rectangular body with rounded cylindrical ends.
// The angular wedge cuts at each end shape the bending pocket so adjacent links can
// rotate up to `angle` degrees without the shells clashing.
module outline(width, length, height, radius, l1, angle)
{
	y_ofs = l1 / 2;
	t     = radius / 2;

	difference() {
		union() {
			translate([0, 0, height/2])    cube([width,l1,height], true);
			translate([0, -y_ofs, radius]) rotate([0, 90, 0]) cylinder(width, r = radius, center = true, $fs=0.5);
			translate([0,  y_ofs, radius]) rotate([0, 90, 0]) cylinder(width, r = radius, center = true, $fs=0.5);
			// Wedge extensions allow the rounded end to sweep through the bend angle without gap
			translate([0, -y_ofs, radius]) rotate([angle,     0, 0]) translate([0, -t, -t]) cube([width,radius,radius], true);
			translate([0,  y_ofs, radius]) rotate([360-angle, 0, 0]) translate([0,  t, -t]) cube([width,radius,radius], true);
		}
		// Trim the bottom flat so the printed part sits flush on the bed
		translate([0, 0, -(t/2)]) cube([width,length,t], true);
	}
}

// Tapered pivot pin — narrower at the tip so it self-aligns when pressing links together.
// The taper also provides a slight press-fit retention in the matching axis_hole.
module axis(x_ofs, y_ofs, z_ofs, length, radius)
{
	rad = (radius * 0.25);
	translate([x_ofs,y_ofs,z_ofs]) rotate([0, 90, 0]) cylinder(length+tolerance, r1 = rad*1.25, r2 = rad, center = true, $fs=0.25);
}

// Matching tapered socket for the pivot pin. Scaled up by tolerance so the pin slides in
// without friction but cannot rattle sideways during articulation.
module axis_hole(x_ofs, y_ofs, z_ofs, length, radius)
{
	rad = (radius * 0.25) * 1.25;
	translate([x_ofs,y_ofs,z_ofs]) rotate([0, 90, 0]) cylinder(length+tolerance, r1 = rad+tolerance, r2 = rad, center = true, $fs=0.25);
}

// Cuts the outer ear on one side of one link end.
// The ear receives (or provides) the pivot pin that joins two links.
// `inner_axis` flips whether this ear carries the pin or the socket — links must be
// printed with opposite inner_axis values to mate correctly.
module outcut0(width, radius, h1, thick, angle, inner_axis)
{
	w = (width - thick)/2;
	t = thick + tolerance/2;

	translate([w, 0, 0]) union() {
		difference() {
			union() {
				translate([0,0,h1/2]) cube([t,radius*2, h1], true);
				// Angular wedge mirrors the outline's sweep pocket on the ear geometry
				translate([0,0,h1]) rotate([angle, 0, 0]) translate([0,radius/2,0]) cube([t,radius,radius*2], true);
				translate([0,0,h1]) rotate([0, 90, 0]) cylinder(t, r = radius, center = true, $fs=0.5);
				if (inner_axis) {
					axis_hole(-(1.5*w), tolerance/2, h1,w,radius);
				}
			}
			if (!inner_axis) {
				axis(-(tolerance)/2, tolerance/2, h1,thick,radius);
			}
		}
	}
}
// Mirrors outcut0 to produce symmetric ears on both sides of the link end.
module outcut(width, radius, l1, h1, thick, angle, inner_axis)
{
	translate([0,l1/2,0]) union() {
		outcut0(width, radius, h1, thick, angle, inner_axis);
		mirror([1,0,0]) outcut0(width, radius, h1, thick, angle, inner_axis);
	}
}

// Cuts the inner fork at the opposite end of the link — the fork cradles the ears of
// the next link and carries the opposite half of the pivot joint (pin or socket,
// whichever outcut didn't provide).
module incut(width, radius, l1, h1, thick, angle, inner_axis)
{
	width2 = width - 2*(thick-tolerance);

	translate([0,-(l1/2),h1]) difference() {
		union() {
			translate([0,0,-(h1/2)]) cube([width2,radius*2,h1], true);
			translate([0,0,0]) rotate([180-angle,0,0]) translate([0,radius/2,0]) cube([width2, radius, radius*2], true);
			translate([0,0,0]) rotate([0, 90, 0]) cylinder(width2, r = radius, center = true, $fs=0.5);
			if (!inner_axis) {
				axis_hole((width-thick)/2+tolerance, -(tolerance/2), 0,thick,radius);
				mirror([1,0,0]) axis_hole((width-thick)/2+tolerance, -(tolerance/2), 0,thick,radius);
			}
		}
		if (inner_axis) {
			axis(-((width2-thick)/2), -(tolerance/2), 0,thick,radius);
			mirror([1,0,0]) axis(-((width2-thick)/2), -(tolerance/2), 0,thick,radius);
		}
	}
}

// Cross-section profile of the cable channel — either a closed rectangular tube
// or an open C-profile (two cylinders + connecting slab) for cable insertion.
module middle_0(length, radius, thick, closed)
{
	if (closed) {
		cube([radius*2,length,radius*2], true);
	} else {
		rotate([90, 90, 0]) cylinder(length, r = radius, center = true, $fn=50);
		translate([0,0,thick]) rotate([90, 90, 0]) cylinder(length, r = radius, center = true, $fn=50);
		translate([0,0,thick/2]) cube([2*radius,length,thick], true);
	}
}

// Carves out the hollow cable channel running through the full length of the link.
// The channel is split into three segments (centre + two angled halves) and each half
// is swept through the articulation angle so the bore stays clear at maximum bend —
// preventing cables from being pinched at the joint.
module middle(width, radius, length, height, l1, h1, thick, over, under, inner_axis, closed)
{
	l = length;
	th = max(thick,thick * height/width);
	h = height - (closed ?2 :1)*th;
	w = width - 4*thick;
	r = h / 2;
	scale(v=[w/h,1,1]) translate(v = [0,0,r+th]) union() {
		translate([0,h1,0]) middle_0(l, r, th, closed);
		translate([0,(l1/2)+0.1,0]) {
			difference() {
				rotate([over,0,0]) union() {
					translate([0, l/4, 0]) middle_0(l/2, r, th, closed);
					translate([0, l/4,-r]) cube([2*r,l/2,2*r], true);
				}
				translate([0, l/4,-r]) cube([2*r,l/2,2*r], true);
			}
			difference() {
				rotate([-under,0,0]) union() {
					translate([0, l/4, 0]) middle_0(l/2, r, th, closed);
					translate([0, l/4,r]) cube([2*r,l/2,2*r], true);
				}
				translate([0, l/4,r]) cube([2*r,l/2,2*r], true);
			}
		}
	}
}

// Snap-in clip that closes the open top of the link after cables are routed.
// The two hooked legs (one per side) flex inward on insertion and spring back
// to lock under the lip of the link body.
// Called twice: once as a negative (cut the slot in the link), once as a positive
// (the separate printable clip piece placed beside the link on the build plate).
// `tol` is positive when cutting the slot (looser fit) and zero when printing the clip.
module clip(width, height, length, tol=0)
{
    tol2 = tol * 2;
    cwidth = (length/10)+tol;   // clip depth scales with link length for proportional grip
    cthickness = 1.5+tol;
    clength = 5;
    ccylinder = 2+tol2;         // hook diameter — sized to snap under the link's top edge
    translate([0, 0, height-(cthickness-tol2)/2])union(){
        cube([width+tol2, cwidth, cthickness], true);
        translate([width/2-(cthickness-tol2)/2, 0, -clength/2])union(){
            cube([cthickness, cwidth, clength+tol], true);
            translate([-cthickness/2, 0, -(clength/2-ccylinder/2)])rotate([90, 0, 0])cylinder(cwidth, r = ccylinder / 2, center= true, $fs=0.25);
        }
        translate([-(width/2-(cthickness-tol2)/2), 0, -clength/2])rotate([0, 0, 180])union(){
            cube([cthickness, cwidth, clength+tol], true);
            translate([-cthickness/2, 0, -(clength/2-ccylinder/2)])rotate([90, 0, 0])cylinder(cwidth, r = ccylinder / 2, center= true, $fs=0.25);
        }
    }
}

// Drills the transverse hole used to close the link with a physical pin (toothpick).
// Only relevant when clip=false and closed=false.
module hole(width, height, closed)
{
	if (!closed) {
		translate([0,0,height-1.5]) rotate([0, 90, 0]) cylinder(width+1, r = toothpick / 2, center = true, $fs=0.25);
	}
}

// Main assembly: combines all modules into a single printable chain link.
// thick is clamped between 1 and 2 mm regardless of width to keep walls printable.
// len is floored at 2*(height+thick) so the link is always long enough to form a proper joint.
// The clip (if enabled) is output as a separate body translated clear of the link,
// ready to print in the same job without supports.
module chain_link(width, length, height, under_angle, over_angle, inner_axis, closed, clip)
{
	thick = min(2,max(1, 0.1*width));
	radius = height / 2;
	len    = max(length, 2*(height+thick));
	l1     = len - (2 * radius);   // straight mid-section length between the two rounded ends
	h1     = radius;
	under  = min(max_angle, under_angle);
	over   = min(max_angle, over_angle);

	difference() {
		outline(width, len, height, radius, l1, under);
		outcut(width, radius, l1, h1, thick, over,  inner_axis);
		middle(width, radius, len, height, l1, h1, thick, over, under, inner_axis, closed);
		incut(width, radius, l1, h1, thick, over, inner_axis);
        if(clip&&!closed){
            clip(width, height, len, tolerance);  // cut the clip slot with added tolerance
        }else{
            hole(width, height, closed);
        }
	}
    // Place the clip body beside the link (not overlapping) for single-print convenience
    if(clip&&!closed) translate([0, 2+height+len/2, (len/10)/2])rotate([90, 0, 0])clip(width, height, len);
}

// Preview helper: renders three links articulated at their maximum bending angles
// to visually verify clearance and joint geometry before printing a full chain.
module debug(width, length, height, under_angle, over_angle, inner_axis, closed)
{
	thick = min(2,max(1, 0.1*width));
	radius = height / 2;
	len    = max(length, 2*(height+thick));
	l1     = len - (2 * radius);
	y_ofs  = (l1 / 2) + 0.1;
	z_ofs  = radius;

	chain_link(width, length, height, under_angle, over_angle, inner_axis, closed);
	translate(v = [0, -y_ofs,z_ofs]) rotate(a = [min(max_angle, under_angle),0,0]) translate(v = [0,-y_ofs,-z_ofs]) chain_link(width, length, height, under_angle, over_angle, inner_axis, closed);
	translate(v = [0, y_ofs,z_ofs]) rotate(a = [min(max_angle, over_angle),0,0]) translate(v = [0,y_ofs,-z_ofs]) chain_link(width, length, height, under_angle, over_angle, inner_axis, closed);
}
//debug(15, 18, 10, 30, 30, true, false);

//Multicolor Block or Chain Link
if(multicolor_block){
    translate([0, 0, height/2])cube([width+2, length+2, mcb_height], center = true);
}else{
    //Old
    //chain_link(width= 30, length=45, height=15, under_angle=0, over_angle=30, inner_axis=false, closed=false , clip=true);
    // New - Changed for Customizer compatibility
    chain_link(width, length, height, under_angle, over_angle, inner_axis, closed , clip);
}
