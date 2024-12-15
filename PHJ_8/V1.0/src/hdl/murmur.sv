`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: murmur
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: compute murmur hash digest of tuples
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module murmur (
    input logic clk,
    input logic resetn,

    output logic in_ready,
    input logic [63:0] in_data,
    input logic in_valid,
    input logic in_last_processed,
    input logic [63:0] in_serialnum,
    
    input logic out_ready,
    output logic [95:0] out_data, 
    output logic out_valid,
    output logic out_last_processed,
    output logic [63:0] out_serialnum
);

parameter KEY_BITS = 32;
parameter PAYLOAD_BITS = 32;
parameter HASH_BITS = 32;

logic valid1, valid2, valid3, valid4, valid5;
logic [KEY_BITS - 1:0] org_key1, org_key2, org_key3, org_key4, org_key5;
logic [PAYLOAD_BITS - 1:0] org_payload1, org_payload2, org_payload3, org_payload4, org_payload5;
logic [KEY_BITS - 1:0] key1, bitshift_key1, xor_key1;
logic [2*KEY_BITS - 1:0] mult_key1;
logic [KEY_BITS - 1:0] key2, bitshift_key2, xor_key2;
logic [2*KEY_BITS - 1:0] mult_key2;
logic [KEY_BITS - 1:0] key3, bitshift_key3, xor_key3;
logic [HASH_BITS-1:0] hash;

logic last_processed1, last_processed2, last_processed3, last_processed4, last_processed5;
logic [63:0] serialnum1;
logic [63:0] serialnum2;
logic [63:0] serialnum3;
logic [63:0] serialnum4;
logic [63:0] serialnum5;

always @(posedge clk) begin
    if (~resetn) begin
        valid1 <= 1'b0;
        valid2 <= 1'b0;
        valid3 <= 1'b0;
        valid4 <= 1'b0;
        valid5 <= 1'b0;

        last_processed1 <= 1'b0;
        last_processed2 <= 1'b0;
        last_processed3 <= 1'b0;
        last_processed4 <= 1'b0;
        last_processed5 <= 1'b0;

    end else begin
        if(out_ready) begin
            xor_key1 <= key1 ^ bitshift_key1;
            mult_key1 <= (KEY_BITS == 32) ? (xor_key1 * 32'h85ebca6b) : (xor_key1 * 64'hff51afd7ed558ccd);
            
            xor_key2 <= key2 ^ bitshift_key2;
            mult_key2 <= (KEY_BITS == 32) ? (xor_key2 * 32'hc2b2ae35) : (xor_key2 * 64'hc4ceb9fe1a85ec53);
            
            xor_key3 <= key3 ^ bitshift_key3;
            
            valid1 <= in_valid;
            valid2 <= valid1;
            valid3 <= valid2;
            valid4 <= valid3;
            valid5 <= valid4;

            org_key1 <= in_data[KEY_BITS-1:0];
            org_key2 <= org_key1;
            org_key3 <= org_key2;
            org_key4 <= org_key3;
            org_key5 <= org_key4;

            org_payload1 <= in_data[PAYLOAD_BITS + KEY_BITS -1: KEY_BITS];
            org_payload2 <= org_payload1;
            org_payload3 <= org_payload2;
            org_payload4 <= org_payload3;
            org_payload5 <= org_payload4;

            last_processed1 <= in_last_processed;
            last_processed2 <= last_processed1;
            last_processed3 <= last_processed2;
            last_processed4 <= last_processed3;
            last_processed5 <= last_processed4;

            serialnum1 <= in_serialnum;
            serialnum2 <= serialnum1;
            serialnum3 <= serialnum2;
            serialnum4 <= serialnum3;
            serialnum5 <= serialnum4;

            out_valid <= valid5;
            //out_data <= {32'b1, org_payload5, org_key5};//{org_key5, org_payload5, org_key5};//{xor_key3[HASH_BITS-1:0], org_payload5, org_key5};
            out_data <= {xor_key3[HASH_BITS-1:0], org_payload5, org_key5};
            out_last_processed <= last_processed5;
            out_serialnum <= serialnum5;
        end
        else begin
            out_valid <= out_valid;
            out_data <= out_data;
            out_last_processed <= out_last_processed;
            
        end
    end
end


// USE ALWAYS_COMB, wenns ned lauft denn stimmt din code ned....
// DES MUSS IRGENDWIA FUNKTIONIERA::!!!!!
// FALLS ZU VIEL ZIT VERLÜRSCH, NIMM EINFACH DA ALWAYS@*

always @* begin
//always_comb begin
        key1 <= in_data[KEY_BITS-1:0];
        bitshift_key1 <= (KEY_BITS == 32) ? (key1 >> 16) : (key1 >> 33);;

        key2 <= mult_key1[KEY_BITS-1:0];
        bitshift_key2 <= (KEY_BITS == 32) ? (key2 >> 13) : (key2 >> 33);

        key3 <= mult_key2[KEY_BITS-1:0];
        bitshift_key3 <= (KEY_BITS == 32) ? (key3 >> 16) : (key3 >> 33);;
end

// USE ASSIGN HERE..!
always_comb begin
    in_ready <= out_ready;
end

endmodule
