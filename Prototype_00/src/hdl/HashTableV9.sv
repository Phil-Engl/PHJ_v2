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


module HashTableV9 #(
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

    integer i;
    integer nextI;
    logic Nready;
	// 32 bits for the counter + tuples_per_row * tuples_size
	localparam DATA_WIDTH = 288;
	localparam NUM_ROWS = 2**ROW_BITS;

    typedef enum integer {Init, Build, Probe, Last_Processed} StateType;
    StateType State, nextState;

    logic [127:0] N_out_data;
    logic N_out_valid;
    logic [63:0] N_out_serialnum;
    logic N_out_last_processed;
    logic N_out_was_joined;

    logic [127:0] N_out_data1;
    logic N_out_valid1;
    logic [63:0] N_out_serialnum1;
    logic N_out_last_processed1;
    logic N_out_was_joined1;

    logic [127:0] out_data1;
    logic out_valid1;
    logic [63:0] out_serialnum1;
    logic out_last_processed1;
    logic out_was_joined1;

    logic [127:0] N_out_data2;
    logic N_out_valid2;
    logic [63:0] N_out_serialnum2;
    logic N_out_last_processed2;
    logic N_out_was_joined2;

    logic [127:0] out_data2;
    logic out_valid2;
    logic [63:0] out_serialnum2;
    logic out_last_processed2;
    logic out_was_joined2;

    logic [ROW_BITS-1:0] test_addr;
    logic [ROW_BITS-1:0] N_test_addr;

    logic [ROW_BITS-1:0] raddr;
    logic [ROW_BITS-1:0] raddr1;

    logic [ROW_BITS-1:0] N_raddr;
    logic [ROW_BITS-1:0] N_raddr1;


    logic [63:0] tmp2_tuple_PROBE;
    logic [63:0] tmp1_tuple_PROBE;
    logic [63:0] tmp_tuple_PROBE;
    logic [63:0] tmpE1_tuple_PROBE;
    logic [63:0] tmpE2_tuple_PROBE;

    logic [63:0] N_tmp2_tuple_PROBE;
    logic [63:0] N_tmp1_tuple_PROBE;
    logic [63:0] N_tmp_tuple_PROBE;
    logic [63:0] N_tmpE1_tuple_PROBE;
    logic [63:0] N_tmpE2_tuple_PROBE;


    logic tmp2_valid_PROBE;
    logic tmp1_valid_PROBE;
    logic tmp_valid_PROBE;
    logic tmpE1_valid_PROBE;
    logic tmpE2_valid_PROBE;
    

    logic N_tmp2_valid_PROBE;
    logic N_tmp1_valid_PROBE;
    logic N_tmp_valid_PROBE;
    logic N_tmpE1_valid_PROBE;
    logic N_tmpE2_valid_PROBE;


    logic tmp2_last_PROBE;
    logic tmp1_last_PROBE;
    logic tmp_last_PROBE;
    logic tmpE1_last_PROBE;
    logic tmpE2_last_PROBE;

    logic tmp_last_PROBE_test1;
    logic tmp_last_PROBE_test2;

    logic N_tmp_last_PROBE_test1;
    logic N_tmp_last_PROBE_test2;


    logic N_tmp2_last_PROBE;
    logic N_tmp1_last_PROBE;
    logic N_tmp_last_PROBE;
     logic N_tmpE1_last_PROBE;
    logic N_tmpE2_last_PROBE;

    logic [63:0] tmp2_serialnum;
    logic [63:0] tmp1_serialnum;
    logic [63:0] tmp_serialnum;
    logic [63:0] tmpE1_serialnum;
    logic [63:0] tmpE2_serialnum;

    logic [63:0] N_tmp2_serialnum;
    logic [63:0] N_tmp1_serialnum;
    logic [63:0] N_tmp_serialnum;
    logic [63:0] N_tmpE1_serialnum;
    logic [63:0] N_tmpE2_serialnum;




    logic [63:0] tmp2_tuple_BUILD;
    logic [63:0] tmp1_tuple_BUILD;
    logic [63:0] tmp_tuple_BUILD;

    logic [63:0] N_tmp2_tuple_BUILD;
    logic [63:0] N_tmp1_tuple_BUILD;
    logic [63:0] N_tmp_tuple_BUILD;

    logic tmp2_valid_BUILD;
    logic tmp1_valid_BUILD;
    logic tmp_valid_BUILD;

    logic N_tmp2_valid_BUILD;
    logic N_tmp1_valid_BUILD;
    logic N_tmp_valid_BUILD;


    logic tmp2_last_BUILD;
    logic tmp1_last_BUILD;
    logic tmp_last_BUILD;

    logic N_tmp2_last_BUILD;
    logic N_tmp1_last_BUILD;
    logic N_tmp_last_BUILD;


    logic [ROW_BITS-1:0] waddr;
    logic [ROW_BITS-1:0] N_waddr;

    logic [DATA_WIDTH-1:0] data;
    logic [DATA_WIDTH-1:0] N_data;
    //logic [DATA_WIDTH-1:0] tmp_out_row;
    logic [DATA_WIDTH-1:0] out_row;
    logic [DATA_WIDTH-1:0] out_rowE1;
    logic [DATA_WIDTH-1:0] out_rowE2;
    logic [DATA_WIDTH-1:0] N_out_rowE1;
    logic [DATA_WIDTH-1:0] N_out_rowE2;
    
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
    logic N_we;

    
    

    logic N_wrote_two;
    logic wrote_two;

    logic [31:0] debug;

    logic test_ready;

    //logic [ROW_BITS-1:0]

    URAM_with_READY #(
       	.DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ROW_BITS)
    ) dut (
        .clk(clk),
        .raddr(raddr),
        .waddr(waddr),
        .data(data),
        .we(we),
        .out(out_row),
        .out_ready(test_ready)
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
                State <= nextState;
                i <= nextI;

                out_rowE1 <= N_out_rowE1;
                out_rowE2 <= N_out_rowE2;

                out_valid <= N_out_valid;
                out_data <= N_out_data;
                out_serialnum <= N_out_serialnum;
                out_last_processed <= N_out_last_processed;
                out_was_joined <= N_out_was_joined;

                raddr1 <= N_raddr1;
                raddr <= N_raddr;
                waddr <= N_waddr;

                tmp2_tuple_BUILD <= N_tmp2_tuple_BUILD;
                tmp1_tuple_BUILD <= N_tmp1_tuple_BUILD;
                tmp_tuple_BUILD <= N_tmp_tuple_BUILD;

                tmp2_valid_BUILD <= N_tmp2_valid_BUILD;
                tmp1_valid_BUILD <= N_tmp1_valid_BUILD;
                tmp_valid_BUILD <= N_tmp_valid_BUILD;

                tmp2_last_BUILD <= N_tmp2_last_BUILD;
                tmp1_last_BUILD <= N_tmp1_last_BUILD;
                tmp_last_BUILD <= N_tmp_last_BUILD;

                tmp2_tuple_PROBE <= N_tmp2_tuple_PROBE;
                tmp1_tuple_PROBE <= N_tmp1_tuple_PROBE;
                tmp_tuple_PROBE <= N_tmp_tuple_PROBE;
                tmpE1_tuple_PROBE <= N_tmpE1_tuple_PROBE;
                tmpE2_tuple_PROBE <= N_tmpE2_tuple_PROBE;

                tmp2_valid_PROBE <= N_tmp2_valid_PROBE;
                tmp1_valid_PROBE <= N_tmp1_valid_PROBE;
                tmp_valid_PROBE <= N_tmp_valid_PROBE;
                tmpE1_valid_PROBE <= N_tmpE1_valid_PROBE;
                tmpE2_valid_PROBE <= N_tmpE2_valid_PROBE;

                tmp2_last_PROBE <= N_tmp2_last_PROBE;
                tmp1_last_PROBE <= N_tmp1_last_PROBE;
                tmp_last_PROBE <= N_tmp_last_PROBE;
                tmpE1_last_PROBE <= N_tmpE1_last_PROBE;
                tmpE2_last_PROBE <= N_tmpE2_last_PROBE;

                //tmp_last_PROBE_test1 <= N_tmp_last_PROBE_test1;
                //tmp_last_PROBE_test2 <= N_tmp_last_PROBE_test2;

                tmp2_serialnum <= N_tmp2_serialnum;
                tmp1_serialnum <= N_tmp1_serialnum;
                tmp_serialnum <= N_tmp_serialnum;
                tmpE1_serialnum <= N_tmpE1_serialnum;
                tmpE2_serialnum <= N_tmpE2_serialnum;
    	end
    end


    always_comb begin 
        in_ready_BUILD <= 1;
        in_ready_PROBE <= 1;
        nextI <= i;
        we <= 0;
        data <= '0;
        
        nextState <= State;

        N_out_data <= '0;
        N_out_was_joined <= 0;
        N_out_valid <= 0;
        N_out_serialnum <= '0;
        N_out_last_processed <= 1'b0;

        N_out_rowE1 <= '0;
        N_out_rowE2 <= '0;

        
        
        N_tmp2_tuple_BUILD <= '0;
        N_tmp1_tuple_BUILD <= '0;
        N_tmp_tuple_BUILD <= '0;

        N_tmp2_valid_BUILD <= '0;
        N_tmp1_valid_BUILD <= '0;
        N_tmp_valid_BUILD <= '0;

        N_tmp2_last_BUILD <= '0;
        N_tmp1_last_BUILD <= '0;
        N_tmp_last_BUILD <= '0;


        N_tmp2_tuple_PROBE <= '0;
        N_tmp1_tuple_PROBE <= '0;
        N_tmp_tuple_PROBE <= '0;
        N_tmpE1_tuple_PROBE <= '0;
        N_tmpE2_tuple_PROBE <= '0;

        N_tmp2_valid_PROBE <= '0;
        N_tmp1_valid_PROBE <= '0;
        N_tmp_valid_PROBE <= '0;
        N_tmpE1_valid_PROBE <= '0;
        N_tmpE2_valid_PROBE <= '0;

        N_tmp2_last_PROBE <= '0;
        N_tmp1_last_PROBE <= '0;
        N_tmp_last_PROBE <= '0;
        N_tmpE1_last_PROBE <= '0;
        N_tmpE2_last_PROBE <= '0;

        N_tmp2_serialnum <= '0;
        N_tmp1_serialnum <= '0;
        N_tmp_serialnum <= '0;
        N_tmpE1_serialnum <= '0;
        N_tmpE2_serialnum <= '0;


        N_raddr1 <= '0;
        N_raddr <= '0;
        N_waddr <= '0;

        test_ready <= 1'b1;

	    case(State)
	    	Init: begin
                //we <= 1'b0;
                
                if (i < NUM_ROWS) begin
                    N_waddr <= i;
                    data <= 0;
                    we <= 1'b1;
                    nextI <= i + 1;
                    nextState <= Init;
                    in_ready_BUILD <= 0;
                    in_ready_PROBE <= 0;
                end else begin
                    nextState <= Build;
                    nextI <= 0; // Reset i for the next reset event
                    we <= 1'b1;
                    in_ready_BUILD <= 0;
                    in_ready_PROBE <= 0;
                end
            end

	        Build: begin
                //we <= 1'b0;
                N_raddr1 <= in_hash_BUILD[ROW_BITS-1:0];
                N_raddr <= raddr1;
                N_waddr <= raddr;

                N_tmp2_tuple_BUILD <= in_data_BUILD;
                N_tmp1_tuple_BUILD <= tmp2_tuple_BUILD;
                N_tmp_tuple_BUILD <= tmp1_tuple_BUILD;


                N_tmp2_valid_BUILD <= in_valid_BUILD;
                N_tmp1_valid_BUILD <= tmp2_valid_BUILD;

                // HAD TO PUT THIS LINE IN THE IF-ELSE to invalidate next valid bit in case of double write
                //N_tmp_valid_BUILD <= tmp1_valid_BUILD;

                N_tmp2_last_BUILD <= in_last_processed_BUILD;
                N_tmp1_last_BUILD <= tmp2_last_BUILD;
                N_tmp_last_BUILD <= tmp1_last_BUILD;

                
                if(raddr == waddr & tmp1_valid_BUILD & tmp_valid_BUILD) begin
                    debug <= 1;
                    //encountered 2 consecutive writes to the same row => write them both next cycle and invalidate the second tuple
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

                    // INVALIDATE SECOND WRITE
                    N_tmp_valid_BUILD <= 1'b0;

                end
                else begin
                    debug <= 2;
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
                    N_tmp_valid_BUILD <= tmp1_valid_BUILD;
                end

                if(tmp_last_BUILD) begin
                    nextState <= Probe;
                end
                else begin
                    nextState <= Build;
                end

	        end

            

            Probe: begin
                //we <= 1'b0;
                in_ready_PROBE <= out_ready;
                
                N_out_last_processed <= 1'b0;

                if(out_ready) begin
                    debug <= 3;
                    N_raddr1 <= in_hash_PROBE[ROW_BITS-1:0];
                    N_raddr <= raddr1;
                    //N_test_addr <= raddr;

                    N_tmp2_tuple_PROBE <= in_data_PROBE;
                    N_tmp1_tuple_PROBE <= tmp2_tuple_PROBE;
                    N_tmp_tuple_PROBE <= tmp1_tuple_PROBE;
                    N_tmpE1_tuple_PROBE <= tmp_tuple_PROBE;
                    N_tmpE2_tuple_PROBE <= tmpE1_tuple_PROBE;

                    N_tmp2_valid_PROBE <= in_valid_PROBE;
                    N_tmp1_valid_PROBE <= tmp2_valid_PROBE;
                    N_tmp_valid_PROBE <= tmp1_valid_PROBE;
                    N_tmpE1_valid_PROBE <= tmp_valid_PROBE;
                    N_tmpE2_valid_PROBE <= tmpE1_valid_PROBE;

                    N_tmp2_last_PROBE <= in_last_processed_PROBE;
                    N_tmp1_last_PROBE <= tmp2_last_PROBE;
                    N_tmp_last_PROBE <= tmp1_last_PROBE;
                    N_tmpE1_last_PROBE <= tmp_last_PROBE;
                    N_tmpE2_last_PROBE <= tmpE1_last_PROBE;

                    N_tmp2_serialnum <= in_serialnum;
                    N_tmp1_serialnum <= tmp2_serialnum;
                    N_tmp_serialnum <= tmp1_serialnum;
                    N_tmpE1_serialnum <= tmp_serialnum;
                    N_tmpE2_serialnum <= tmpE1_serialnum;

                    N_out_rowE1 <= out_row;
                    N_out_rowE2 <= out_rowE1;

                    for(int i=0; i<4; i++) begin
                        if(out_rowE2[(i*64)+:32] == tmpE2_tuple_PROBE[0+:32] & (out_rowE2[287:256] > (3-i))) begin
                            N_out_data[64+:64] <= out_rowE2[(i*64)+:64];
                            N_out_data[0+:64] <= tmpE2_tuple_PROBE[0+:64];
                            N_out_was_joined <= 1'b1;
                            //N_out_serialnum <= tmp_serialnum;//tmp_serialnum;
                        end
                    end

                    N_out_serialnum <= tmpE2_serialnum;
                    N_out_valid <= tmpE2_valid_PROBE;

                    if(tmpE2_last_PROBE) begin
                        nextState <= Last_Processed;
                    end
                    else begin
                        nextState <= Probe;
                    end

                end
                else begin
                    debug <= 4;
                    nextState <= Probe;

                    N_raddr1 <= raddr1;
                    N_raddr <= raddr;

                    test_ready <= 1'b0;

                    N_out_rowE1 <= out_rowE1;
                    N_out_rowE2 <= out_rowE2;

                    N_tmp2_tuple_PROBE <= tmp2_tuple_PROBE;
                    N_tmp1_tuple_PROBE <= tmp1_tuple_PROBE;
                    N_tmp_tuple_PROBE <= tmp_tuple_PROBE;
                    N_tmpE1_tuple_PROBE <= tmpE1_tuple_PROBE;
                    N_tmpE2_tuple_PROBE <= tmpE2_tuple_PROBE;

                    N_tmp2_valid_PROBE <= tmp2_valid_PROBE;
                    N_tmp1_valid_PROBE <= tmp1_valid_PROBE;
                    N_tmp_valid_PROBE <= tmp_valid_PROBE;
                    N_tmpE1_valid_PROBE <= tmpE1_valid_PROBE;
                    N_tmpE2_valid_PROBE <= tmpE2_valid_PROBE;

                    N_tmp2_last_PROBE <= tmp2_last_PROBE;
                    N_tmp1_last_PROBE <= tmp1_last_PROBE;
                    N_tmp_last_PROBE <= tmp_last_PROBE;
                    N_tmpE1_last_PROBE <= tmpE1_last_PROBE;
                    N_tmpE2_last_PROBE <= tmpE2_last_PROBE;
                    

                    N_tmp2_serialnum <= tmp2_serialnum;
                    N_tmp1_serialnum <= tmp1_serialnum;
                    N_tmp_serialnum <= tmp_serialnum;
                    N_tmpE1_serialnum <= tmpE1_serialnum;
                    N_tmpE2_serialnum <= tmpE2_serialnum;

                    N_out_data <= out_data;
                    N_out_valid <= out_valid;
                    N_out_serialnum <= out_serialnum;
                    N_out_last_processed <= out_last_processed;
                    N_out_was_joined <= out_was_joined; 
                end
            end

            Last_Processed: begin
                nextState <= Last_Processed;
                N_out_last_processed <= 1'b1;
            end

	    endcase
	end
endmodule
