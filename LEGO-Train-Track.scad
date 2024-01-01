use <LEGO.scad>;


color([108/255, 110/255, 104/255]) place(0,0) track();

// place(14,0) block(height=1/3, width=2,length=2);

module track(
    gauge="standard",
    length=16
){
    place(-0.5,0) block(
        height=1/3,
        width=1,
        length=8
    );
    
    place(3,0) block(
        height=1/3,
        width=2,
        length=8
    );
    
    place(7,0) block(
        height=1/3,
        width=2,
        length=8
    );
    
    place(11,0) block(
        height=1/3,
        width=2,
        length=8
    );
    
    place(14.5,0) block(
        height=1/3,
        width=1,
        length=8
    );
    rail(-0.5,-2.5,1/3,15);
    rail(-0.5,2.5,1/3,15);
    
}

module rail(x,y,z,length)
{
    points = [
        [3, 0.8],     
        [1.25, 2],       
        [1.25, 6.4],    
        [1.75-3, 6.4],     
        [-1.25, 2],       
        [-3, 0.8]         
    ];
    place(x, y, z) {
        rotate([90,0,180]) linear_extrude(height = length * 8){
            polygon(points);
        }
    }
}