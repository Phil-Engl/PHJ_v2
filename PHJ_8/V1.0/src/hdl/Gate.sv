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


module Gate_old #(
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

    input logic     ready_4_output,
    output logic    [INPUT_SIZE-1:0] out_data,
    output logic    [31:0] out_tag,
    output logic    out_valid,
    output logic    [63:0] out_serialnum,
    output logic    out_last_processed,
    output logic    out_was_joined
    );

typedef enum int {Init = 0, Work = 1, Stalled_A = 2, Stalled_B = 3} StateType;
StateType State, nextState;

logic [INPUT_SIZE-1:0] NextOutput;
logic NextOutValid;
logic a_Nready;
logic b_Nready;
logic preference;
logic NextPreference;
logic [31:0] NextOutTag;
logic Next_last_processed;
logic [63:0] Next_serialnum;
logic N_out_was_joined;

always_ff@(posedge clk) begin
    	if(~resetn) begin
    		State <= Init;
            preference <= 0;
            out_data <= '0;
            out_valid <= 1'b0;
            out_tag <= '0;
            out_last_processed <= 1'b0;
            out_serialnum <= 0;
            out_was_joined <= 0;
        end
    	else begin
            
            if(ready_4_output | ~out_valid) begin
                State <= nextState;
                preference <= NextPreference;
                out_data <= NextOutput;
                out_tag <= NextOutTag;
                out_valid <= NextOutValid;
                out_last_processed <= Next_last_processed;
                out_serialnum <= Next_serialnum;
                out_was_joined <= N_out_was_joined;
            end
            else begin
                State <= State;
                preference <= preference;
                out_data <= out_data;
                out_tag <= out_tag;
                out_valid <= out_valid;
                out_last_processed <= out_last_processed;
                out_serialnum <= out_serialnum;
                out_was_joined <= out_was_joined;
            end
    	end
    end


always_comb begin
    NextOutput <= '0;
    NextOutValid <= 1'b0;
    NextOutTag <= '0;
    //Next_last_processed <= 1'b0;
    Next_serialnum <= 0;
    N_out_was_joined <= 0;

    in_ready[0] <= (ready_4_output | ~out_valid);
    in_ready[1] <= (ready_4_output | ~out_valid);

    //NextPreference <= preference;
    //nextState <= State;
    //Next_last_processed <= out_last_processed;

    case(State)
	    Init: begin
            NextPreference <= 1;
            NextOutput <= '0;
            NextOutValid <= 1'b0;
            NextOutTag <= '0;
            //out_was_joined <= 0;
            nextState <= Work;
            Next_last_processed <= 1'b0;
        end

        Work: begin
            if (in_valid[0] & in_valid[1] & in_tag[0][decision_bit] == ID[0] & in_tag[1][decision_bit] == ID[0]) begin
                    // Input b has currently preference
                    if(preference == 0) begin
                        nextState <= Work;
                        NextOutput <= in_data[1];
                        NextOutTag <= in_tag[1];
                        Next_serialnum <= in_serialnum[1];
                        NextOutValid <= 1'b1;
                        NextPreference <= 1;
                        in_ready[0] <= 1'b0;
                        N_out_was_joined <= in_was_joined[1];
                    end
                    // Input a has currently preference
                    else begin
                        nextState <= Work;
                        NextOutput <= in_data[0];
                        NextOutTag <= in_tag[0];
                        Next_serialnum <= in_serialnum[0];
                        NextOutValid <= 1'b1;
                        NextPreference <= 0;
                        in_ready[1] <= 1'b0;
                        N_out_was_joined <= in_was_joined[0];
                    end
                end
            // Work to do just for input a
            else if (in_valid[0] & in_tag[0][decision_bit] == ID[0]) begin  
                NextOutput <= in_data[0];
                NextOutTag <= in_tag[0];
                Next_serialnum <= in_serialnum[0];
                N_out_was_joined <= in_was_joined[0];
                NextOutValid <= 1'b1;
                NextPreference <= 0;
                /*if(in_last_processed[0] & in_last_processed[1]) begin
                    Next_last_processed <= 1'b1;
                end*/
            end
            // Work to do just for input b
            else if (in_valid[1] & in_tag[1][decision_bit] == ID[0]) begin  
                NextOutput <= in_data[1];
                NextOutTag <= in_tag[1];
                Next_serialnum <= in_serialnum[1];
                N_out_was_joined <= in_was_joined[1];
                NextOutValid <= 1'b1;
                NextPreference <= 1;
                /*if(in_last_processed[0] & in_last_processed[1]) begin
                    Next_last_processed <= 1'b1;
                end*/
            end
            else if(~in_valid[0] & in_last_processed[0] & ~in_valid[1] & in_last_processed[1]) begin
                Next_last_processed <= 1'b1;
            end
        end

    endcase
end

endmodule