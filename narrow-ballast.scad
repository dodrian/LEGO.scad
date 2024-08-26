use <LEGO.scad>

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
