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


module HashTableV3 #(
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

    typedef enum integer {Init, Read, Write, Probe} StateType;
    StateType State, nextState;

    logic [127:0] N_out_data;
    logic N_out_valid;
    logic [63:0] N_out_serialnum;
    logic N_out_last_processed;


    logic [ROW_BITS-1:0] raddr;
    logic [ROW_BITS-1:0] raddr1;

    logic [63:0] tmp2_tuple;
    logic [63:0] tmp1_tuple;
    logic [63:0] tmp_tuple;

    logic tmp2_valid;
    logic tmp1_valid;
    logic tmp_valid;

    logic tmp2_last;
    logic tmp1_last;
    logic tmp_last;

    logic [63:0] tmp2_serialnum;
    logic [63:0] tmp1_serialnum;
    logic [63:0] tmp_serialnum;


    logic [ROW_BITS-1:0] waddr;
    logic [DATA_WIDTH-1:0] data;
    logic [DATA_WIDTH-1:0] tmp_out_row;
    logic [DATA_WIDTH-1:0] out_row;
    
    //logic [63:0] tuple_tmp;
    //logic [ROW_BITS-1:0] address_tmp;
    //logic [63:0] tmp_serialnum;

    //logic [63:0] tuple_tmp1;
    //logic valid_tmp1;

    //logic [63:0] tmp_serialnum1;

    logic valid_tmp;
    logic we;

    //logic tmp_last_processed1;
    //logic tmp_last_processed;

    logic N_out_was_joined;

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
    	end
    	else begin
            if(State == Probe) begin
                if(out_ready) begin
                    State <= nextState;

                    out_valid <= N_out_valid;
                    out_data <= N_out_data;
                    out_serialnum <= N_out_serialnum;
                    out_last_processed <= N_out_last_processed;
                    out_was_joined <= N_out_was_joined;

                    raddr <= raddr1;

                    tmp1_tuple <= tmp2_tuple;
                    tmp_tuple <= tmp1_tuple;

                    tmp1_valid <= tmp2_valid;
                    tmp_valid <= tmp1_valid;

                    tmp1_serialnum <= tmp2_serialnum;
                    tmp_serialnum <= tmp1_serialnum;

                    tmp1_last <= tmp2_last;
                    tmp_last <= tmp1_last;
                end
                else begin
                    State <= nextState;

                    out_valid <= out_valid;
                    out_data <= out_data;
                    out_serialnum <= out_serialnum;
                    out_last_processed <= out_last_processed;
                    out_was_joined <= out_was_joined;

                    raddr <= raddr;

                    tmp1_tuple <= tmp1_tuple;
                    tmp_tuple <= tmp_tuple;

                    tmp1_valid <= tmp1_valid;
                    tmp_valid <= tmp_valid;

                    tmp1_serialnum <= tmp1_serialnum;
                    tmp_serialnum <= tmp_serialnum;

                    tmp1_last <= tmp1_last;
                    tmp_last <= tmp_last;
                end
            end
            else begin
                State <= nextState;
                i <= nextI;
            end
    	end
    end


    always_comb begin 
        in_ready_BUILD <= 1;
        in_ready_PROBE <= 1;
        nextI <= i;
        we <= 0;
        data <= '0;

        //N_out_valid <= 0;
        //N_out_data <= '0;
        //N_out_serialnum <= '0;
        //N_out_last_processed <= 0;
        //N_out_was_joined <= 0;

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
                    nextState <= Read;
                    nextI <= 0; // Reset i for the next reset event
                    in_ready_PROBE <= 0;
                    N_out_last_processed <= 0;
                    in_ready_BUILD <= 0;
                    in_ready_PROBE <= 0;
                end
            end

	        Read: begin
                if (in_valid_BUILD) begin
	                raddr <= in_hash_BUILD[ROW_BITS-1:0];
                    waddr <= in_hash_BUILD[ROW_BITS-1:0];
	            	nextState <= Write;
                    in_ready_BUILD <= 0;
	            end
                else if(in_last_processed_BUILD) begin
                    nextState <= Probe;
                end
                in_ready_PROBE <= 0;
	        end

            Write: begin
                for(int i=0; i<4; i++) begin
                    if(i < out_row[287:256]) begin
                        data[(3-i)*64 +: 64] <= out_row[(3-i)*64 +: 64];
                    end
                    else if(i == out_row[287:256]) begin
                        data[(3-i)*64 +: 64] <= in_data_BUILD;
                        data[256+:32] <= i+1;
                    end
                    else begin 
                        data[(3-i)*64 +: 64] <= '0;
                    end
                end

                we <= 1;
	            nextState <= Read;
                in_ready_PROBE <= 0;
            end

            Probe: begin
                in_ready_PROBE <= out_ready;
                
                raddr1 <= in_hash_PROBE[ROW_BITS-1:0];
                tmp2_tuple <= in_data_PROBE;
                tmp2_valid <= in_valid_PROBE;
                tmp2_last <= in_last_processed_PROBE;
                tmp2_serialnum <= in_serialnum;

                for(int i=0; i<4; i++) begin
                    if(out_row[(i*64)+:32] == tmp_tuple[0+:32] & (out_row[287:256] > (3-i))) begin
                        N_out_data[64+:64] <= out_row[(i*64)+:64];
                        N_out_data[0+:64] <= tmp_tuple[0+:64];
                        N_out_was_joined <= 1'b1;
                        N_out_serialnum <= tmp_serialnum;//tmp_serialnum;
                    end
                end

                N_out_valid <= tmp_valid;
                nextState <= Probe;
                if(tmp_last) begin
                    N_out_last_processed <= 1;
                end
	        end

	    endcase
	end
endmodule
