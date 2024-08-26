use <LEGO.scad>;

// Length, in studs, between first two coupling points
length_one = 4;

// length, in studs, between next two coupling points (zero to ignore)
length_two = 0;

/* [rod measurements] */
    rod_height = 7.4;
    hole_diameter = 4.8;
    indent_diameter = 6.2;
    indent_depth = 1.0;
    inner_thickness = 1.5;
    full_thickness = 4;
    stud_spacing = 8;

$fs=0.1;

module coupling_rod() {

    
    // base
    cube([length_one * stud_spacing, rod_height, inner_thickness]);
    
    // circle
    translate([0,rod_height / 2, 0]) {
        difference() {
            cylinder(r=rod_height / 2, h=full_thickness);
            translate([0,0,-0.05]) cylinder(r=hole_diameter / 2, h = full_thickness + 0.1);
            translate([0,0,full_thickness - indent_depth]) cylinder(r=indent_diameter / 2, h = indent_depth + 0.1);
        }
    }
}

coupling_rod();