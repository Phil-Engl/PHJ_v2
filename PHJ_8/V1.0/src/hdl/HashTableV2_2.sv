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


module HashTableV2_2 #(
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

    typedef enum integer {Init, Read, Write, Probe_Read, Probe_Write} StateType;
    StateType State, nextState;

    logic [127:0] N_out_data;
    logic N_out_valid;
    logic [63:0] N_out_serialnum;
    logic N_out_last_processed;


    logic [ROW_BITS-1:0] raddr;
    logic [ROW_BITS-1:0] raddr1;
    logic [ROW_BITS-1:0] waddr;
    logic [DATA_WIDTH-1:0] data;
    logic [DATA_WIDTH-1:0] tmp_out_row;
    logic [DATA_WIDTH-1:0] out_row;
    
    logic [63:0] tuple_tmp;
    logic [ROW_BITS-1:0] address_tmp;
    logic [63:0] tmp_serialnum;

    logic [63:0] tuple_tmp1;
    logic valid_tmp1;

    logic [63:0] tmp_serialnum1;

    logic valid_tmp;
    logic we;

    logic tmp_last_processed1;
    logic tmp_last_processed;

    logic N_out_was_joined;

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
            if(State == Probe_Read | State == Probe_Write) begin
                if(out_ready) begin
                    State <= nextState;

                    out_valid <= N_out_valid;
                    out_data <= N_out_data;
                    out_serialnum <= N_out_serialnum;
                    out_last_processed <= N_out_last_processed;
                    out_was_joined <= N_out_was_joined;
                end
                else begin
                    State <= State;
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

        waddr <= '0;
        raddr <= '0;
        nextState <= State;

        N_out_valid <= 0;
        N_out_data <= '0;
        N_out_serialnum <= '0;
        N_out_last_processed <= out_last_processed;
        N_out_was_joined <= 0;

	    case(State)
	    	Init: begin
                
                if (i < NUM_ROWS) begin
                    waddr <= i;
                    raddr <= '0;

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

                    waddr <= '0;
                    raddr <= '0;
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
                    nextState <= Probe_Read;
                    waddr <= '0;
                    raddr <= '0;
                end
                else begin
                    waddr <= '0;
                    raddr <= '0;
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

                waddr <= waddr;
                raddr <= '0;//raddr;

                we <= 1;
	            nextState <= Read;
                in_ready_PROBE <= 0;
            end

            Probe_Read: begin
               
                

                if(out_ready ) begin
                    if (in_valid_PROBE) begin
                        raddr <= in_hash_PROBE[ROW_BITS-1:0];
                        waddr <= '0;
                        //waddr <= in_hash_PROBE[ROW_BITS-1:0];
                        nextState <= Probe_Write;
                        in_ready_PROBE <= 0;
                    end
                    else if(in_last_processed_PROBE) begin
                        N_out_last_processed <= 1;
                        raddr <= '0;
                        waddr <= '0;
                    end
                end
                else begin
                    in_ready_PROBE <= 0;
                    raddr <= '0;
                    waddr <= '0;
                    //N_out_serialnum <= 222;
                end

                in_ready_PROBE <= 0;
	        end

            Probe_Write: begin
                raddr <= raddr;
                waddr <= '0;

                if(out_ready ) begin
                    for(int i=0; i<4; i++) begin
                            if(out_row[(i*64)+:32] == in_data_PROBE[0+:32] & (out_row[287:256] > (3-i))) begin
                                N_out_data[64+:64] <= out_row[(i*64)+:64];
                                N_out_data[0+:64] <= in_data_PROBE[0+:64];
                                //valid_tmp;//1'b1;
                                N_out_was_joined <= 1'b1;
                                N_out_serialnum <= in_serialnum;//tmp_serialnum;
                            end
                            
                        end
                    
                    N_out_valid <= in_valid_PROBE;
                    nextState <= Probe_Read;
                    //in_ready_PROBE <= 1;
                    if(in_last_processed_PROBE) begin
                        N_out_last_processed <= 1;
                    end
                end
                else begin
                    in_ready_PROBE <= 0;
                end
            end

            /*Probe_Read: begin
               
               
                raddr <= in_hash_PROBE[ROW_BITS-1:0];
                tuple_tmp1 <= in_data_PROBE;
                valid_tmp1 <= in_valid_PROBE;
                tmp_serialnum1 <= in_serialnum;

                if(valid_tmp) begin
                    for(int i=0; i<4; i++) begin
                        if(tmp_out_row[(i*64)+:32] == tuple_tmp[0+:32] & (tmp_out_row[287:256] > (3-i))) begin
                            N_out_data[64+:64] <= tmp_out_row[(i*64)+:64];
                            N_out_data[0+:64] <= tuple_tmp[0+:64];
                            N_out_valid <= valid_tmp;//1'b1;
                            N_out_serialnum <= tmp_serialnum;
                        end
                        
                    end
                end
                else begin
                    N_out_data[64+:64] <= '0;
                    N_out_data[0+:64] <= '0;
                    N_out_valid <= 0;
                    N_out_serialnum <= 0;
                end
                

                    // if valid_tmp1 is 1, we might output another tuple next cycle so we cannot set last_processed to 1 until then...
                if(in_last_processed_PROBE & ~in_valid_PROBE) begin
                    N_out_last_processed <= 1'b1;
                end
                    //in_ready_PROBE <= 1'b1;
                
                in_ready_PROBE <= out_ready;
                nextState <= Probe_Read;
                
                
            end*/

	    endcase
	end
endmodule
