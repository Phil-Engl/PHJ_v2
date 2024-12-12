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


module Command_and_Control_multi #(
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


logic [31:0] next;
logic [31:0] N_next;
logic N_last_processed;


logic [31:0] debug;


always_ff @(posedge clk) begin
    if(~resetn) begin
        next <= 0;
        last_processed <= 1'b0;
    end
    else begin
        next <= N_next;
        last_processed <= N_last_processed;
    end
end



always_comb begin
    if(&out_ready) begin
        // All outputs are ready
        if(&in_is_stored) begin
            // All SaR have the next tuple stored => we release it next cycle
            N_next <= next+1;
            release_data <= '1;
            N_last_processed <= last_processed;
            debug <= 1;
        end
        else if(&local_last_processed & ~(|in_is_stored)) begin
            // We cannot output any more tuples and all SaR have processed the last tuple => we are done
            N_last_processed <= 1'b1;
            release_data <= '0;
            N_next = next;
            debug <= 2;
        end
        else begin
            // Cannot output anything next cycle
            release_data <= '0;
            N_next = next;
            N_last_processed <= last_processed;
            debug <= 3;
        end
    end
    else begin
        // Not all outputs are ready => have to invalidate the ones that are ready again!
        release_data <= '0;
        debug <= 4;
        N_next = next;
        N_last_processed <= last_processed;
        for(int i=0; i<NUM_STORAGES; i++) begin
            if(out_ready[i]) begin
                release_data[i] <= 1'b0;
            end
        end
    end
end


endmodule
