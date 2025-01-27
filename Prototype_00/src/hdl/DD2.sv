`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: DD2
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: module has 2 inputs for tuples and forwards tuples according to the n-th bit of their hash digest to either of the 2 outputs
// 
// Dependencies: Gate
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DD2#(
    parameter INPUT_SIZE = 64,
    parameter decision_bit = 0
)(
    input logic clk,
    input logic resetn,
    
    output logic    [1:0] in_ready,
    input logic     [1:0] [INPUT_SIZE-1:0] in_data,
    input logic     [1:0] [31:0] in_tag,
    input logic     [1:0] in_valid,
    input logic     [1:0] in_last_processed,
    input logic     [1:0] [63:0] in_serialnum,
    input logic     [1:0] in_was_joined,

    input logic     out_ready_0,
    output logic    [INPUT_SIZE-1:0] out_data_0,
    output logic    [31:0] out_tag_0,
    output logic    out_valid_0,
    output logic    out_last_processed_0,
    output logic    [63:0] out_serialnum_0,
    output logic    out_was_joined_0,

    input logic     out_ready_1,
    output logic    [INPUT_SIZE-1:0] out_data_1,
    output logic    [31:0] out_tag_1,
    output logic    out_valid_1,
    output logic    out_last_processed_1,
    output logic    [63:0] out_serialnum_1,
    output logic    out_was_joined_1
    );

    logic [1:0] Gate0_ready;
    logic [1:0] Gate1_ready;

    logic [1:0] Gate0_masked_valid;
    logic [1:0] Gate1_masked_valid;

    logic  N_last_processed_0;
    logic  N_last_processed_1;

    Gate #(
        .INPUT_SIZE(INPUT_SIZE),
        .decision_bit(decision_bit),
        .ID(0)
    ) Gate_0 (
        .clk(clk),
        .resetn(resetn),
        
        .in_ready(Gate0_ready),
        .in_data(in_data),
        .in_valid(Gate0_masked_valid),
        .in_tag(in_tag),
        .in_last_processed(in_last_processed),
        .in_serialnum(in_serialnum),
        .in_was_joined(in_was_joined),
        
        .ready_4_output(out_ready_0),
        .out_data(out_data_0),
        .out_tag(out_tag_0),
        .out_valid(out_valid_0),
        .out_last_processed(),
        .out_serialnum(out_serialnum_0),
        .out_was_joined(out_was_joined_0)
    );


    Gate #(
        .INPUT_SIZE(INPUT_SIZE),
        .decision_bit(decision_bit),
        .ID(1)
    ) Gate_1 (
        .clk(clk),
        .resetn(resetn),
        
        .in_ready(Gate1_ready),
        .in_data(in_data),
        .in_valid(Gate1_masked_valid),
        .in_tag(in_tag),
        .in_last_processed(in_last_processed),
        .in_serialnum(in_serialnum),
        .in_was_joined(in_was_joined),
        
        .ready_4_output(out_ready_1),
        .out_data(out_data_1),
        .out_tag(out_tag_1),
        .out_valid(out_valid_1),
        .out_last_processed(),
        .out_serialnum(out_serialnum_1),
        .out_was_joined(out_was_joined_1)
    );

always_ff @( posedge clk ) begin : test_last_processed
    out_last_processed_0 <= N_last_processed_0;
    out_last_processed_1 <= N_last_processed_1;
end

always_comb begin
    in_ready[0] <= Gate0_ready[0] & Gate1_ready[0];
    in_ready[1] <= Gate0_ready[1] & Gate1_ready[1];

    Gate0_masked_valid[0] <= in_valid[0] & out_ready_1;
    Gate0_masked_valid[1] <= in_valid[1] & out_ready_1;

    Gate1_masked_valid[0] <= in_valid[0] & out_ready_0;
    Gate1_masked_valid[1] <= in_valid[1] & out_ready_0;

    N_last_processed_0 <=   (&in_last_processed) & (~out_valid_0);
    N_last_processed_1 <=   (&in_last_processed) & (~out_valid_1);
end
endmodule
