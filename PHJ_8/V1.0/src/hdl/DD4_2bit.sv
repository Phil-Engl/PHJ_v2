`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: DD4_2bit
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: module has 4 inputs for tuples and forwards tuples according to the n-th and (n-1)th bit of their hash digest to either of the 4 outputs
// 
// Dependencies: DD4, DD2
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DD4_2bit#(
    parameter INPUT_SIZE = 64,
    parameter decision_bit = 1
    )(
    input logic clk,
    input logic resetn,

    output logic [3:0] in_ready,
    input logic [3:0] [INPUT_SIZE-1:0] in_data,
    input logic [3:0] [31:0] in_tag,
    input logic [3:0] in_valid,
    input logic [3:0] in_last_processed,
    input logic [3:0][63:0] in_serialnum,
    input logic [3:0] in_was_joined,

    input logic [3:0] out_ready,
    output logic [3:0][INPUT_SIZE-1:0] out_data,
    output logic [3:0][31:0] out_tag,
    output logic [3:0]out_valid,
    output logic [3:0]out_last_processed,
    output logic [3:0][63:0] out_serialnum,
    output logic [3:0] out_was_joined
    );

    logic [3:0] tmp_ready;
    logic [3:0] [INPUT_SIZE-1:0] tmp_data;
    logic [3:0] [31:0] tmp_tag;
    logic [3:0] tmp_valid;
    logic [3:0] tmp_last_processed;
    logic [3:0][63:0] tmp_serialnum;
    logic [3:0] tmp_was_joined;

DD4 #(
    .INPUT_SIZE(INPUT_SIZE),
    .decision_bit(decision_bit)
  ) L1 (
    .clk(clk),
    .resetn(resetn),

    .in_ready(in_ready),
    .in_data(in_data),
    .in_tag(in_tag),
    .in_valid(in_valid),
    .in_last_processed(in_last_processed),
    .in_serialnum(in_serialnum),
    .in_was_joined(in_was_joined),

    .out_ready(tmp_ready),
    .out_data(tmp_data),
    .out_tag(tmp_tag),
    .out_valid(tmp_valid),
    .out_last_processed(tmp_last_processed),
    .out_serialnum(tmp_serialnum),
    .out_was_joined(tmp_was_joined)
  );


  DD2 #(
    .INPUT_SIZE(INPUT_SIZE),
    .decision_bit(decision_bit-1)
)L2_0(
    .clk(clk),
    .resetn(resetn),
    
    .in_ready(tmp_ready[1:0]),
    .in_data(tmp_data[1:0]),
    .in_valid(tmp_valid[1:0]),
    .in_tag(tmp_tag[1:0]),
    .in_last_processed(tmp_last_processed[1:0]),
    .in_serialnum(tmp_serialnum[1:0]),
    .in_was_joined(tmp_was_joined[1:0]),

    .out_ready_0(out_ready[0]),
    .out_data_0(out_data[0]),
    .out_tag_0(out_tag[0]),
    .out_valid_0(out_valid[0]),
    .out_last_processed_0(out_last_processed[0]),
    .out_serialnum_0(out_serialnum[0]),
    .out_was_joined_0(out_was_joined[0]),

    .out_ready_1(out_ready[1]),
    .out_data_1(out_data[1]),
    .out_tag_1(out_tag[1]),
    .out_valid_1(out_valid[1]),
    .out_last_processed_1(out_last_processed[1]),
    .out_serialnum_1(out_serialnum[1]),
    .out_was_joined_1(out_was_joined[1])
);

DD2 #(
    .INPUT_SIZE(INPUT_SIZE),
    .decision_bit(decision_bit-1)
)L2_1(
    .clk(clk),
    .resetn(resetn),
    
    .in_ready(tmp_ready[3:2]),
    .in_data(tmp_data[3:2]),
    .in_valid(tmp_valid[3:2]),
    .in_tag(tmp_tag[3:2]),
    .in_last_processed(tmp_last_processed[3:2]),
    .in_serialnum(tmp_serialnum[3:2]),
    .in_was_joined(tmp_was_joined[3:2]),

    .out_ready_0(out_ready[2]),
    .out_data_0(out_data[2]),
    .out_tag_0(out_tag[2]),
    .out_valid_0(out_valid[2]),
    .out_last_processed_0(out_last_processed[2]),
    .out_serialnum_0(out_serialnum[2]),
    .out_was_joined_0(out_was_joined[2]),

    .out_ready_1(out_ready[3]),
    .out_data_1(out_data[3]),
    .out_tag_1(out_tag[3]),
    .out_valid_1(out_valid[3]),
    .out_last_processed_1(out_last_processed[3]),
    .out_serialnum_1(out_serialnum[3]),
    .out_was_joined_1(out_was_joined[3])
);
endmodule
