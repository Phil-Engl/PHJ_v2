`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2024 01:22:58 PM
// Design Name: 
// Module Name: rand_to_axi
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

module CONV_STREAM_to_AXI#(
    parameter BLOCK_SIZE = 128
)
(
    input logic clk,
    input logic rst_n,

    output logic [7:0] in_ready,
    input logic [7:0] [BLOCK_SIZE-1:0] in_data,
    input logic [7:0] in_valid,
    input logic [7:0] in_last,

    input logic ready_4_output,
    output logic [1023:0] out_data,
    output logic [127:0] out_keep,
    output logic out_valid,
    output logic out_last
    );

logic [8*BLOCK_SIZE-1:0] tmp_out_data;
logic tmp_out_valid;
logic [31:0] tmp_out_num;
logic tmp_ready_4_output;
logic tmp_out_last;
logic [31:0] multiplied_num;


BlockShift_NW # (
    .BLOCK_SIZE(BLOCK_SIZE)
) uut_F0 (
    .clk(clk),
    .rst_n(rst_n),
    .in_ready(in_ready),
    .in_data(in_data),
    .in_valid(in_valid),
    .in_num({1,1,1,1,1,1,1,1}),
    .in_last(in_last),
    .ready_4_output(tmp_ready_4_output),
    .out_data(tmp_out_data),
    .out_valid(tmp_out_valid),
    .out_num(tmp_out_num),
    .out_last(tmp_out_last)
);

BarrelShifter #(
    .BLOCK_SIZE(128),
    .NUM_BLOCKS(8)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .in_ready(tmp_ready_4_output),
    .in_data(tmp_out_data),
    //.in_keep(),
    .in_valid(tmp_out_valid),
    .in_last(tmp_out_last),
    .in_num_bytes_valid(multiplied_num),
    .out_ready(ready_4_output),
    .out_data(out_data), 
    .out_keep(out_keep),
    .out_valid(out_valid),
    .out_last(out_last)
);

always_comb begin
        multiplied_num <= tmp_out_num;// * 16; // (BLOCK_SIZE / 8) = 16! //(tmp_out_num * BLOCK_SIZE) / 8;
end

endmodule
