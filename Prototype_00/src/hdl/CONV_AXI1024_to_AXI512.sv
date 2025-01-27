`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2024 12:20:28 PM
// Design Name: 
// Module Name: axi_1024_to_512
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


module CONV_AXI1024_to_AXI512(
    input logic clk,
    input logic rst_n,

    output logic in_ready,
    input logic [1023:0] in_data,
    input logic [127:0] in_keep,
    input logic in_valid,
    input logic in_last,
    
    input logic out_ready,
    output logic [511:0] out_data,
    output logic [63:0] out_keep,
    output logic out_valid,
    output logic out_last

);

typedef enum integer {first_half, second_half} StateType;
StateType state, N_state;

logic [511:0] N_out_data;
logic [63:0] N_out_keep;
logic N_out_valid;
logic N_out_last;

always_ff @(posedge clk) begin
    if(~rst_n) begin
        out_data <= '0;
        out_keep <= '0;
        out_valid <= 1'b0;
        out_last <= 1'b0;
        state <= first_half;
    end
    else begin
        state <= N_state;

        out_data <= N_out_data;
        out_keep <= N_out_keep;
        out_valid <= N_out_valid;
        out_last <= N_out_last;
    end
end

always_comb begin
    in_ready <= 1'b0;
    N_out_data <= out_data;
    N_out_keep <= out_keep;
    N_out_valid <= out_valid;
    N_out_last <= out_last;
    N_state <= state;

    case(state)
	    	first_half: begin
                if(out_ready) begin
                    //Output is ready
                    if(in_valid & ~in_last) begin
                    // We have input and its not the last input => output first half of input next cycle
                        N_out_data <= in_data[511:0];//in_data[1023:512];
                        N_out_keep <= in_keep[63:0];//in_keep[127:64];
                        N_out_valid <= 1'b1;
                    // We then have to stall to output the second half of the input next cycle 
                        in_ready <= 1'b0;
                        N_state <= second_half;
                    end
                    else if(in_valid & in_last) begin
                    // we received the last input
                        N_out_data <= in_data[511:0];//in_data[1023:512];
                        N_out_keep <= in_keep[63:0];//in_keep[127:64];
                        N_out_valid <= 1'b1;

                    // check if it is more than 512 bit
                        if(in_keep[127:64] == '0) begin
                            // If not => set the last_flag when outputting first half
                            N_out_last <= 1'b1;
                        end
                        else begin
                            // Otherwise set last_flag when outputting second half
                            N_state <= second_half;
                            in_ready <= 1'b0;
                        end
                    end
                    else begin
                        // we are ready but there is no valid input => output 0s next cycle
                        in_ready <= 1'b1;
                        N_out_data <= '0;
                        N_out_keep <= '0;
                        N_out_valid <= 1'b0;
                        N_out_last <= out_last;
                        N_state <= state;
                    end
                end
                else begin
                        //Output is not ready => we need to stall and keep all outputs as they are
                        in_ready <= 1'b0;
                        N_out_data <= out_data;
                        N_out_keep <= out_keep;
                        N_out_valid <= out_valid;
                        N_out_last <= out_last;
                        N_state <= state;

                end
            end

            second_half: begin
                if(out_ready) begin
                    // Out is ready => we can output second half of the input received in the previous cycle
                    N_out_data <= in_data[1023:512];//in_data[511:0];
                    N_out_keep <= in_keep[127:64];//in_keep[63:0];
                    N_out_valid <= 1'b1;
                    N_out_last <= in_last;
                    N_state <= first_half;
                    in_ready <= 1'b1;
                end
                else begin
                    // Out is not ready => we have to stall
                    in_ready <= 1'b0;
                    N_out_data <= out_data;
                    N_out_keep <= out_keep;
                    N_out_valid <= out_valid;
                    N_out_last <= out_last;
                    N_state <= state;
                end
            end
    endcase
end

endmodule
