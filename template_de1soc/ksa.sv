module ksa (
    CLOCK_50,
    KEY,
    SW, 
    LEDR, 
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5
);

//=======================================================
//  PORT declarations
//=======================================================
input                       CLOCK_50;
input            [3:0]      KEY;
input            [9:0]      SW;
output           [9:0]      LEDR;

//////////// SEG7 //////////
output           [6:0]      HEX0;
output           [6:0]      HEX1;
output           [6:0]      HEX2;
output           [6:0]      HEX3;
output           [6:0]      HEX4;
output           [6:0]      HEX5;


logic clk, reset_n;

assign clk = CLOCK_50;
assign reset_n = KEY[3];


logic [6:0] ssOut;
logic [3:0] nIn;

SevenSegmentDisplayDecoder ssdd (
    .ssOut(ssOut), 
    .nIn(nIn)
);


endmodule


