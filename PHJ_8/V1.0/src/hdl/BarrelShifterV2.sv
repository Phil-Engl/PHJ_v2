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


module BarrelShifterV2#(
    parameter NUM_BYTES = 64
)(
    input logic clk,
    input logic rst_n,

    output logic in_ready,
    input logic [(NUM_BYTES*8)-1:0] in_data,
    input logic in_valid,
    input logic in_last,
    input logic [31:0] in_num_bytes_valid,

    input logic out_ready,
    output logic [(NUM_BYTES*8)-1:0] out_data,
    output logic [NUM_BYTES-1:0] out_keep,
    output logic out_valid,
    output logic out_last

);

logic [(NUM_BYTES * 8)-1:0] buff;
logic [31:0] count;
logic [31:0] num_missing;

logic [(NUM_BYTES * 8)-1:0] N_buff;
logic [31:0] N_count;

logic [NUM_BYTES*8-1:0] N_out_data;
logic [NUM_BYTES-1:0] N_out_keep;
logic N_out_valid;
logic N_out_last;

logic [31:0] debug;

always_ff @( posedge clk ) begin
    if(~rst_n) begin
        out_data <= '0;
        out_keep <= '0;
        out_valid <= 1'b0;
        out_last <= 1'b0;
        buff <= '0;
        count <= 0;
        num_missing <= 0;
    end
    else begin
        out_data <= N_out_data;
        out_keep <= N_out_keep;
        out_valid <= N_out_valid;
        out_last <= N_out_last;

        buff <= N_buff;
        count <= N_count;
        num_missing <= (NUM_BYTES - N_count);
    end
end


always_comb begin
    if(out_ready) begin
        // We can output stuff next cycle
        in_ready <= 1'b1;
        if(in_valid) begin
            //Input is valid        
            if(in_num_bytes_valid > num_missing) begin
                // Input is strictly larger than what we are missing => we can output 512 bits next cycle and still have some in the buffer
                    debug <= 1;
                    for(int i=0; i<NUM_BYTES; i++) begin
                        if(i < count) begin
                            // First output what is in the buffer
                            N_out_data[i*8+:8] <= buff[i*8+:8];
                        end

                        if(i < num_missing) begin
                            // Append enough of the current input to fill 512 bits
                            N_out_data[(i+count)*8 +:8] <= in_data[i*8 +:8];
                        end
                        else begin
                            // Put the input bytes that we cannot output next cycle into the buffer
                            N_buff[(i-num_missing)*8 +:8] <= in_data[i*8 +:8];
                        end
                    end
                    // Set valid, keep and last
                    N_out_keep <= '1;
                    N_out_valid <= 1'b1;
                    N_out_last <= 1'b0;
                    // Calculate the number of valid bytes in our buffer for the next cycle
                    N_count <= (count + in_num_bytes_valid) - NUM_BYTES; // we output NUM_BYTES bytes...
                end
                
            else if (in_last) begin
                // Input is valid, less or equal to num_missing, and is the last input we will receive => output buffer + current input
                debug <= 2;
                for(int i=0; i<NUM_BYTES; i++) begin
                    if(i<count) begin
                        // Output buffer
                        N_out_data[i*8 +:8] <= buff[i*8 +:8];
                        N_out_keep[i] <= 1'b1;
                    end

                    if(i<in_num_bytes_valid) begin
                        // Output current input
                        N_out_data[(count + i)*8 +:8] <= in_data[i*8 +:8];
                        N_out_keep[count + i] <= 1'b1;
                    end
                    else begin
                        // Append 0s to fill 512 bits
                        N_out_data[(count + i)*8 +:8] <= '0;
                        N_out_keep[count + i] <= 1'b0;
                    end
                end
                // Set valid and last
                N_out_valid <= 1'b1;
                N_out_last <= 1'b1;
                N_count <= 0;
            end

            else begin
                //Input is valid but not enough s.t. we can output 512 bits next cycle => we simply add input to current buffer
                debug <= 3;
                for(int i=0; i<NUM_BYTES; i++) begin
                    if(i<count) begin
                        // Current buffer
                        N_buff[i*8 +:8] <=buff[i*8 +:8];
                    end

                    if(i<in_num_bytes_valid) begin
                        // Add current input
                        N_buff[(count+i)*8 +:8] <= in_data[i*8 +:8];
                    end                    
                end
                // Set valid, last and keep
                N_out_last <= 1'b0;
                N_out_valid <= 1'b0;
                N_out_keep <= '0;
                // Output 0s...
                N_out_data <= '0;
                // Caclulate number of bytes in our buffer for next cycle
                N_count <= count + in_num_bytes_valid;
            end

        
        end
        else if (in_last & count > 0) begin
            // We will receive no further input but we have some in our buffer => output buffer next cycle and set last flag
            debug <= 4;
            for(int i=0; i<NUM_BYTES; i++) begin
                    if(i<count) begin
                        // Output buffer
                        N_out_data[i*8 +:8] <= buff[i*8 +:8];
                        N_out_keep[i] <= 1'b1;
                    end
                    else begin
                        // Append 0s
                        N_out_data[i*8 +:8] <= '0;
                        N_out_keep[i] <= 1'b0;
                    end
                end
                // Set valid and last bits
                N_out_valid <= 1'b1;
                N_out_last <= 1'b1;
                N_count <= 0;
        end

        else begin 
            // We got no valid input => cannot output anything next cycle
            debug <= 5;
            // Output 0s
            N_out_data <= 512'b0;
            N_out_keep <= 64'b0;

            // Set valid and last
            N_out_valid <= 1'b0;
            N_out_last <= 1'b0;
            
            //Keep count and buffer as they are
            N_count <= count;
            N_buff <= buff;
        end
    end
    else begin
        // Output not ready => we need to stall and keep all outputs as they currently are
        in_ready <= 1'b0;
        N_out_data <= out_data;
        N_out_valid <= out_valid;
        N_out_keep <= out_keep;
        N_out_last <= out_last;
        N_count <= count;
        N_buff <= buff;
       
    end
end
    
endmodule
