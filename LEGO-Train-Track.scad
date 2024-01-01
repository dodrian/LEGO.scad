use <LEGO.scad>;

// length of the track, in studs
track_length = 16;

gauge = "standard"; // [standard:Standard, narrow:Narrow]


color([108/255, 110/255, 104/255]) track(
    length=track_length,
    gauge_size = (gauge == "standard") ? 8 : (gauge == "narrow") ? 6 : 0
);

// place(14,0) block(height=1/3, width=2,length=2);

module track(
    gauge_size = 8,
    length=16
){
    ties(gauge_size, length);
    
    rail(0.5,1,1/3,length - 1);
    rail(0.5,gauge_size - 2,1/3,length - 1);
    
}

module ties(
    gauge_size = 8,
    length=16
){
    // first tie
    place(0,0) tie(
        size=1,
        gauge=gauge_size
    );
    
    // intermediate ties
    for(ii = [3:4:length-3]) {
    
        place(ii,0) tie(
            gauge=gauge_size
        );
    }
    
    // last tie
    place(length - 1,0) tie(
        size=1,
        gauge=gauge_size
    );
}

// a tie has a gap in studs where the rail goes
module tie(
    x=0,
    y=0,
    z=0,
    gauge=8, // total width of tie
    size=2
){
    
    difference() { // remove studs one in from either end
        place(x,y,z) uncenter(width=size, length=gauge) {
            block(
                width=gauge,
                length=size,
                height=1/3
            );
        }
        place(x,y+1,1/3) cube([8, size * 8, 8], center=false);
        place(x,y+gauge - 2,1/3) cube([8, size * 8, 8], center=false);
    }
}

module rail(x,y,z,length)
{
    points = [
        [7, 0],
        [7, 0.8],     
        [5.25, 2],       
        [5.25, 6.4],    
        [2.75, 6.4],     
        [2.75, 2],       
        [1, 0.8],
        [1, 0]
    ];
    place(x, y + 1, z) {
        rotate([90,0,180]) linear_extrude(height = length * 8){
            polygon(points);
        }
    }
}