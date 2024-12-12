`timescale 1ns / 1ps

import lynxTypes::*;
import common::*;

module CompressionArbiter (
    input logic clk,
    input logic rst_n,

    AXI4SR.s axis_host_recv,
    AXI4SR.m axis_host_send
);


localparam INPUT_SIZE = 64;
localparam ROW_BITS = 8;
localparam COL_BITS = 2;
localparam MAX_IN_TRANSIT = 16;



logic [511:0] in_data;
logic in_valid;
logic in_ready;
logic in_last;


logic [1023:0] out_data_double;
logic [127:0] out_keep_double;
logic out_valid_double;
logic out_last_double;


logic in_ready_single;
logic [511:0] out_data_single;
logic [63:0] out_keep_single;
logic out_valid_single;
logic out_last_single;

logic out_ready;



Partitioned_Hash_Join #(
        .INPUT_SIZE(INPUT_SIZE),
        .ROW_BITS(ROW_BITS),
        .COL_BITS(COL_BITS),
        .MAX_IN_TRANSIT(MAX_IN_TRANSIT)
    ) uut (
    .clk(clk),
    .resetn(rst_n),
    
    .in_ready(in_ready),
    .in_data(in_data),
    .in_valid({in_valid, in_valid, in_valid, in_valid, in_valid, in_valid, in_valid, in_valid}),
    .in_last(in_last),

    //.out_ready(1'b1),
    .out_ready(in_ready_single),
    //.out_ready(out_ready),
    .out_data(out_data_double),
    .out_valid(out_valid_double),
    .out_last(out_last_double),
    .out_keep(out_keep_double)
    );


axi_1024_to_512V2 uut2(
        .clk(clk),
        .rst_n(rst_n),

        .in_ready(in_ready_single),
        .in_data(out_data_double),
        .in_keep(out_keep_double),
        .in_valid(out_valid_double),
        .in_last(out_last_double),

        .out_ready(out_ready),
        .out_data(out_data_single),
        .out_keep(out_keep_single),
        .out_valid(out_valid_single),
        .out_last(out_last_single)
    );



assign in_data = axis_host_recv.tdata;
assign in_valid = axis_host_recv.tvalid;
assign in_last = axis_host_recv.tlast;
assign axis_host_recv.tready = in_ready;

assign axis_host_send.tdata = out_data_single;
assign axis_host_send.tkeep = out_keep_single;
assign axis_host_send.tvalid = out_valid_single;
assign axis_host_send.tlast = out_last_single;
assign out_ready = axis_host_send.tready;



endmodule
