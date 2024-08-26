/**
 * narrow-ballast.scad
 * Copyright (c) Dorian Westacott, 2024
 * 
 * MIT License
 *
 * LEGO, the LEGO logo, the Brick, and DUPLO are trademarks of the LEGO Group. This is an independent project not sponsored, endorsed, nor associated with the LEGO Group.   
 */
 
 
// If your printer prints the track ballast correctly except for the stud diameter, use this variable to resize just the studs for your printer. A value of 1.05 will print the studs 105% bigger than standard.
stud_rescale = 1.025;
//stud_rescale = 1.03 * 1;  // Creality Ender 3 Pro, PLA
//stud_rescale = 1.0475 * 1; // Orion Delta, T-Glase
//stud_rescale = 1.022 * 1; // Orion Delta, ABS

color([108/255, 110/255, 104/255]) {
    stack(0,0,0) {
        place(0,0,0) uncenter(1,8) block(width=1, length=8, height=1/3, draw_posts=false, include_wall_splines=false, stud_rescale=stud_rescale);
        place(7,0,0) uncenter(1,8) block(width=1, length=8, height=1/3, draw_posts=false, include_wall_splines=false, stud_rescale=stud_rescale);
        place(0,3,0) rotate([0, 0, 90]) uncenter(2,8)  block(width=2, length=8, height=1/3, type="tile", draw_posts=false, include_wall_splines=false);
        place(0,7,0) rotate([0, 0, 90]) uncenter(2,8)  block(width=2, length=8, height=1/3, type="tile", draw_posts=false, include_wall_splines=false);
        place(1,1,1/3) uncenter(1,2) block(width=1,length=2,height=1/3, block_bottom_type="closed", stud_rescale=stud_rescale);
        place(1,5,1/3) uncenter(1,2) block(width=1,length=2,height=1/3, block_bottom_type="closed", stud_rescale=stud_rescale);
        place(6,1,1/3) uncenter(1,2) block(width=1,length=2,height=1/3, block_bottom_type="closed", stud_rescale=stud_rescale);
        place(6,5,1/3) uncenter(1,2) block(width=1,length=2,height=1/3, block_bottom_type="closed", stud_rescale=stud_rescale);
        place(3,1,1/3) uncenter(2,2) block(width=2,length=2,height=1/3, block_bottom_type="closed", stud_rescale=stud_rescale);
        place(3,5,1/3) uncenter(2,2) block(width=2,length=2,height=1/3, block_bottom_type="closed", stud_rescale=stud_rescale);
    }
}



/**
 * LEGO.scad 
 * https://github.com/cfinke/LEGO.scad
 * Copyright (c) Christopher Finke 2024
 * 
 * Modified and included under MIT License
 */


