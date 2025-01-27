`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2024 05:44:39 PM
// Design Name: 
// Module Name: BarrelShifter
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


module BarrelShifter#(
    parameter NUM_BLOCKS,
    parameter BLOCK_SIZE
)(
    input logic clk,
    input logic rst_n,

    output logic in_ready,
    input logic [(NUM_BLOCKS * BLOCK_SIZE)-1:0] in_data,
    input logic in_valid,
    input logic in_last,
    input logic [31:0] in_num_bytes_valid,

    input logic out_ready,
    output logic [(NUM_BLOCKS * BLOCK_SIZE)-1:0] out_data,
    output logic [((NUM_BLOCKS*BLOCK_SIZE)/8)-1:0] out_keep,
    output logic out_valid,
    output logic out_last

);

logic [(NUM_BLOCKS * BLOCK_SIZE * 2)-1:0] buff;
logic [(NUM_BLOCKS * BLOCK_SIZE * 2)-1:0] N_buff;
logic [(NUM_BLOCKS * BLOCK_SIZE)-1:0] N_out_data;
logic [((NUM_BLOCKS*BLOCK_SIZE)/8)-1:0] N_out_keep;

integer count;
integer N_count;
logic N_out_valid;
logic N_out_last;
logic can_output_stuff;

logic [31:0] debug;

always_ff @( posedge clk ) begin
    if(~rst_n) begin
        out_data <= '0;
        out_keep <= '0;
        out_valid <= 1'b0;
        out_last <= 1'b0;
        buff <= '0;
        count <= 0;
    end
    else begin
        
        out_last <= N_out_last;
        count <= N_count;
        out_valid <= N_out_valid;
        out_keep <= N_out_keep;

        if(can_output_stuff) begin
            buff <= N_buff >> (NUM_BLOCKS * BLOCK_SIZE);
           out_data <= N_buff[NUM_BLOCKS*BLOCK_SIZE-1:0];
        end
        else begin
            buff <= N_buff;
            out_data <= N_out_data;
        end
    end
end


always_comb begin
    in_ready <= 1'b0;
    N_out_data <= out_data;
    N_out_valid <= 1'b0;
    N_out_keep <= '0;
    N_out_last <= 1'b0;
    N_count <= count;
    N_buff <= buff;
    can_output_stuff <= 1'b0;

    if(out_ready) begin
        // We can output stuff next cycle => we can receive new data next cycle 
        in_ready <= 1'b1;
        if(in_valid) begin
            // Input is valid => add it to the buffer
            for(int i = 0; i <= NUM_BLOCKS; i++ ) begin
                if(i<count) begin
                    N_buff[i*BLOCK_SIZE+:BLOCK_SIZE] <= buff[i*BLOCK_SIZE+:BLOCK_SIZE];
                end
                else if(i==count) begin
                    N_buff[i*BLOCK_SIZE+:BLOCK_SIZE*NUM_BLOCKS] <= in_data;
                end
            end
            // Check if we have enough data in buffer to output something next cycle
            if(count + in_num_bytes_valid > NUM_BLOCKS) begin
                // Can output stuff next cycle
                can_output_stuff <= 1'b1;
                N_out_valid <= 1'b1;
                N_out_keep <= '1;
                N_count <= (count + in_num_bytes_valid) - NUM_BLOCKS;
            end
            else begin
                // Cannot output stuff next cycle
                N_count <= count + in_num_bytes_valid;
            end
            
        end
        else if(in_last)begin
            // Input not valid but last signal is set to high => output what is currently in buffer
            can_output_stuff <= 1'b1 & ~out_last;
            N_out_valid <= 1'b1;
            N_count <= 0;
            N_out_last <= 1'b1;
            for(int i=0; i<NUM_BLOCKS; i++) begin
                if(i < count) begin
                    N_out_keep[(i*BLOCK_SIZE/8)+:(BLOCK_SIZE/8)] <= '1;
                end
                else begin
                    N_out_keep[(i*BLOCK_SIZE/8)+:(BLOCK_SIZE/8)] <= '0;
                end
            end
        end
    end
    else begin
        // Not ready for new output => keep all outputs the same and stall input
        in_ready <= 1'b0;
        N_out_valid <= out_valid;
        N_out_keep <= out_keep;
        N_out_last <= out_last;
        N_count <= count;
        N_buff <= buff;
    end        
end
endmodule
