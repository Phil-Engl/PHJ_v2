`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2024 12:45:19 PM
// Design Name: 
// Module Name: BlockShift_NW
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BlockShift_NW#(
    parameter BLOCK_SIZE = 128
)(
    input logic clk,
    input logic rst_n,

    output logic [7:0] in_ready,
    input logic [7:0] [BLOCK_SIZE-1:0] in_data,
    input logic [7:0] in_valid,
    input logic [7:0] [31:0] in_num,
    input logic [7:0] in_last,

    input logic ready_4_output,
    output logic [(8*BLOCK_SIZE)-1:0] out_data,
    output logic out_valid,
    output logic [31:0] out_num,
    output logic out_last
    );

logic [3:0] [2*BLOCK_SIZE-1:0] tmp_data;
logic [3:0] tmp_valid;
logic [3:0] [31:0] tmp_num;
logic [3:0] tmp_ready;
logic [3:0] tmp_last;

logic [1:0] [4*BLOCK_SIZE-1:0] tmp2_data;
logic [1:0] tmp2_valid;
logic [1:0] [31:0] tmp2_num;
logic [1:0] tmp2_ready;
logic [1:0] tmp2_last;

BlockShifter #(
    .BLOCK_SIZE(BLOCK_SIZE),
    .MAX_NUM_BLOCKS(1)
) uut_F0 (
    .clk(clk),
    .rst_n(rst_n),
    
    .in_ready(in_ready[1:0]),
    .in_data(in_data[1:0]),
    .in_valid(in_valid[1:0]),
    .in_num(in_num[1:0]),
    .in_last(in_last[1:0]),
    
    .ready_4_output(tmp_ready[0]),
    .out_data(tmp_data[0]),
    .out_valid(tmp_valid[0]),
    .out_num(tmp_num[0]),
    .out_last(tmp_last[0])
);

BlockShifter #(
    .BLOCK_SIZE(BLOCK_SIZE),
    .MAX_NUM_BLOCKS(1)
) uut_F1 (
    .clk(clk),
    .rst_n(rst_n),
    
    .in_ready(in_ready[3:2]),
    .in_data(in_data[3:2]),
    .in_valid(in_valid[3:2]),
    .in_num(in_num[3:2]),
    .in_last(in_last[3:2]),

    .ready_4_output(tmp_ready[1]),
    .out_data(tmp_data[1]),
    .out_valid(tmp_valid[1]),
    .out_num(tmp_num[1]),
    .out_last(tmp_last[1])
);

BlockShifter #(
    .BLOCK_SIZE(BLOCK_SIZE),
    .MAX_NUM_BLOCKS(1)
) uut_F2 (
    .clk(clk),
    .rst_n(rst_n),
    
    .in_ready(in_ready[5:4]),
    .in_data(in_data[5:4]),
    .in_valid(in_valid[5:4]),
    .in_num(in_num[5:4]),
    .in_last(in_last[5:4]),

    .ready_4_output(tmp_ready[2]),
    .out_data(tmp_data[2]),
    .out_valid(tmp_valid[2]),
    .out_num(tmp_num[2]),
    .out_last(tmp_last[2])
);

BlockShifter #(
    .BLOCK_SIZE(BLOCK_SIZE),
    .MAX_NUM_BLOCKS(1)
) uut_F3 (
    .clk(clk),
    .rst_n(rst_n),
    
    .in_ready(in_ready[7:6]),
    .in_data(in_data[7:6]),
    .in_valid(in_valid[7:6]),
    .in_num(in_num[7:6]),
    .in_last(in_last[7:6]),

    .ready_4_output(tmp_ready[3]),
    .out_data(tmp_data[3]),
    .out_valid(tmp_valid[3]),
    .out_num(tmp_num[3]),
    .out_last(tmp_last[3])
);

BlockShifter #(
    .BLOCK_SIZE(BLOCK_SIZE),
    .MAX_NUM_BLOCKS(2)
) uut_S0 (
    .clk(clk),
    .rst_n(rst_n),

    .in_ready(tmp_ready[1:0]),
    .in_data(tmp_data[1:0]),
    .in_valid(tmp_valid[1:0]),
    .in_num(tmp_num[1:0]),
    .in_last(tmp_last[1:0]),

    .ready_4_output(tmp2_ready[0]),
    .out_data(tmp2_data[0]),
    .out_valid(tmp2_valid[0]),
    .out_num(tmp2_num[0]),
    .out_last(tmp2_last[0])
);

BlockShifter #(
    .BLOCK_SIZE(BLOCK_SIZE),
    .MAX_NUM_BLOCKS(2)
) uut_S1 (
    .clk(clk),
    .rst_n(rst_n),

    .in_ready(tmp_ready[3:2]),
    .in_data(tmp_data[3:2]),
    .in_valid(tmp_valid[3:2]),
    .in_num(tmp_num[3:2]),
    .in_last(tmp_last[3:2]),

    .ready_4_output(tmp2_ready[1]),
    .out_data(tmp2_data[1]),
    .out_valid(tmp2_valid[1]),
    .out_num(tmp2_num[1]),
    .out_last(tmp2_last[1])
);

BlockShifter #(
    .BLOCK_SIZE(BLOCK_SIZE),
    .MAX_NUM_BLOCKS(4)
) uut_T0 (
    .clk(clk),
    .rst_n(rst_n),

    .in_ready(tmp2_ready),
    .in_data(tmp2_data),
    .in_valid(tmp2_valid),
    .in_num(tmp2_num),
    .in_last(tmp2_last),

    .ready_4_output(ready_4_output),
    .out_data(out_data),
    .out_valid(out_valid),
    .out_num(out_num),
    .out_last(out_last)
);
endmodule