module block(
    width=1,
    length=2,
    height=1,
    type="brick",
    brand="lego",
    stud_type="solid",
    block_bottom_type="open",
    include_wall_splines=true,
    horizontal_holes=false,
    vertical_axle_holes=false,
    reinforcement=false,
    wing_type="full",
    wing_end_width=2,
    wing_base_length=2,
    stud_notches=false,
    slope_stud_rows=1,
    slope_end_height=0,
    curve_stud_rows=1,
    curve_type="concave",
    curve_end_height=0,
    roadway_width=0,
    roadway_length=0,
    roadway_x=0,
    roadway_y=0,
    roadway_invert=false,
    round_radius=0,
    stud_rescale=1,
    stud_top_roundness=0,
    dual_sided=false,
    dual_bottom=false,
    draw_posts=true,
    ) {
    post_wall_thickness = (brand == "lego" ? 0.85 : 1);
    wall_thickness=(brand == "lego" ? 1.45 : 1.5);
    stud_diameter=(brand == "lego" ? 4.85 : 9.40);
    hollow_stud_inner_diameter = (brand == "lego" ? 3.1 : 6.7);
    stud_height=(brand == "lego" ? 1.8 : 4.4);
    stud_spacing=(brand == "lego" ? 8 : 8 * 2);
    block_height=compute_block_height(type, brand);
    pin_diameter=(brand == "lego" ? 3 : 3 * 2);
    post_diameter=(brand == "lego" ? 6.5 : 13.2);
    cylinder_precision=(brand == "lego" ? 0.1 : 0.05);
    reinforcing_width = (brand == "lego" ? 0.7 : 1);

    real_include_wall_splines = block_bottom_type == "open" && include_wall_splines;
    spline_length = (brand == "lego" ? 0.25 : 1.7);
    spline_thickness = (brand == "lego" ? 0.7 : 1.3);

    horizontal_hole_diameter = (brand == "lego" ? 4.8 : 4.8 * 2);
    horizontal_hole_z_offset = (brand == "lego" ? 5.8 : 5.8 * 2);
    horizontal_hole_bevel_diameter = (brand == "lego" ? 6.2 : 6.2 * 2);
    horizontal_hole_bevel_depth = (brand == "lego" ? 0.9 : 0.9 * 1.5 / 1.2 );

    roof_thickness = (type == "baseplate" || dual_sided ? block_height * height : 1 * 1);

    // Duplo axle dimensions are based on "Early Simple Machines Set 9656"
    axle_spline_width = (brand == "lego" ? 2.0 : 3.10);
    axle_diameter = (brand == "lego" ? 5 * 1 : 7.25);

    // Brand-independent measurements.
    wall_play = 0.1 * 1;
    horizontal_hole_wall_thickness = 1 * 1;

    // Ensure that width is always less than or equal to length.
    real_width = ((type == "wing" || type == "slope") ? width : min(width, length) );
    real_length = ((type == "wing" || type == "slope")  ? length : max(width, length) );
    real_height = compute_real_height(type, height);

    // Ensure that the wing end width is even if the width is even, odd if odd, and a reasonable value.
    real_wing_end_width = (wing_type == "full"
        ?
        min(real_width - 2, ((real_width % 2 == 0) ? 
            (max(2, (
                wing_end_width % 2 == 0 ?
                (wing_end_width)
                :
                (wing_end_width-1)
            )))
            :
            (max(1, (
                wing_end_width % 2 == 0 ?
                (wing_end_width-1)
                :
                (wing_end_width)
            )))
        ))
        :
        (min(real_width-1, max(1, wing_end_width))) // Half-wing
    );

    // Ensure that the base length is a reasonable value.
    real_wing_base_length = min(real_length-1, max(1, wing_base_length)) + 1; // +1 because the angle starts before the last stud.
        
    // Validate all the rest of the arguments.
    real_slope_end_height = max(0, min(real_height - 1/3, slope_end_height));
    real_slope_stud_rows = min(real_length - 1, slope_stud_rows);
    real_curve_stud_rows = max(0, curve_stud_rows);
    real_curve_type = (curve_type == "convex" ? "convex" : "concave");
    real_curve_end_height = max(0, min(real_height - 1/3, curve_end_height));
    real_horizontal_holes = horizontal_holes && ((type == "baseplate" && real_height >= 8) || real_height >= 1) && !dual_sided;
    real_vertical_axle_holes = vertical_axle_holes && real_width > 1;
    real_reinforcement = reinforcement && type != "baseplate" && type != "tile" && !dual_sided;

    real_roadway_width = max(0, min(roadway_width, real_width));
    real_roadway_length = max(0, min(roadway_length, real_length));
    real_roadway_x = max(0, min(real_length - real_roadway_length, roadway_x));
    real_roadway_y = max(0, min(real_width - real_roadway_width, roadway_y));

    real_stud_notches = stud_notches && !dual_sided;
    real_dual_sided = dual_sided && type != "curve" && type != "slope" && type != "tile";
    real_dual_bottom = dual_bottom && !real_dual_sided && type != "curve" && type != "slope";

    total_studs_width = (stud_diameter * stud_rescale * real_width) + ((real_width - 1) * (stud_spacing - (stud_diameter * stud_rescale)));
    total_studs_length = (stud_diameter * stud_rescale * real_length) + ((real_length - 1) * (stud_spacing - (stud_diameter * stud_rescale)));

    total_posts_width = (post_diameter * (real_width - 1)) + ((real_width - 2) * (stud_spacing - post_diameter));
    total_posts_length = (post_diameter * (real_length - 1)) + ((real_length - 2) * (stud_spacing - post_diameter));

    total_axles_width = (axle_diameter * (real_width - 1)) + ((real_width - 2) * (stud_spacing - axle_diameter));
    total_axles_length = (axle_diameter * (real_length - 1)) + ((real_length - 2) * (stud_spacing - axle_diameter));

    total_pins_width = (pin_diameter * (real_width - 1)) + max(0, ((real_width - 2) * (stud_spacing - pin_diameter)));
    total_pins_length = (pin_diameter * (real_length - 1)) + max(0, ((real_length - 2) * (stud_spacing - pin_diameter)));

    overall_length = (real_length * stud_spacing) - (2 * wall_play);
    overall_width = (real_width * stud_spacing) - (2 * wall_play);

    wing_slope = (wing_type == "full" ?
        ((real_width - (real_wing_end_width + 1)) / 2) / (real_length - (real_wing_base_length - 1))
        :
        (real_width - (real_wing_end_width)) / (real_length - (real_wing_base_length - 1))
    );
    
    // trying to round the corners more then the width of the results in broken geometry
    // TODO allow setting each corner's rounding radius?
    max_round = min(real_width, real_length) / 2;
    real_rounding = round_radius > 0 ? min(max_round,round_radius) : max_round;
    round_distance = real_rounding * stud_spacing;

    translate([-overall_length/2, -overall_width/2, 0]) // Comment to position at 0,0,0 instead of centered on X and Y.
        union() {
            difference() {
                union() {
                    /**
                     * Include any union()s that should come before the final difference()s.
                     */
                    
                    // The mass of the block.
                    difference() {
                        cube([overall_length, overall_width, real_height * block_height]);
                        if (block_bottom_type == "open") {
                          translate([wall_thickness,wall_thickness,-roof_thickness]) cube([overall_length-wall_thickness*2,overall_width-wall_thickness*2,block_height*real_height]);
                        }
                    }

                    // The studs on top of the block (if it's not a tile).
                    if ( type != "tile" && !real_dual_bottom ) {
                        translate([stud_diameter * stud_rescale / 2, stud_diameter * stud_rescale / 2, 0]) 
                        translate([(overall_length - total_studs_length)/2, (overall_width - total_studs_width)/2, 0]) {
                            for (ycount=[0:real_width-1]) {
                                for (xcount=[0:real_length-1]) {
                                    if (!skip_this_stud(xcount, ycount)) {
                                        translate([xcount*stud_spacing,ycount*stud_spacing,block_height*real_height]) stud();
                                    }
                                }
                            }
                       }
                    }

                    // Interior splines to catch the studs.
                    if (real_include_wall_splines) {
                      translate([stud_spacing / 2 - wall_play - (spline_thickness/2), 0, 0]) for (xcount = [0:real_length-1]) {
                          translate([0,wall_thickness,0]) translate([xcount * stud_spacing, 0, 0]) cube([spline_thickness, spline_length, real_height * block_height]);
                          translate([xcount * stud_spacing, overall_width - wall_thickness -  spline_length, 0]) cube([spline_thickness, spline_length, real_height * block_height]);
                      }

                      translate([0, stud_spacing / 2 - wall_play - (spline_thickness/2), 0]) for (ycount = [0:real_width-1]) {
                          translate([wall_thickness,0,0]) translate([0, ycount * stud_spacing, 0]) cube([spline_length, spline_thickness, real_height * block_height]);
                          translate([overall_length - wall_thickness -  spline_length, ycount * stud_spacing, 0]) cube([spline_length, spline_thickness, real_height * block_height]);
                      }
                    }

                    if (type != "baseplate" && block_bottom_type == "open" && real_width > 1 && real_length > 1 && !real_dual_sided && roof_thickness < block_height * height) {
                        // Reinforcements and posts
                        translate([post_diameter / 2, post_diameter / 2, 0]) {
                            translate([(overall_length - total_posts_length)/2, (overall_width - total_posts_width)/2, 0]) {
                                union() {
                                    // Posts
                                    if (draw_posts) {
                                        for (ycount=[1:real_width-1]) {
                                            for (xcount=[1:real_length-1]) {
                                                translate([(xcount-1)*stud_spacing,(ycount-1)*stud_spacing,0]) post(real_vertical_axle_holes && !skip_this_vertical_axle_hole(xcount, ycount));
                                            }
                                        }
                                    }

                                    // Reinforcements
                                    if (real_reinforcement) {
                                        difference() {
                                            for (ycount=[1:real_width-1]) {
                                                for (xcount=[1:real_length-1]) {
                                                    translate([(xcount-1)*stud_spacing,(ycount-1)*stud_spacing,0]) reinforcement();
                                                }
                                            }

                                            for (ycount=[1:real_width-1]) {
                                                for (xcount=[1:real_length-1]) {
                                                    translate([(xcount-1)*stud_spacing,(ycount-1)*stud_spacing,-0.5]) cylinder(r=post_diameter/2-0.1, h=real_height*block_height+0.5, $fs=cylinder_precision);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if (draw_posts && type != "baseplate" && block_bottom_type == "open" && (real_width == 1 || real_length == 1) && real_width != real_length && !real_dual_sided && roof_thickness < block_height * height) {
                        // Pins
                        if (real_width == 1) {
                            translate([(pin_diameter/2) + (overall_length - total_pins_length) / 2, overall_width/2, 0]) {
                                for (xcount=[1:real_length-1]) {
                                    translate([(xcount-1)*stud_spacing,0,0]) cylinder(r=pin_diameter/2,h=block_height*real_height,$fs=cylinder_precision);
                                }
                            }
                        }
                        else {
                            translate([overall_length/2, (pin_diameter/2) + (overall_width - total_pins_width) / 2, 0]) {
                                for (ycount=[1:real_width-1]) {
                                    translate([0,(ycount-1)*stud_spacing,0]) cylinder(r=pin_diameter/2,h=block_height*real_height,$fs=cylinder_precision);
                                }
                            }
                        }
                    }

                    if (real_horizontal_holes) {
                        // The holes for the horizontal axles.
                        // 1-length bricks have the hole underneath the stud.
                        // >1-length bricks have the holes between the studs.
                        for (height_index = [0 : height - 1]) {
                            translate([horizontal_holes_x_offset(), overall_width, height_index * block_height]) 
                            translate([(overall_length - total_studs_length)/2, 0, 0]) {
                            for (axle_hole_index=[horizontal_hole_start_index() : horizontal_hole_end_index()]) {
                                if (!skip_this_horizontal_hole(axle_hole_index, height_index)) {
                                        translate([axle_hole_index*stud_spacing,0,horizontal_hole_z_offset]) rotate([90, 0, 0])  cylinder(r=horizontal_hole_diameter/2 + horizontal_hole_wall_thickness, h=overall_width,$fs=cylinder_precision);
                                    }
                                }
                            }
                        }
                    }
                }

                
                /**
                 * Include any differences from the basic brick here.
                 */
                
                if (real_vertical_axle_holes) {
                    if (real_width > 1 && real_length > 1) {
                        translate([axle_diameter / 2, axle_diameter / 2, 0]) {
                            translate([(overall_length - total_axles_length)/2, (overall_width - total_axles_width)/2, 0]) {
                                for (ycount = [ 1 : real_width - 1 ]) {
                                    for (xcount = [ 1 : real_length - 1]) {
                                        if (!skip_this_vertical_axle_hole(xcount, ycount)) {
                                            translate([(xcount-1)*stud_spacing,(ycount-1)*stud_spacing,-block_height/2]) axle();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                if (type == "wing") {
                    if (wing_type == "full" || wing_type == "right")  {
                        translate([0, 0, -0.5]) linear_extrude(block_height * real_height + stud_height + 1) polygon(points=[
                            [stud_spacing * (real_wing_base_length-1), -0.01],
                            [overall_length + 0.01, -0.01],
                            [overall_length + 0.01, (wing_type == "full" ?
                                (overall_width / 2 - (real_wing_end_width * stud_spacing / 2))
                                :
                                (overall_width - (real_wing_end_width * stud_spacing))
                            )]
                        ]
                        );
                    }
                    if (wing_type == "full" || wing_type == "left")  {
                        translate([0, 0, -0.5]) linear_extrude(block_height * real_height + stud_height + 1) polygon(points=[
                            [stud_spacing * (real_wing_base_length-1), overall_width + 0.01],
                            [overall_length + 0.01, overall_width + 0.01],
                            [overall_length + 0.01, (wing_type == "full" ? overall_width / 2 : 0) + (real_wing_end_width * stud_spacing / (wing_type == "full" ? 2 : 1))]
                        ]
                        );


                    }
                }
                else if (type == "slope") {
                    translate([0, overall_width+0.5, 0]) rotate([90, 0, 0]) linear_extrude(overall_width+1) polygon(points=[
                        [-0.1, (block_height * real_slope_end_height) + stud_height],
                        [min(overall_length, overall_length - (stud_spacing * real_slope_stud_rows) + (wall_play/2)), real_height * block_height - roof_thickness],
                        [min(overall_length, overall_length - (stud_spacing * real_slope_stud_rows) + (wall_play/2)), real_height * block_height + stud_height + 1],
                        [-0.1, real_height * block_height + stud_height + 1]
                    ]);
                }
                else if (type == "curve") {
                    if (real_curve_type == "concave") {
                        difference() {
                            translate([
                                    -curve_circle_length() / 2, // Align the center of the cube with the end of the block.
                                    -0.5, // Center the extra width on the block.
                                    (real_height * block_height) - (curve_circle_height() / 2)  // Align the bottom of the cube with the center of the curve circle.
                                ])
                                cube([curve_circle_length(), overall_width + 1, curve_circle_height()]);

                            translate([
                                    curve_circle_length() / 2,  // Align the end of the curve with the end of the block.
                                    overall_width / 2, // Center it on the block.
                                    (real_height * block_height) - (curve_circle_height() / 2)  // Align the top of the curve with the top of the block.
                                ])
                                rotate([90, 0, 0]) // Rotate sideways
                                translate([0, 0, -overall_width/2]) // Move so the cylinder is z-centered.
                                resize([curve_circle_length(), curve_circle_height(), 0]) // Resize to the approprate scale.
                                cylinder(r=real_height * block_height, h=overall_width, $fs=cylinder_precision);
                        }
                    }
                    else if (real_curve_type == "convex") {
                        union() {
                            translate([0, 0, real_height * block_height]) cube([overall_length - (real_curve_stud_rows * stud_spacing), overall_width, stud_height + .1]);
                            translate([0, 0, block_height * real_height])
                                translate([0, (overall_width+1)/2-.5, 0]) // Center across the end of the block.
                                rotate([90, 0, 0])
                                translate([0, 0, -((overall_width+1)/2)]) // z-center
                                resize([curve_circle_length(), curve_circle_height(), 0]) // Resize to the final dimensions.
                                cylinder(r=block_height * real_height, h=overall_width+1, $fs=cylinder_precision);
                        }
                    }
                }
                else if (type == "baseplate") {
                    // Rounded corners.
                    union() {
                        translate([overall_length, overall_width, 0]) translate([-((stud_spacing / 2) - wall_play), -((stud_spacing / 2) - wall_play), 0]) negative_rounded_corner(r=((stud_spacing / 2) - wall_play), h=real_height * block_height);
                        
                        translate([0, overall_width, 0]) translate([((stud_spacing / 2) - wall_play), -((stud_spacing / 2) - wall_play), 0]) rotate([0, 0, 90]) negative_rounded_corner(r=((stud_spacing / 2) - wall_play), h=real_height * block_height);
                        translate([((stud_spacing / 2) - wall_play), ((stud_spacing / 2) - wall_play), 0]) rotate([0, 0, 180]) negative_rounded_corner(r=((stud_spacing / 2) - wall_play), h=real_height * block_height);
                        translate([overall_length, 0, 0]) translate([-((stud_spacing / 2) - wall_play), ((stud_spacing / 2) - wall_play), 0]) rotate([0, 0, 270]) negative_rounded_corner(r=((stud_spacing / 2) - wall_play), h=real_height * block_height);
                    }
                }
                else if (type == "round") {
                    // Rounded corners.
                    union() {
                        translate([overall_length, overall_width, 0]) translate([-((round_distance) - wall_play), -((round_distance) - wall_play), -.499])                     negative_rounded_corner(r=((round_distance) - wall_play), h=real_height * block_height, inside=true);
                        translate([0, overall_width, 0])              translate([ ((round_distance) - wall_play), -((round_distance) - wall_play), -.499]) rotate([0, 0, 90 ]) negative_rounded_corner(r=((round_distance) - wall_play), h=real_height * block_height, inside=true);
                                                                      translate([ ((round_distance) - wall_play),  ((round_distance) - wall_play), -.499]) rotate([0, 0, 180]) negative_rounded_corner(r=((round_distance) - wall_play), h=real_height * block_height, inside=true);
                        translate([overall_length, 0, 0])             translate([-((round_distance) - wall_play),  ((round_distance) - wall_play), -.499]) rotate([0, 0, 270]) negative_rounded_corner(r=((round_distance) - wall_play), h=real_height * block_height, inside=true);
                    }
                }

                if (real_horizontal_holes) {
                    // The holes for the horizontal axles.
                    // 1-length bricks have the hole underneath the stud.
                    // >1-length bricks have the holes between the studs.
                    for (height_index = [0 : height - 1]) {
                        translate([horizontal_holes_x_offset(), 0, height_index * block_height]) 
                        translate([(overall_length - total_studs_length)/2, 0, 0]) {
                            for (axle_hole_index=[horizontal_hole_start_index() : horizontal_hole_end_index()]) {
                                if (!skip_this_horizontal_hole(axle_hole_index, height_index)) {
                                    union() {
                                        translate([axle_hole_index*stud_spacing,overall_width,horizontal_hole_z_offset]) rotate([90, 0, 0])  cylinder(r=horizontal_hole_diameter/2, h=overall_width,$fs=cylinder_precision);
    
                                        // Bevels. The +/- 0.1 measurements are here just for nicer previews in OpenSCAD, and could be removed.
                                        translate([axle_hole_index*stud_spacing,horizontal_hole_bevel_depth-0.1,horizontal_hole_z_offset]) rotate([90, 0, 0]) cylinder(r=horizontal_hole_bevel_diameter/2, h=horizontal_hole_bevel_depth+0.1,$fs=cylinder_precision);
                                        translate([axle_hole_index*stud_spacing,overall_width+0.1,horizontal_hole_z_offset]) rotate([90, 0, 0]) cylinder(r=horizontal_hole_bevel_diameter/2, h=horizontal_hole_bevel_depth+0.1,$fs=cylinder_precision);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            
            /**
             * Any final union()s for the brick.
             */
            
            if (type == "wing") {
                difference() {
                    union() {
                        if ( wing_type == "full" || wing_type == "right" ){
                            linear_extrude(block_height * real_height) polygon(points=[
                                [stud_spacing * (real_wing_base_length-1), 0],
                                [overall_length, (wing_type == "full" ? 
                                    ((overall_width / 2) - (real_wing_end_width * stud_spacing / 2))
                                    :
                                    (overall_width - (real_wing_end_width * stud_spacing))
                                )],
                                [overall_length, (wing_type == "full" ? 
                                    ((overall_width / 2) - (real_wing_end_width * stud_spacing / 2))
                                    :
                                    (overall_width - (real_wing_end_width * stud_spacing))
                                ) + wall_thickness],
                                [stud_spacing * (real_wing_base_length-1), wall_thickness]
                            ]);
                        }

                        if (wing_type == "full" || wing_type == "left") {
                            linear_extrude(block_height * real_height) polygon(points=[
                                [stud_spacing * (real_wing_base_length-1), overall_width],
                                [overall_length, (wing_type == "full" ? overall_width / 2 : 0) + (real_wing_end_width * stud_spacing / (wing_type == "full" ? 2 : 1))],
                                [overall_length, (wing_type == "full" ? overall_width / 2 : 0) + (real_wing_end_width * stud_spacing / (wing_type == "full" ? 2 : 1)) - wall_thickness],
                                [stud_spacing * (real_wing_base_length-1), overall_width - wall_thickness]
                            ]);
                        }
                    }

                    if (real_stud_notches) {subtract_stud_notches();}
                }
            }
            else if (type == "slope") {
                translate([0, overall_width, 0]) rotate([90, 0, 0]) linear_extrude(overall_width) polygon(points=[
                    [0, (block_height * real_slope_end_height) + stud_height],
                    [0, (block_height * real_slope_end_height) + stud_height + roof_thickness],
                    [min(overall_length, overall_length - (stud_spacing * real_slope_stud_rows) + (wall_play/2)), real_height * block_height],
                    [min(overall_length, overall_length - (stud_spacing * real_slope_stud_rows) + (wall_play/2)), (real_height * block_height) - roof_thickness]
                ]);
            }
            else if (type == "curve") {
                if (real_curve_type == "concave") {
                    intersection() {
                        translate([
                                -curve_circle_length() / 2, // Align the center of the cube with the end of the block.
                                -0.5, // Center the extra width on the block.
                                (real_height * block_height) - (curve_circle_height() / 2)  // Align the bottom of the cube with the center of the curve circle.
                            ])
                            cube([curve_circle_length(), overall_width + 1, curve_circle_height()]);

                        difference() {   
                            translate([
                                    curve_circle_length() / 2,  // Align the end of the curve with the end of the block.
                                    overall_width / 2, // Center it on the block.
                                    (real_height * block_height) - (curve_circle_height() / 2)  // Align the top of the curve with the top of the block.
                                ])
                                rotate([90, 0, 0]) // Rotate sideways
                                translate([0, 0, -overall_width/2]) // Move so the cylinder is z-centered.
                                resize([curve_circle_length(), curve_circle_height(), 0]) // Resize to the approprate scale.
                                cylinder(r=real_height * block_height, h=overall_width, $fs=cylinder_precision);

                            translate([
                                    curve_circle_length() / 2,  // Align the end of the curve with the end of the block.
                                    overall_width / 2, // Center it on the block.
                                    (real_height * block_height) - (curve_circle_height() / 2) // Align the top of the curve with the top of the block.
                                ])
                                rotate([90, 0, 0]) // Rotate sideways
                                translate([0, 0, -overall_width/2]) // Move so the cylinder is z-centered.
                                resize([curve_circle_length() - (wall_thickness * 2), curve_circle_height() - (wall_thickness * 2), 0]) // Resize to the approprate scale.
                                cylinder(r=real_height * block_height, h=overall_width, $fs=cylinder_precision);
                        }
                    }
                }
                else if (real_curve_type == "convex") {
                    intersection() {
                        translate([
                            0,
                            0,
                            (real_height * block_height) - (curve_circle_height() / 2) - wall_thickness // Align the top of the cube with the top of the block.
                        ])
                            cube([curve_circle_length() / 2, overall_width, curve_circle_height() / 2 + wall_thickness]);

                       translate([0, 0, block_height * real_height])
                            translate([0, overall_width/2, 0]) // Center across the end of the block.
                            rotate([90, 0, 0])
                            translate([0, 0, -overall_width/2]) // z-center
                            difference() {
                                resize([curve_circle_length() + (wall_thickness * 2), curve_circle_height() + (wall_thickness * 2), 0]) // Resize to the final dimensions.
                                cylinder(r=block_height * real_height, h=overall_width, $fs=cylinder_precision);

                                translate([0, 0, -0.5]) // The inner cylinder is just a little taller, for nicer OpenSCAD previews.
                                    resize([curve_circle_length(), curve_circle_height(), 0]) // Resize to the final dimensions.
                                    cylinder(r=block_height * real_height, h=overall_width+1, $fs=cylinder_precision);
                            }
                    }
                }
            }
            else if (type == "round") {
                difference() {
                    union() {
                        translate([round_distance,                    round_distance,                 0])             rounded_corner_wall(real_rounding);
                        translate([overall_length - (round_distance), round_distance,                 0]) rotate(90)  rounded_corner_wall(real_rounding);
                        translate([overall_length - (round_distance), overall_width - round_distance, 0]) rotate(180) rounded_corner_wall(real_rounding);
                        translate([round_distance,                    overall_width - round_distance, 0]) rotate(270) rounded_corner_wall(real_rounding);
                    }
                if (real_stud_notches) {subtract_stud_notches();}
                }
            }
            
            if (real_dual_sided) {
                translate([overall_length/2, overall_width/2, block_height * height]) mirror([0,0,1]) block(
                    width=real_width,
                    length=real_length,
                    height=real_height,
                    type=type,
                    brand=brand,
                    stud_type=stud_type,
                    block_bottom_type=block_bottom_type,
                    include_wall_splines=include_wall_splines,
                    horizontal_holes=real_horizontal_holes,
                    vertical_axle_holes=real_vertical_axle_holes,
                    reinforcement=real_reinforcement,
                    wing_type=wing_type,
                    wing_end_width=real_wing_end_width,
                    wing_base_length=real_wing_base_length-1,
                    stud_notches=real_stud_notches,
                    slope_stud_rows=real_slope_stud_rows,
                    slope_end_height=real_slope_end_height,
                    curve_stud_rows=real_curve_stud_rows,
                    curve_type=real_curve_type,
                    curve_end_height=real_curve_end_height,
                    roadway_width=real_roadway_width,
                    roadway_length=real_roadway_length,
                    roadway_x=real_roadway_x,
                    roadway_y=real_roadway_y,
                    stud_rescale=stud_rescale,
                    stud_top_roundness=stud_top_roundness,
                    dual_sided=false
                );
            }

            if (real_dual_bottom) {
                translate([overall_length/2, overall_width/2, block_height * height * 2]) mirror([0,0,1]) block(
                    width=real_width,
                    length=real_length,
                    height=real_height,
                    type="tile",
                    brand=brand,
                    stud_type=stud_type,
                    block_bottom_type=block_bottom_type,
                    include_wall_splines=include_wall_splines,
                    horizontal_holes=real_horizontal_holes,
                    vertical_axle_holes=real_vertical_axle_holes,
                    reinforcement=real_reinforcement,
                    wing_type=wing_type,
                    wing_end_width=real_wing_end_width,
                    wing_base_length=real_wing_base_length-1,
                    stud_notches=real_stud_notches,
                    slope_stud_rows=real_slope_stud_rows,
                    slope_end_height=real_slope_end_height,
                    curve_stud_rows=real_curve_stud_rows,
                    curve_type=real_curve_type,
                    curve_end_height=real_curve_end_height,
                    roadway_width=real_roadway_width,
                    roadway_length=real_roadway_length,
                    roadway_x=real_roadway_x,
                    roadway_y=real_roadway_y,
                    stud_rescale=stud_rescale,
                    stud_top_roundness=stud_top_roundness,
                    dual_sided=false,
                    dual_bottom=false
                );
            }
    }

    module post(vertical_axle_hole) {
        difference() {
            cylinder(r=post_diameter/2, h=real_height*block_height,$fs=cylinder_precision);
            if (vertical_axle_hole==true) {
                translate([0,0,-block_height/2])
                    axle();
            } else {
                translate([0,0,-0.5]) cylinder(r=(post_diameter/2)-post_wall_thickness, h=real_height*block_height+1,$fs=cylinder_precision);
            }
        }
    }

    module reinforcement() {
        union() {
            translate([0,0,real_height*block_height/2]) union() {
                cube([reinforcing_width, 2 * (stud_spacing - (2 * wall_play)), real_height * block_height],center=true);
                rotate(v=[0,0,1],a=90) cube([reinforcing_width, 2 * (stud_spacing - (2 * wall_play)), real_height * block_height], center=true);
            }
        }
    }

    module axle() {
        translate([0,0,(real_height+1)*block_height/2]) union() {
            cube([axle_diameter,axle_spline_width,(real_height+1)*block_height],center=true);
            cube([axle_spline_width,axle_diameter,(real_height+1)*block_height],center=true);
        }
    }

    module stud() {
        stud_top_height=1;
        stud_body_height=(stud_top_roundness != 0) ? (stud_height - stud_top_height) : stud_height;
        difference() {
            union() {
                cylinder(r=(stud_diameter*stud_rescale)/2,h=stud_body_height,$fs=cylinder_precision);
                if (stud_top_roundness != 0) {
                    translate([0,0,stud_body_height])
                    rounded_stud_top(height=stud_top_height, radius=(stud_diameter*stud_rescale)/2,curve_height=stud_top_roundness);
                }
            }

            if (stud_type == "hollow") {
                // 0.5 is for cleaner preview; doesn't affect functionality.
                cylinder(r=(hollow_stud_inner_diameter*stud_rescale)/2,h=stud_height+0.5,$fs=cylinder_precision);
            }
        }
    }

    module rounded_stud_top(
        height,
        radius,
        curve_height
        ) {
        assert(curve_height < (radius/2), "Curve height must be less than half the radius");
        assert(height >= curve_height, "Curve height must be greater than or equal to height");
        base_height=height-curve_height;
        union() {
            cylinder(h=base_height, r=radius, $fs=cylinder_precision);
            translate([0,0,base_height])
            difference() {
                union() {
                    rotate_extrude($fs=cylinder_precision)
                    hull() {
                        translate([radius-curve_height, 0, 0])
                        circle(curve_height, $fs=cylinder_precision);
                    };
                    cylinder(h=curve_height, r=(radius-curve_height), $fs=cylinder_precision);
                }
                translate([0,0,-curve_height])
                cylinder(h=curve_height, r=(radius), $fs=cylinder_precision);
            }

        };
    }

    module subtract_stud_notches() {
        translate([overall_length/2, overall_width/2, -.001])
            translate([0, 0, -(1/3 * block_height)]) block(
                width=real_width,
                length=real_length,
                height=1/3,
                brand=brand,
                stud_type="solid",
                block_bottom_type=block_bottom_type,
                include_wall_splines=include_wall_splines,
                type="brick",
                stud_rescale=1.5,
                stud_top_roundness=stud_top_roundness
            );
    }
                        
    module rounded_corner_wall(round_radius) {
        difference() {
            rotate([0,0,180]) {
                rotate_extrude(angle=90) {
                    square([round_radius * stud_spacing,real_height * block_height]);
                }
            }
            translate([0,0,-.001])
            rotate([0,0,179]) {
                // just a little wider to avoid false surfaces
                rotate_extrude(angle=92) {
                    square([(round_radius * stud_spacing) - wall_thickness,(real_height * block_height)+ .001]);
                }
            }
        }
    }

    function curve_circle_length() = (overall_length - (stud_spacing * min(real_length - 1, real_curve_stud_rows)) + (wall_play/2)) * 2;
    function curve_circle_height() = (
            (
                (block_height * real_height) - (real_curve_end_height * block_height)) * 2) - (real_curve_type == "convex" ? (stud_height * 2) + (wall_thickness * 2) : 0);

    function wing_width(x_pos) = (real_width - width_loss(x_pos));

    function width_loss(x_pos) = (type != "wing" ? 0 :
        round((wing_type == "full" ?
            max(0, (2 * wing_slope * (x_pos - (real_wing_base_length - 1)))) + 0.3 // Full wing
            :
            max(0, (wing_slope * (x_pos - (real_wing_base_length - 1)))) + 0.2 // Half wing
        )) // +extra is because full studs can still fit on partially missing bases, but not by much
    );

    function horizontal_hole_start_index() = (
        (
            (type == "slope" && real_slope_stud_rows == 1)
            || (type == "curve" && real_curve_stud_rows == 1)
        )
        ?
        real_length - 1
        :
        0
    );
    function horizontal_hole_end_index() = (
        (
            real_length == 1
            || (type == "slope" && real_slope_stud_rows == 1)
            || (type == "curve" && real_curve_stud_rows == 1)
        )
        ?
        real_length - 1
        :
        real_length - 2
    );
    function skip_this_horizontal_hole(xcount, zcount) = (
        (type == "slope" && ((zcount >= slope_end_height) && (xcount <= real_length - real_slope_stud_rows - 1)))
        ||
        (type == "curve" && ((zcount >= curve_end_height) && (xcount <= real_length - real_curve_stud_rows - 1)))
    );

    function horizontal_holes_x_offset() = (
        (horizontal_hole_diameter / 2)
        + (
            (
                real_length == 1
                || (type == "slope" && real_slope_stud_rows == 1)
                || (type == "curve" && real_curve_stud_rows == 1)
            )
            ?
            0
            :
            (stud_spacing / 2)
        )
    );
    
    function put_vertical_axle_hole_here(xcount, ycount) = (
        !skip_this_axle_hole(xcount, ycount)
    );
    
    function skip_this_vertical_axle_hole(xcount, ycount) = (
        (type == "slope" && xcount < (real_length - real_slope_stud_rows + 1))
        ||
        (type == "curve" && xcount < (real_length - real_curve_stud_rows + 1))
        
    );
    
    // Ranges are zeron indexed
    function skip_this_stud(xcount, ycount) = (
        (type == "wing" && (
            (wing_type == "full" && ((ycount+1 <= ceil(width_loss(xcount+1)/2)) || (ycount+1 > floor(real_width - (width_loss(xcount+1)/2)))))
            || (wing_type == "left" && ycount+1 > wing_width(xcount+1))
            || (wing_type == "right" && ycount < width_loss(xcount+1))
            )
        )
        ||
        ( ! roadway_invert && real_roadway_width > 0 && real_roadway_length > 0 && pos_in_roadway(xcount, ycount))
        ||
        ( roadway_invert && real_roadway_width > 0 && real_roadway_length > 0 && !pos_in_roadway(xcount, ycount))
        ||
        (type == "round" && (
            ((xcount+1) * (ycount+1)) < real_rounding
            || ((real_length - xcount) * (ycount+1)) < real_rounding
            || ((real_length - xcount) * (real_width - ycount)) < real_rounding
            || ((xcount+1) * (real_width - ycount)) < real_rounding
        ))
    );

    function pos_in_roadway(x, y) = (
        x >= real_roadway_x
        && y >= real_roadway_y
        && y < real_roadway_y + real_roadway_width
        && x < real_roadway_x + real_roadway_length
    );
        
    
    module negative_rounded_corner(r,h,inside=false) {
        ir=inside ? r-wall_thickness : r;
        difference() {
            translate([0, 0, -.5]) cube([r+1, r+1, h+1]);
            translate([0, 0, -1]) cylinder(r=ir, h=h + 2, $fs=cylinder_precision);
        }
    }
}

module uncenter(
    width,
    length,
    height,
    stud_spacing=8,
    x_wall_play=0.1,
    y_wall_play=0.1,
    z_wall_play=0.1
    ) {
    translate([((stud_spacing * length) / 2) - x_wall_play, ((stud_spacing * width) / 2) - y_wall_play, height ? ((stud_spacing * height) / 2) - z_wall_play : 0]) children();
}

module place(x, y, z=0) {
    translate([8 * y, 8 * x, z * 9.6]) children();
}

module stack(x=0,y=0,z=0) {
    union() {
        place(x,y,z) {
            children();
        }
    }
}

function compute_real_height(type, height) = max((type == "baseplate" ? 1 : 1/3), height);

function compute_block_height(type, brand) = (brand == "lego" ? (type == "baseplate" ? 1.3 : 9.6) : 9.6 * 2);

function block_height(height_ratio=1, brand="lego", type="block") =
  let (
    real_height = compute_real_height(type, height_ratio),
    block_height = compute_block_height(type, brand)
  )
  (real_height * block_height);


function minimum_block_count(
    length=0,
    stud_spacing=8,
    wall_play=0.1
    ) = ceil((length/stud_spacing)-wall_play);


/* MIT License

Copyright (c) 2024 Dorian Westacott
Copyright (c) 2015 Christopher Finke

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/