`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2024 03:35:52 PM
// Design Name: 
// Module Name: BlockShifter
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


module BlockShifter#(
    parameter BLOCK_SIZE = 64,
    parameter MAX_NUM_BLOCKS = 1
)(
    input logic clk,
    input logic rst_n,

    output logic [1:0] in_ready,
    input logic [1:0] [MAX_NUM_BLOCKS-1:0][BLOCK_SIZE-1:0] in_data,
    input logic [1:0] in_valid,
    input logic [1:0] [31:0] in_num,
    input logic [1:0] in_last,

    input logic ready_4_output,
    output logic [2*MAX_NUM_BLOCKS-1:0][BLOCK_SIZE-1:0] out_data,
    output logic out_valid,
    output logic [31:0] out_num, 
    output logic out_last
    );

logic [2*MAX_NUM_BLOCKS-1:0][BLOCK_SIZE-1:0] N_out_data;
logic N_out_valid;
logic [31:0] N_out_num;
logic N_out_last;

always_ff @(posedge clk) begin
    if(~rst_n) begin
        out_data <= '0;
        out_valid <= 0;
        out_num <= 0;
        out_last <= 1'b0;
    end
    else begin
        out_data <= N_out_data;
        out_valid <= N_out_valid;
        out_num <= N_out_num;
        out_last <= N_out_last;
    end
end

always_comb begin

    in_ready[0] <= ready_4_output;
    in_ready[1] <= ready_4_output;

    N_out_data <= '0;

    if(ready_4_output) begin
        N_out_valid <= in_valid[0] | in_valid[1];
        N_out_last <= in_last[0] & in_last[1];

        if(in_valid[0] & in_valid[1]) begin
            N_out_num <= in_num[0] + in_num[1];
        end
        else if (in_valid[0]) begin
            N_out_num <= in_num[0];
        end
        else if(in_valid[1]) begin
            N_out_num <= in_num[1];
        end
        else begin
            N_out_num <= 0;
        end

        for(int i=0; i<MAX_NUM_BLOCKS; i++) begin
            if(in_valid[0] & (i<in_num[0])) begin
                N_out_data[i] <= in_data[0][i];
            end
        end

        for(int j=0; j<2*MAX_NUM_BLOCKS; j++) begin
            for(int i=0; i<MAX_NUM_BLOCKS; i++) begin
                if(in_valid[1] & (i<in_num[1]))begin
                    if(j == in_num[0] + i) begin
                        N_out_data[j] <= in_data[1][i];
                    end
                end
            end
        end
    end
    else begin
        N_out_data <= out_data;
        N_out_valid <= out_valid;
        N_out_num <= out_num;
        N_out_last <= out_last;
    end

end

endmodule