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


module store_and_releaseV3#(
    parameter DATA_SIZE = 128,
    parameter MAX_NUM = 2
)(
    input logic clk,
    input logic resetn,

    output logic in_ready,
    input logic [DATA_SIZE-1:0] in_data,
    input logic in_valid,
    input logic [31:0] in_serialnum,
    input logic in_joined,

    input logic out_ready,
    output logic [DATA_SIZE-1:0] out_data,
    output logic out_valid,

    output logic next_in_storage,
    
    input logic release_data,
    input logic [31:0] next,
    //input logic [31:0] to_release,

    input logic in_last_processed,
    output logic local_last_processed
    //input logic all_last_processed,
    //output logic out_last_processed
    
);

//logic [MAX_NUM-1:0] [DATA_SIZE-1:0] storage;
logic [MAX_NUM-1:0] storage_valid;
logic [MAX_NUM-1:0] storage_joined;


logic [DATA_SIZE-1:0] N_store_data;
logic [31:0] N_store_addr;
logic N_store_valid;
logic N_store_joined;

logic [31:0] local_addr;

logic [DATA_SIZE-1:0] N_out_data;
logic N_out_valid;

logic N_local_last_processed;


//logic [31:0] bram_raddr;
//logic [31:0] N_bram_raddr;

logic [31:0] bram_waddr;
logic [DATA_SIZE-1:0] bram_data;
logic [DATA_SIZE-1:0] bram_out_row;
logic bram_we;


logic [31:0] local_release_addr;
logic [31:0] test_addr;

logic [DATA_SIZE-1:0] tmp_data;

logic [DATA_SIZE-1:0] last_tuple_stored;
logic [31:0] last_local_addr; 



    simple_dual_port_ram_single_clock #(
       	.DATA_WIDTH(DATA_SIZE),
        .ADDR_WIDTH($clog2(MAX_NUM))
    ) dut (
        .clk(clk),
        .raddr(next % MAX_NUM),
        .waddr(bram_waddr),
        .data(bram_data),
        .we(bram_we),
        .out(tmp_data)
    );







always_ff @(posedge clk) begin
    if(~resetn) begin
        //out_data <= '0;
        out_valid <= 0;
        //storage <= '0;
        storage_valid <= '0;
        local_last_processed <= 0;
    end
    else begin
        // If we have valid input => store it
        if(N_store_valid) begin
            //storage[N_store_addr] <= N_store_data;

            storage_valid[bram_waddr] <= 1'b1;
            storage_joined[bram_waddr] <= N_store_joined;

            last_local_addr <= bram_waddr;
            last_tuple_stored <= bram_data;

            /*if(bram_waddr == local_addr & N_out_valid) begin
                out_data <= last_tuple_stored
            end*/
        end

        local_last_processed <= N_local_last_processed;

        // Output stuff
        //out_data <= N_out_data;
        //out_valid <= N_out_valid;

        // If we output something, we want to invalidate that line in our storage
        /*if(N_out_valid) begin
            storage_valid[local_release_addr] <= 1'b0;
            out_data <= tmp_data;
        end
        else begin
            out_data <= '0;
        end
        out_valid <= N_out_valid;*/

        if(N_out_valid) begin
            // We want to output something next cycle
            if(last_local_addr == (next % MAX_NUM) ) begin
                // The tuple we want to output was only received last cycle => we output it from tmp_data
                storage_valid[next % MAX_NUM] <= 1'b0;
                storage_joined[next % MAX_NUM] <= 1'b0;
                out_data <= last_tuple_stored;//'1;
                out_valid <= 1'b1;
            end
            else begin
                // We output a tuple from BRAM
                storage_valid[next % MAX_NUM] <= 1'b0;
                storage_joined[next % MAX_NUM] <= 1'b0;
                out_data <= tmp_data;
                out_valid <= 1'b1;
            end
        end
        else begin
            out_data <= '0;
            out_valid <= 1'b0;
        end
    end
end


always_comb begin
    
    // I think we are always ready for input???
    in_ready <= 1'b1;

    // default values => Set all outputs to 0
    //N_store_data <= '0;
    //N_store_addr <= '0;
    N_store_valid <= 0;
    N_store_joined <= 0;

    N_out_data <= '0;
    //N_out_valid <= 1'b0;

    bram_we <= 1'b0;
    bram_waddr <= '0;
    bram_data <= '0;

    // the local addr is where we store the tuple with serial number "next"
    local_addr <= next % MAX_NUM;
    //local_release_addr <= to_release % MAX_NUM;
    // We are ready to release the tuple with serialnumber "next" if it is in storage and out_ready is true
    next_in_storage <= storage_valid[next % MAX_NUM] & ~out_valid;// & ~out_valid;// & out_ready;

    //If the input is valid, we store it in the next cycle
    if(in_valid & in_joined) begin
        bram_data <= in_data;
        bram_waddr <= (in_serialnum % MAX_NUM);
        bram_we <= 1'b1;

        N_store_valid <= 1;
        N_store_joined <= 1;
    end
    else if (in_valid) begin
        bram_waddr <= (in_serialnum % MAX_NUM);

        N_store_valid <= 1;
        N_store_joined <= 0;
    end

    if(in_last_processed & ~(|storage_valid)) begin
        N_local_last_processed <= 1'b1;
    end
    else begin
        N_local_last_processed <= local_last_processed;
    end
    
    // If CC gives signal to release AND the tuple stored is a joined tuple, we output "next" in the next cycle
    if(release_data & storage_joined[next % MAX_NUM]) begin
        N_out_valid <= 1'b1;
    end
    else begin
        N_out_valid <= 1'b0;
    end
    //else begin 
    //    N_out_valid <= 1'b0;
    //    test_addr <= '0;
    //end
end
endmodule
