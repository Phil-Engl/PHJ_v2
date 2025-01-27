`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: Gate
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: module has 2 inputs for tuples and either forwards tuples with n-th bit of the hash digest set to low or to high.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Gate #(
    parameter INPUT_SIZE = 64,
    parameter ID = 0,
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
    input logic     [1:0] other_gate_ready,

    input logic     ready_4_output,
    output logic    [INPUT_SIZE-1:0] out_data,
    output logic    [31:0] out_tag,
    output logic    out_valid,
    output logic    [63:0] out_serialnum,
    output logic    out_last_processed,
    output logic    out_was_joined
    );

typedef enum integer {a_precedence, b_precedence} StateType;
StateType State, nextState;

logic [INPUT_SIZE-1:0] NextOutput;
logic NextOutValid;

logic [31:0] NextOutTag;
logic Next_last_processed;
logic [63:0] Next_serialnum;
logic N_out_was_joined;

always_ff@(posedge clk) begin
    	if(~resetn) begin
            State <= a_precedence;
            out_data <= '0;
            out_tag <= '0;
            out_valid <= 1'b0;
            out_last_processed <= 1'b0;
            out_serialnum <= 0;
            out_was_joined <= 0;
        end
    	else begin
            State <= nextState;
            out_data <= NextOutput;
            out_tag <= NextOutTag;
            out_valid <= NextOutValid;
            out_last_processed <= Next_last_processed;
            out_serialnum <= Next_serialnum;
            out_was_joined <= N_out_was_joined;
    	end
    end


always_comb begin
    nextState <= State;

    NextOutput <= out_data;
    NextOutTag <= out_tag;
    Next_serialnum <= out_serialnum;
    N_out_was_joined <= out_was_joined;
    NextOutValid <= out_valid;
    Next_last_processed <= 1'b0;

    in_ready[0] <= 1'b1;
    in_ready[1] <= 1'b1;

    case(State)
            a_precedence: begin
                if(ready_4_output) begin
                    if((in_valid[0] & in_tag[0][decision_bit] == ID[0]) & (in_valid[1] & in_tag[1][decision_bit] == ID[0]) )begin
                        // Both inputs are valid and a has precedence => forward input a and stall input b
                        nextState <= b_precedence;
                        NextOutput <= in_data[0];
                        NextOutTag <= in_tag[0];
                        Next_serialnum <= in_serialnum[0];
                        N_out_was_joined <= in_was_joined[0];
                        NextOutValid <= 1'b1;            
                        
                        in_ready[1] <= 1'b0;
                    end
                    else if(in_valid[0] & in_tag[0][decision_bit] == ID[0]) begin
                        // Only input a is valid => forward it (no stalls needed)
                        nextState <= b_precedence;
                        NextOutput <= in_data[0];
                        NextOutTag <= in_tag[0];
                        Next_serialnum <= in_serialnum[0];
                        N_out_was_joined <= in_was_joined[0];
                        NextOutValid <= 1'b1;     

                    end
                    else if(in_valid[1] & in_tag[1][decision_bit] == ID[0] ) begin
                        // Only input b is valid => forward it (no stalls needed)
                        nextState <= a_precedence;
                        NextOutput <= in_data[1];
                        NextOutTag <= in_tag[1];
                        Next_serialnum <= in_serialnum[1];
                        N_out_was_joined <= in_was_joined[1];
                        NextOutValid <= 1'b1;
                    end
                    else begin
                        // No valid input is given => cannot output anything valid next cycle
                        NextOutput <= '0;
                        NextOutTag <= '0;
                        Next_serialnum <= '0;
                        N_out_was_joined <= '0;
                        NextOutValid <= 1'b0;     
                    end
                end
                else begin
                    // Not ready for new output => stall inputs
                    in_ready[0] <= 1'b0;
                    in_ready[1] <= 1'b0;
                end
                
                
            end
            b_precedence: begin
                if(ready_4_output) begin
                    if ((in_valid[1] & in_tag[1][decision_bit] == ID[0]) & (in_valid[0] & in_tag[0][decision_bit] == ID[0])) begin
                        // Both inputs are valid and b has precedence => forward input b and stall input a
                        nextState <= b_precedence;
                        NextOutput <= in_data[1];
                        NextOutTag <= in_tag[1];
                        Next_serialnum <= in_serialnum[1];
                        N_out_was_joined <= in_was_joined[1];
                        NextOutValid <= 1'b1;
                        
                        in_ready[0] <= 1'b0;
                    end
                    else if(in_valid[1] & in_tag[1][decision_bit] == ID[0]) begin
                        // Only input b is valid => forward it (no stalls needed)
                        nextState <= b_precedence;
                        NextOutput <= in_data[1];
                        NextOutTag <= in_tag[1];
                        Next_serialnum <= in_serialnum[1];
                        N_out_was_joined <= in_was_joined[1];
                        NextOutValid <= 1'b1;
                    end
                    else if(in_valid[0] & in_tag[0][decision_bit] == ID[0] ) begin
                        // Only input a is valid => forward it (no stalls needed)
                        nextState <= a_precedence;
                        NextOutput <= in_data[0];
                        NextOutTag <= in_tag[0];
                        Next_serialnum <= in_serialnum[0];
                        N_out_was_joined <= in_was_joined[0];
                        NextOutValid <= 1'b1;
                    end
                    else begin
                        // No valid input is given => cannot output anything valid next cycle
                        NextOutput <= '0;
                        NextOutTag <= '0;
                        Next_serialnum <= '0;
                        N_out_was_joined <= '0;
                        NextOutValid <= 1'b0;
                    end
                end
                else begin
                    // Not ready for new output => stall inputs
                    in_ready[0] <= 1'b0;
                    in_ready[1] <= 1'b0;
                end        
            end   
    endcase
end
endmodule