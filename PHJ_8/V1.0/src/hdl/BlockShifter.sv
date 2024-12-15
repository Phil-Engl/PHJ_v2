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
    input logic [1:0] [BLOCK_SIZE*MAX_NUM_BLOCKS-1:0] in_data,
    input logic [1:0] in_valid,
    input logic [1:0] [31:0] in_num,
    input logic [1:0] in_last,

    input logic ready_4_output,
    output logic [(2*MAX_NUM_BLOCKS*BLOCK_SIZE)-1:0] out_data,
    output logic out_valid,
    output logic [31:0] out_num, 
    output logic out_last
    );

logic [(2*MAX_NUM_BLOCKS*BLOCK_SIZE)-1:0] N_out_data;
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

    N_out_valid <= in_valid[0] | in_valid[1];
    N_out_last <= in_last[0] & in_last[1];

    // IS IT STILL CORRECT IF I DO THIS????????
    N_out_data <= '0;
    N_out_num <= 0;

    if(in_valid[0] & in_valid[1]) begin
        N_out_num <= in_num[0] + in_num[1];


        for(int i=0; i<MAX_NUM_BLOCKS*BLOCK_SIZE; i++) begin
            if(i<in_num[0]*BLOCK_SIZE) begin
                N_out_data[i] <= in_data[0][i];
            end
        end

        for(int j=0; j<2*MAX_NUM_BLOCKS*BLOCK_SIZE; j++) begin
            for(int i=0; i<MAX_NUM_BLOCKS*BLOCK_SIZE; i++) begin
                if(j == in_num[0] * BLOCK_SIZE + i) begin
                    N_out_data[j] <= in_data[1][i];
                end
            end
        end

        
    end
    else if(in_valid[0] & ~in_valid[1]) begin
        N_out_num <= in_num[0];

        for(int i=0; i<MAX_NUM_BLOCKS*BLOCK_SIZE; i++) begin
            if(i<in_num[0]*BLOCK_SIZE) begin
                N_out_data[i] <= in_data[0][i];
            end
        end

    end
    else if(~in_valid[0] & in_valid[1]) begin
        N_out_num <= in_num[1];
        for(int i=0; i<MAX_NUM_BLOCKS*BLOCK_SIZE; i++) begin
            if(i<in_num[1]*BLOCK_SIZE) begin
                N_out_data[i] <= in_data[1][i];
            end
        end

    end
    else begin
        N_out_data <= '0;
        N_out_num <= 0;
    end



    /*for(int i=0; i<2*MAX_NUM_BLOCKS; i++) begin

        if(in_valid[0] & in_valid[1]) begin
            // Both inputs are valid
            if(i < in_num[0]) begin
                //Output block from first input
                N_out_data[i*BLOCK_SIZE+:BLOCK_SIZE] <= in_data[0][i*BLOCK_SIZE+:BLOCK_SIZE];
            end
            if(i < in_num[1]) begin
                //Output block from second input
                N_out_data[(i+in_num[0])*BLOCK_SIZE+:BLOCK_SIZE] <= in_data[1][i*BLOCK_SIZE+:BLOCK_SIZE];
            end
            //Fill remainder of output with 0s
            if(i >= in_num[0] + in_num[1]) begin
                N_out_data[i*BLOCK_SIZE+:BLOCK_SIZE] <= '0;
            end
            // Number of output blocks is sum of input blocks from both inputs
            N_out_num <= in_num[0] + in_num[1];
        end
        else if(in_valid[0]) begin
            // Only first input is valid
            if(i < in_num[0]) begin
                // Output first input block
                N_out_data[i*BLOCK_SIZE+:BLOCK_SIZE] <= in_data[0][i*BLOCK_SIZE+:BLOCK_SIZE];
            end
            else begin
                // Fill remainder of output with 0s
                N_out_data[i*BLOCK_SIZE+:BLOCK_SIZE] <= '0;
            end
            // Number of output blocks is number of input blocks received from first input
            N_out_num <= in_num[0];
        end
        else if(in_valid[1]) begin
            // Only second input is valid
            if(i < in_num[1]) begin
                // Output second input block
                N_out_data[i*BLOCK_SIZE+:BLOCK_SIZE] <= in_data[1][i*BLOCK_SIZE+:BLOCK_SIZE];
            end
            else begin
                //append 0s
                N_out_data[i*BLOCK_SIZE+:BLOCK_SIZE] <= '0;
            end
            //Number of output blocks is number of input blocks received on second input
            N_out_num <= in_num[1];
        end
        else begin
            // No valid input given => output 0s in next cycle
            N_out_data[i*BLOCK_SIZE+:BLOCK_SIZE] <= '0;
            N_out_num <= 0;
        end
    end*/

end

endmodule