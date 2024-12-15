`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: HashTable
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: simple hash table built from BRAM module
// 
// Dependencies: BRAM
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HashTableV2 #(
    parameter TUPLE_SIZE = 64,
    parameter ROW_BITS = 3, 
    parameter COL_BITS = 1
)(
    input logic clk,
    input logic resetn,

    output logic in_ready_BUILD,
    input logic [63:0] in_data_BUILD,
    input logic [31:0] in_hash_BUILD,
    input logic in_valid_BUILD,
    input logic in_last_processed_BUILD,

    output logic in_ready_PROBE,
    input logic [63:0] in_data_PROBE,
    input logic [31:0] in_hash_PROBE,
    input logic in_valid_PROBE,
    input logic in_last_processed_PROBE,
    input logic [63:0] in_serialnum,

    input logic out_ready,
    output logic out_valid,
    output logic [127:0] out_data,
    output logic out_last_processed,
    output logic [63:0] out_serialnum,
    output logic out_was_joined
);

always_comb begin
    in_ready_BUILD <= 1'b1;
    in_ready_PROBE <= 1'b1;
    out_valid <= '0;
    out_data <= '0;
    out_last_processed <= '0;
    out_serialnum <= '0;
    out_was_joined <= '0;
end
    
endmodule
