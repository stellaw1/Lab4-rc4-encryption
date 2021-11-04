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

logic mem_write;
logic [7:0] mem_addr;
logic [7:0] mem_data_in;
logic [7:0] mem_data_out;

logic init_start, init_finish; 
logic [7:0] init_data_out;

array_fill init_s_array (
    .clk(clk),
    .start(reset_n),
    .finish(init_finish),
    .data(init_data_out)
);

logic shuffle_start, shuffle_finish, shuffle_wren;
logic [7:0] shuffle_data_out, shuffle_addr_out;
logic [23:0] secret;

array_shuffle shuffle_s_array (
    .clk(clk),
    .start(init_finish),
    .data_in(mem_data_out),
    .secret(secret),
    .finish(shuffle_finish),
    .mem_write(shuffle_wren),
    .addr_out(shuffle_addr_out),
    .data_out(shuffle_data_out)
);

s_memory mem (
    .address(mem_addr), 
    .clock(clk),
    .data(mem_data_in),
    .wren(mem_write),
    .q(mem_data_out)
);

logic [4:0] rom_address;
logic [7:0] rom_read_data;

message encrypted (
    .address(rom_address),
    .clock(clk),
    .q(rom_read_data)
);

logic [4:0] ram_address;
logic [7:0] ram_write_data;
logic ram_wren;
logic ram_read_data;

ram decrypted (
    .address(ram_address),
    .clock(clk),
    .data(ram_write_data),
    .wren(ram_wren),
    .q(ram_read_data)
);

logic decrypt_start, decrypt_finish, decrypt_write;
logic [7:0] decrypt_addr;
logic [4:0] decrypt_ram_addr;
logic [7:0] decrypt_data_out;

decrypt_message decryptor (
    .clk(clk),
    .start(decrypt_start),
    .s_read_data(mem_data_out),
    .rom_read_data(rom_read_data),
    .s_write(decrypt_write),
    .ram_write(ram_wren),
    .s_address(decrypt_addr),
    .ram_address(decrypt_ram_addr),
    .rom_address(rom_address),
    .s_write_data(decrypt_data_out),
    .ram_write_data(ram_write_data),
    .finish(decrypt_finish)
);

logic check_start, check_finish, check_valid;
logic [7:0] check_ram_addr;

check_message test_decrypt (
    .clk(clk),
    .start(check_start),
    .read_character(ram_read_data),
    .finish(check_finish),
    .valid(check_valid),
    .address(check_ram_addr)
);

assign mem_write = init_start
    ? 1'b1 
    : shuffle_start
        ? shuffle_wren
        : decrypt_start
            ? decrypt_write
            : 1'b0;

assign mem_addr = init_start
    ? init_data_out
    : shuffle_start
        ? shuffle_addr_out
        : decrypt_addr;

assign mem_data_in = init_start
    ? init_data_out
    : shuffle_start
        ? shuffle_data_out
        : decrypt_data_out;

assign ram_address = decrypt_start
    ? decrypt_ram_addr
    : check_ram_addr;

logic search_finish, message_found;
logic [31:0] encrypted_message;

brute_force search_message (
    .clk(clk),
    .start(reset_n),
    .init_finish(init_finish),
    .shuffle_finish(shuffle_finish),
    .decrypt_finish(decrypt_finish),
    .check_finish(check_finish),
    .check_valid(check_valid),
    .init_start(init_start),
    .shuffle_start(shuffle_start),
    .decrypt_start(decrypt_start),
    .check_start(check_start),
    .finish(search_finish),
    .found(message_found),
    .secret_key(secret)
);

assign LEDR[0] = search_finish & message_found;
assign LEDR[1] = search_finish & !message_found;

SevenSegmentDisplayDecoder hex0 (
    .ssOut(HEX0),
    .nIn(secret[3:0])
);
SevenSegmentDisplayDecoder hex1 (
    .ssOut(HEX1),
    .nIn(secret[7:4])
);
SevenSegmentDisplayDecoder hex2 (
    .ssOut(HEX2),
    .nIn(secret[11:8])
);
SevenSegmentDisplayDecoder hex3 (
    .ssOut(HEX3),
    .nIn(secret[15:12])
);
SevenSegmentDisplayDecoder hex4 (
    .ssOut(HEX4),
    .nIn(secret[19:16])
);
SevenSegmentDisplayDecoder hex5 (
    .ssOut(HEX5),
    .nIn(secret[23:20])
);

endmodule
