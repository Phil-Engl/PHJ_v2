`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: DD8_3bit
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: module has 8 inputs for tuples and forwards tuples according to the [n-th,(n-1)th,(n-2)th] bit of their hash digest to either of the 8 outputs
// 
// Dependencies: DD8, DD4, DD2
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DD8_3bit#(
  parameter INPUT_SIZE = 64,
  parameter decision_bit = 31
)
    (
    input logic clk,
    input logic resetn,

    output logic  [7:0] in_ready,
    input logic   [7:0] [INPUT_SIZE-1:0] in_data,
    input logic   [7:0][31:0] in_tag,
    input logic   [7:0] in_valid,
    input logic   [7:0] in_last_processed,
    input logic   [7:0] [63:0] in_serialnum,
    input logic   [7:0] in_was_joined,

    input logic   [7:0] out_ready,
    output logic  [7:0][INPUT_SIZE-1:0] out_data,
    output logic  [7:0][31:0] out_tag,
    output logic  [7:0] out_valid,
    output logic  [7:0] out_last_processed,
    output logic  [7:0] [63:0] out_serialnum,
    output logic  [7:0] out_was_joined
    );

 logic [7:0] tmp_ready;
 logic [7:0] [INPUT_SIZE-1:0]tmp_data;
 logic [7:0] [31:0]tmp_tag;
 logic [7:0] tmp_valid;
 logic [7:0] tmp_last_processed;
 logic [7:0] [63:0]tmp_serialnum;
 logic [7:0] tmp_was_joined;

DD8 #(
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

DD4_2bit #(
    .INPUT_SIZE(INPUT_SIZE),
    .decision_bit(decision_bit-1)
  ) L2_0 (
    .clk(clk),
    .resetn(resetn),

    .in_ready(tmp_ready[3:0]),
    .in_data(tmp_data[3:0]),
    .in_valid(tmp_valid[3:0]),
    .in_tag(tmp_tag[3:0]),
    .in_last_processed(tmp_last_processed[3:0]),
    .in_serialnum(tmp_serialnum[3:0]),
    .in_was_joined(tmp_was_joined[3:0]),

    .out_ready(out_ready[3:0]),
    .out_data(out_data[3:0]),
    .out_tag(out_tag[3:0]),
    .out_valid(out_valid[3:0]),
    .out_last_processed(out_last_processed[3:0]),
    .out_serialnum(out_serialnum[3:0]),
    .out_was_joined(out_was_joined[3:0])
  );

  DD4_2bit #(
    .INPUT_SIZE(INPUT_SIZE),
    .decision_bit(decision_bit-1)
  ) L2_1 (
    .clk(clk),
    .resetn(resetn),

    .in_ready(tmp_ready[7:4]),
    .in_data(tmp_data[7:4]),
    .in_valid(tmp_valid[7:4]),
    .in_tag(tmp_tag[7:4]),
    .in_last_processed(tmp_last_processed[7:4]),
    .in_serialnum(tmp_serialnum[7:4]),
    .in_was_joined(tmp_was_joined[7:4]),

    .out_ready(out_ready[7:4]),
    .out_data(out_data[7:4]),
    .out_tag(out_tag[7:4]),
    .out_valid(out_valid[7:4]),
    .out_last_processed(out_last_processed[7:4]),
    .out_serialnum(out_serialnum[7:4]),
    .out_was_joined(out_was_joined[7:4])
  );
endmodule
