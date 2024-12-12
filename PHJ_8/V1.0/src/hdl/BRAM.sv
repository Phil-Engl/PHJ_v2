`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: simple_dual_port_ram_single_clock
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: simple BRAM module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module simple_dual_port_ram_single_clock #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 3
)(
    input logic clk,
    input logic [ADDR_WIDTH-1:0] raddr,
    input logic [ADDR_WIDTH-1:0] waddr,
    input logic [DATA_WIDTH-1:0] data,
    input logic we,
    output logic [DATA_WIDTH-1:0] out
);

    // Define memory array
    logic [DATA_WIDTH-1:0] ram [(1<<ADDR_WIDTH)-1:0];

 
    always_ff @(posedge clk) begin
 
        // Write operation
        if (we) begin
            ram[waddr] <= data;
        end

        // Read operation
        out <= ram[raddr];
    end

endmodule
