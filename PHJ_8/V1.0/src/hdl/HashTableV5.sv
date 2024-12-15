`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: HashTable
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: simple hash table built from BRAM module
// 
// Dependencies: BRAM
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HashTableV4 #(
    parameter TUPLE_SIZE = 64,
    parameter ROW_BITS = 3, 
    parameter COL_BITS = 1
)(
    input logic clk,
    input logic resetn,

    output logic in_ready_BUILD,
    input logic [63:0] in_data_BUILD,
    input logic [31:0] in_hash_BUILD,
    input logic in_valid_BUILD,
    input logic in_last_processed_BUILD,

    output logic in_ready_PROBE,
    input logic [63:0] in_data_PROBE,
    input logic [31:0] in_hash_PROBE,
    input logic in_valid_PROBE,
    input logic in_last_processed_PROBE,
    input logic [63:0] in_serialnum,

    input logic out_ready,
    output logic out_valid,
    output logic [127:0] out_data,
    output logic out_last_processed,
    output logic [63:0] out_serialnum,
    output logic out_was_joined
);

// FÜHR A MODE SIGNAL IH (BUILD AND PROBE) UND MACH DIE INPUTS TUPLE, HASH ETC A WRITE_VERISON UND A READ_VERSION

    integer i;
    integer nextI;
    logic Nready;
	// 32 bits for the counter + tuples_per_row * tuples_size
	localparam DATA_WIDTH = 288;
	localparam NUM_ROWS = 2**ROW_BITS;

    typedef enum integer {Init, Build, Probe} StateType;
    StateType State, nextState;

    logic [127:0] N_out_data;
    logic N_out_valid;
    logic [63:0] N_out_serialnum;
    logic N_out_last_processed;


    logic [ROW_BITS-1:0] raddr;
    logic [ROW_BITS-1:0] raddr1;

    logic [63:0] tmp2_tuple_PROBE;
    logic [63:0] tmp1_tuple_PROBE;
    logic [63:0] tmp_tuple_PROBE;

    logic tmp2_valid_PROBE;
    logic tmp1_valid_PROBE;
    logic tmp_valid_PROBE;

    logic tmp2_last_PROBE;
    logic tmp1_last_PROBE;
    logic tmp_last_PROBE;

    logic [63:0] tmp2_serialnum;
    logic [63:0] tmp1_serialnum;
    logic [63:0] tmp_serialnum;


    logic [63:0] tmp2_tuple_BUILD;
    logic [63:0] tmp1_tuple_BUILD;
    logic [63:0] tmp_tuple_BUILD;

    logic tmp2_valid_BUILD;
    logic tmp1_valid_BUILD;
    logic tmp_valid_BUILD;

    logic tmp2_last_BUILD;
    logic tmp1_last_BUILD;
    logic tmp_last_BUILD;


    logic [ROW_BITS-1:0] waddr;
    logic [DATA_WIDTH-1:0] data;
    //logic [DATA_WIDTH-1:0] tmp_out_row;
    logic [DATA_WIDTH-1:0] out_row;
    
    //logic [63:0] tuple_tmp;
    //logic [ROW_BITS-1:0] address_tmp;
    //logic [63:0] tmp_serialnum;

    //logic [63:0] tuple_tmp1;
    //logic valid_tmp1;

    //logic [63:0] tmp_serialnum1;

    logic [ROW_BITS-1:0] rw_addr2;
    logic [ROW_BITS-1:0] rw_addr1;
    logic [ROW_BITS-1:0] rw_addr;

    //logic valid_tmp;
    logic we;

    
    logic N_out_was_joined;

    logic N_wrote_two;
    logic wrote_two;

    //logic [ROW_BITS-1:0]

    simple_dual_port_ram_single_clock #(
       	.DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ROW_BITS)
    ) dut (
        .clk(clk),
        .raddr(raddr),
        .waddr(waddr),
        .data(data),
        .we(we),
        .out(out_row)
    );


    always_ff@(posedge clk) begin
    	if(~resetn) begin
    		State <= Init;
            i <= 0;
            out_last_processed <= 1'b0;
            out_valid <= 0;
            out_data <= '0;
            out_serialnum <= '0;
            out_was_joined <= 0;

            wrote_two <= 0;
            //waddr <= '0;
            //raddr <= '0;
    	end
    	else begin
            if(State == Probe) begin
                //waddr <= '0;
                if(out_ready) begin
                    State <= nextState;

                    out_valid <= N_out_valid;
                    out_data <= N_out_data;
                    out_serialnum <= N_out_serialnum;
                    out_last_processed <= N_out_last_processed;
                    out_was_joined <= N_out_was_joined;

                    raddr <= raddr1;

                    tmp1_tuple_PROBE <= tmp2_tuple_PROBE;
                    tmp_tuple_PROBE <= tmp1_tuple_PROBE;

                    tmp1_valid_PROBE <= tmp2_valid_PROBE;
                    tmp_valid_PROBE <= tmp1_valid_PROBE;

                    tmp1_serialnum <= tmp2_serialnum;
                    tmp_serialnum <= tmp1_serialnum;

                    tmp1_last_PROBE <= tmp2_last_PROBE;
                    tmp_last_PROBE <= tmp1_last_PROBE;
                end
                else begin
                    State <= nextState;

                    out_valid <= out_valid;
                    out_data <= out_data;
                    out_serialnum <= out_serialnum;
                    out_last_processed <= out_last_processed;
                    out_was_joined <= out_was_joined;

                    raddr <= raddr;

                    tmp1_tuple_PROBE <= tmp1_tuple_PROBE;
                    tmp_tuple_PROBE <= tmp_tuple_PROBE;

                    tmp1_valid_PROBE <= tmp1_valid_PROBE;
                    tmp_valid_PROBE <= tmp_valid_PROBE;

                    tmp1_serialnum <= tmp1_serialnum;
                    tmp_serialnum <= tmp_serialnum;

                    tmp1_last_PROBE <= tmp1_last_PROBE;
                    tmp_last_PROBE <= tmp_last_PROBE;
                end
            end
            else if(State == Build) begin
                State <= nextState;

                raddr <= raddr1;
                waddr <= raddr;

                tmp1_tuple_BUILD <= tmp2_tuple_BUILD;
                tmp_tuple_BUILD <= tmp1_tuple_BUILD;

                tmp1_valid_BUILD <= tmp2_valid_BUILD;
                tmp_valid_BUILD <= tmp1_valid_BUILD;

                tmp1_last_BUILD <= tmp2_last_BUILD;
                tmp_last_BUILD <= tmp1_last_BUILD;

                wrote_two <= N_wrote_two;

            end
            else begin
                State <= nextState;
                i <= nextI;
                //waddr <= i;
            end
    	end
    end


    always_comb begin 
        in_ready_BUILD <= 1;
        in_ready_PROBE <= 1;
        nextI <= i;
        we <= 0;
        data <= '0;
        N_wrote_two <= 0;
        raddr1 <= '0;
        //waddr <= '0;

        tmp2_tuple_BUILD <= '0;
        tmp2_valid_BUILD <= 0;
        tmp2_last_BUILD <= 0;

        tmp2_tuple_PROBE <= '0;
        tmp2_valid_PROBE <= 0;
        tmp2_last_PROBE <= 0;
        tmp2_serialnum <= '0;

        //N_out_data <= '0;
        //N_out_was_joined <= 0;
        //N_out_valid <= 0;
        //N_out_serialnum <= '0;
        //N_out_last_processed <= out_last_processed;

	    case(State)
	    	Init: begin
                
                if (i < NUM_ROWS) begin
                    waddr <= i;
                    data <= 0;
                    we <= 1;
                    nextI <= i + 1;
                    nextState <= Init;
                    in_ready_BUILD <= 0;
                    in_ready_PROBE <= 0;
                end else begin
                    nextState <= Build;
                    nextI <= 0; // Reset i for the next reset event
                    in_ready_PROBE <= 0;
                    N_out_last_processed <= 0;
                    in_ready_BUILD <= 0;
                    in_ready_PROBE <= 0;
                end
            end

	        Build: begin
                raddr1 <= in_hash_BUILD[ROW_BITS-1:0];
                tmp2_tuple_BUILD <= in_data_BUILD;
                tmp2_valid_BUILD <= in_valid_BUILD;
                tmp2_last_BUILD <= in_last_processed_BUILD;

                if(~wrote_two) begin
                    //if we wrote two tuples last cycle, we do nothing this cycle
                    if(raddr == waddr & tmp1_valid_BUILD & tmp_valid_BUILD) begin
                        // We have to write the same row two consecutive times => we can do both writes now and do nothing next cycle
                        N_wrote_two <= 1;
                        for(int i=0; i<4; i++) begin 
                            if(i < out_row[287:256]) begin
                                // Keep what was already stored in this row
                                data[(3-i)*64 +: 64] <= out_row[(3-i)*64 +: 64];
                            end
                            else if(i == out_row[287:256]) begin
                                // Add the first tuple
                                data[(3-i)*64 +: 64] <= tmp_tuple_BUILD;
                                // Increment counter by 2
                                data[256+:32] <= i+2;
                            end
                            else if(i == out_row[287:256]+1) begin
                                // add the second tuple
                                data[(3-i)*64 +: 64] <= tmp1_tuple_BUILD;
                            end
                            else begin
                                // Fill remaining space with 0s 
                                data[(3-i)*64 +: 64] <= '0;
                            end
                        end
                        we <= 1;
                    end
                    else begin
                        // We can only write one tuple this cycle (or none if tuple is not valid)
                        for(int i=0; i<4; i++) begin
                            if(i < out_row[287:256]) begin
                                // Keep what was already stored in this row
                                data[(3-i)*64 +: 64] <= out_row[(3-i)*64 +: 64];
                            end
                            else if(i == out_row[287:256]) begin
                                // Add tuple
                                data[(3-i)*64 +: 64] <= tmp_tuple_BUILD;
                                // Increment counter
                                data[256+:32] <= i+1;
                            end
                            else begin 
                                // Fill remaining space with 0s
                                data[(3-i)*64 +: 64] <= '0;
                            end
                        end
                        // Set write enable if the tuple was valid
                        we <= tmp_valid_BUILD;
                    end
                end

                if(tmp_last_BUILD) begin
                    nextState <= Probe;
                end
                else begin
                    nextState <= Build;
                end

	        end

            

            Probe: begin
                in_ready_PROBE <= out_ready;
                nextState <= Probe;
                
                raddr1 <= in_hash_PROBE[ROW_BITS-1:0];
                tmp2_tuple_PROBE <= in_data_PROBE;
                tmp2_valid_PROBE <= in_valid_PROBE;
                tmp2_last_PROBE <= in_last_processed_PROBE;
                tmp2_serialnum <= in_serialnum;

                //if(out_ready) begin
                    /*for(int i=0; i<4; i++) begin
                        if(out_row[(i*64)+:32] == tmp_tuple_PROBE[0+:32] & (out_row[287:256] > (3-i))) begin
                            N_out_data[64+:64] <= out_row[(i*64)+:64];
                            N_out_data[0+:64] <= tmp_tuple_PROBE[0+:64];
                            N_out_was_joined <= 1'b1;
                            N_out_serialnum <= tmp_serialnum;//tmp_serialnum;
                        end
                    end*/

                    if(out_row[0+:32] == tmp_tuple_PROBE[0+:32] & (out_row[287:256] > 3)) begin
                            N_out_data[64+:64] <= out_row[0+:64];
                            N_out_data[0+:64] <= tmp_tuple_PROBE[0+:64];
                            N_out_was_joined <= 1'b1;
                            N_out_serialnum <= tmp_serialnum;//tmp_serialnum;
                            N_out_valid <= tmp_valid_PROBE;
                        end

                    else if(out_row[64+:32] == tmp_tuple_PROBE[0+:32] & (out_row[287:256] > 2)) begin
                            N_out_data[64+:64] <= out_row[64+:64];
                            N_out_data[0+:64] <= tmp_tuple_PROBE[0+:64];
                            N_out_was_joined <= 1'b1;
                            N_out_serialnum <= tmp_serialnum;//tmp_serialnum;
                            N_out_valid <= tmp_valid_PROBE;
                        end

                    else if(out_row[128+:32] == tmp_tuple_PROBE[0+:32] & (out_row[287:256] > 1)) begin
                            N_out_data[64+:64] <= out_row[128+:64];
                            N_out_data[0+:64] <= tmp_tuple_PROBE[0+:64];
                            N_out_was_joined <= 1'b1;
                            N_out_serialnum <= tmp_serialnum;//tmp_serialnum;
                            N_out_valid <= tmp_valid_PROBE;
                        end

                    else if(out_row[192+:32] == tmp_tuple_PROBE[0+:32] & (out_row[287:256] > 0)) begin
                            N_out_data[64+:64] <= out_row[192+:64];
                            N_out_data[0+:64] <= tmp_tuple_PROBE[0+:64];
                            N_out_was_joined <= 1'b1;
                            N_out_serialnum <= tmp_serialnum;//tmp_serialnum;
                            N_out_valid <= tmp_valid_PROBE;
                    end
                    //else if (out_ready) begin
                        //N_out_data <= '0;
                        //N_out_was_joined <= 0;
                        //N_out_valid <= 0;
                        //N_out_serialnum <= '0;
                        //N_out_last_processed <= out_last_processed;

                    //end

                    
                    
                    if(tmp_last_PROBE) begin
                        N_out_last_processed <= 1;
                    end
                //end
                //else begin

                //end
	        end

	    endcase
	end
endmodule
