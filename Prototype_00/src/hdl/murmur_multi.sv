`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: murmur_8way
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: 8 instances of murmur_module in parallel
// 
// Dependencies: murmur
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module murmur_multi#(
    parameter NUM_HASHER = 8
)(
    input logic clk,
    input logic resetn,

    output logic [NUM_HASHER-1:0] in_ready,
    input logic [NUM_HASHER-1:0] [63:0] in_data,
    input logic [NUM_HASHER-1:0] in_valid,
    input logic [NUM_HASHER-1:0] in_last_processed,
    input logic [NUM_HASHER-1:0] [63:0] in_serialnum,
    
    input logic [NUM_HASHER-1:0] out_ready,
    output logic [NUM_HASHER-1:0] [63:0] out_tuple,
    output logic [NUM_HASHER-1:0] [31:0] out_tag,
    output logic [NUM_HASHER-1:0] out_valid,
    output logic [NUM_HASHER-1:0] out_last_processed,
    output logic [NUM_HASHER-1:0] [63:0] out_serialnum
    );


logic [NUM_HASHER-1:0] [95:0] out_data;
integer i;

for(genvar i=0; i<NUM_HASHER; i=i+1) begin
    murmur murmur_inst (
            .clk(clk),
            .resetn(resetn),

            .in_ready(in_ready[i]),
            .in_data(in_data[i]),
            .in_valid(in_valid[i]),
            .in_last_processed(in_last_processed[i]),
            .in_serialnum(in_serialnum[i]),
            
            .out_ready(out_ready[i]),
            .out_valid(out_valid[i]),
            .out_data(out_data[i]),
            .out_last_processed(out_last_processed[i]),
            .out_serialnum(out_serialnum[i])
        );
end

always_comb begin
    for(i=0; i<NUM_HASHER; i=i+1) begin
        out_tuple[i] <= out_data[i][63:0];
        out_tag[i] <= out_data[i][95:64];
    end
end
endmodule
