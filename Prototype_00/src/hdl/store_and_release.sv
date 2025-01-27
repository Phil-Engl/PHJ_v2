`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2024 04:56:24 PM
// Design Name: 
// Module Name: store_and_releaseV2
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


module store_and_release#(
    parameter DATA_SIZE = 128,
    parameter MAX_NUM = 2
)(
    input logic clk,
    input logic resetn,

    //Input data
    output logic in_ready,
    input logic [DATA_SIZE-1:0] in_data,
    input logic in_valid,
    input logic [31:0] in_serialnum,
    input logic in_joined,
    input logic in_last_processed,

    //Output data
    input logic out_ready,
    output logic [DATA_SIZE-1:0] out_data,
    output logic out_valid,
    output logic local_last_processed,

    //Signals to CaC
    output logic next_in_storage,
    input logic release_data,
    input logic [31:0] next
);

localparam ADDR_WIDTH = $clog2(MAX_NUM);

typedef enum integer {Work, Finished} StateType;
StateType State, nextState;


logic [MAX_NUM-1:0] storage_valid;
logic [MAX_NUM-1:0] storage_joined;


logic [DATA_SIZE-1:0] N_store_data;
logic [ADDR_WIDTH-1:0] N_store_addr;
logic N_store_valid;
logic N_store_joined;

logic [ADDR_WIDTH-1:0] local_addr;

logic [DATA_SIZE-1:0] N_out_data;
logic N_out_valid;

logic N_local_last_processed;

logic [DATA_SIZE-1:0] curr_data;
logic curr_valid;
logic curr_last;

logic [ADDR_WIDTH-1:0] bram_waddr;
logic [DATA_SIZE-1:0] bram_data;
logic [DATA_SIZE-1:0] bram_out_row;
logic bram_we;

logic [ADDR_WIDTH-1:0] bram_raddr;
logic [ADDR_WIDTH-1:0] local_release_addr;
logic [ADDR_WIDTH-1:0] test_addr;

logic [DATA_SIZE-1:0] tmp_data;

logic [DATA_SIZE-1:0] last_tuple_stored;
logic [ADDR_WIDTH-1:0] last_local_addr; 

logic invalidate;

logic [31:0] debug;



URAM #(
    .DATA_WIDTH(DATA_SIZE),
    .ADDR_WIDTH(ADDR_WIDTH)
) dut (
    .clk(clk),
    .raddr(bram_raddr),
    .waddr(bram_waddr),
    .data(bram_data),
    .we(bram_we),
    .out(tmp_data)
);

always_ff @(posedge clk) begin
    if(~resetn) begin
        out_valid <= 0;
        storage_valid <= '0;
        local_last_processed <= 0;
        State <= Work;
    end
    else begin
        State <= nextState;
        // Store stuff
        if(N_store_valid) begin
            storage_valid[bram_waddr] <= 1'b1;
            storage_joined[bram_waddr] <= N_store_joined;

            last_local_addr <= bram_waddr;
            last_tuple_stored <= bram_data;
        end

        local_last_processed <= N_local_last_processed;

        // Output stuff
        out_data <= N_out_data;
        out_valid <= N_out_valid;

        // Invalidate stuff
        if(invalidate) begin
            storage_valid[next % MAX_NUM] <= 1'b0;
            storage_joined[next % MAX_NUM] <= 1'b0;
        end
    end
end


always_comb begin
    // I think we are always ready for input???
    in_ready <= 1'b1;

    bram_raddr <= next % MAX_NUM;

    curr_data <= out_data;
    curr_valid <= out_valid;

    N_store_valid <= 0;
    N_store_joined <= 0;

    N_out_data <= '0;
    N_out_valid <= 1'b0;

    bram_we <= 1'b0;
    bram_waddr <= '0;
    bram_data <= '0;

    invalidate <= 0;

    // the local addr is where we store the tuple with serial number "next"
    local_addr <= next % MAX_NUM;
    // We are ready to release the tuple with serialnumber "next" if it is in storage and out_ready is true
    next_in_storage <= storage_valid[next % MAX_NUM] & out_ready;// & ~out_valid;// & ~out_valid;// & out_ready;
    N_local_last_processed <= 1'b0;
    nextState <= Work;
    case(State)
	    Work: begin
            //If the input is valid and was joined, we store it in the next cycle
            if(in_valid & in_joined) begin
                bram_data <= in_data;
                bram_waddr <= (in_serialnum % MAX_NUM);
                bram_we <= 1'b1;

                N_store_valid <= 1;
                N_store_joined <= 1;
            end
            //If the input is valid but was not joined, we do not store it since we won't output it anyway
            else if (in_valid) begin
                bram_waddr <= (in_serialnum % MAX_NUM);

                N_store_valid <= 1;
                N_store_joined <= 0;
            end

            if(out_ready) begin
                if(in_last_processed & ~(|storage_valid)) begin
                    nextState <= Finished;
                end
                
                if(release_data) begin
                    // CC gives signal to output stuff next cycle
                    if(storage_joined[next % MAX_NUM]) begin
                        // Check if it was a joined tuple and set valid_flag accordingly
                        N_out_valid <= 1'b1;
                        // Check if we can load it from bram or from register
                        if(last_local_addr == (next % MAX_NUM) ) begin
                            N_out_data <= last_tuple_stored;//'1;
                            debug <= 2;
                        end
                        else begin
                            N_out_data <= tmp_data;
                            debug <= 3;
                        end
                    end
                    // Invalidate the data we will output next cycle
                    invalidate <= 1;
                    // increase the bram_raddr by 1 to prepare for outputting the next tuple after this
                    bram_raddr <= (next+1) % MAX_NUM;   
                end
            end
            else begin
                // Not ready for output => keep output signals as they are!
                debug <= 4;
                N_out_data <= out_data;
                N_out_valid <= out_valid;
            end
        end

        Finished: begin
            N_local_last_processed <= 1'b1;
            N_out_valid <= 1'b0;
            nextState <= Finished;
        end
    endcase
end
endmodule
