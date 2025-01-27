`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2024 12:20:33 PM
// Design Name: 
// Module Name: Command_and_Control
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


module Command_and_Control #(
    parameter NUM_STORAGES = 8
)(
    input logic clk,
    input logic resetn,

    input logic [NUM_STORAGES-1:0] in_is_stored,
    output logic [NUM_STORAGES-1:0] release_data,
    output logic [31:0] next,

    input logic [NUM_STORAGES-1:0] local_last_processed,
    output logic last_processed, 

    input logic [NUM_STORAGES-1:0] out_ready
);

typedef enum integer {Work, Finished} StateType;
StateType State, nextState;

logic [31:0] N_next;
logic N_last_processed;
logic [31:0] debug;

always_ff @(posedge clk) begin
    if(~resetn) begin
        next <= 0;
        last_processed <= 1'b0;
        State <= Work;
    end
    else begin
        State <= nextState;
        next <= N_next;
        last_processed <= N_last_processed;
    end
end

always_comb begin
    N_next <= next;
    release_data <= '0;
    N_last_processed <= 1'b0;
    nextState <= Work;

    case(State)
        Work: begin
            if(&in_is_stored) begin
                // All SaR have the next tuple stored => we release it next cycle
                N_next <= next+1;
                release_data <= '1;
                debug <= 1;
            end
            else if(&local_last_processed & ~(|in_is_stored)) begin
                // We cannot output any more tuples and all SaR have processed the last tuple => we are done
                nextState <= Finished;
                debug <= 2;
            end
        end
        Finished: begin
            nextState <= Finished;
            N_last_processed <= 1'b1;
        end
    endcase
end
endmodule
