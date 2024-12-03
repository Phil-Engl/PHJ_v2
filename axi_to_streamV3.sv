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

//test
module axi_to_streamV3 #(
    parameter INPUT_SIZE = 64, 
    parameter MAX_IN_TRANSIT = 2
    )(
    input logic clk,
    input logic resetn,
    
    input logic [511:0] in_data,
    input logic [7:0] in_valid,
    output logic in_ready,
    input logic in_last,

    input logic in_last_BUILD,
    input logic in_last_PROBE,

    input logic [7:0] out_ready_BUILD,
    output logic [7:0][63:0] out_data_BUILD,
    output logic [7:0] out_valid_BUILD,
    output logic [7:0] out_last_BUILD,

    //input logic phase, // PHASE == 0 => build ; PHASE == 1 => probe

    input logic [7:0] out_ready_PROBE,
    output logic [7:0][63:0] out_data_PROBE,
    output logic [7:0] out_valid_PROBE, 
    output logic [7:0] [63:0] out_serialnum,
    output logic [7:0] out_last_PROBE,

    input logic [31:0] curr_sn
    

    );

typedef enum int {Build_phase = 0, Probe_phase = 1} StateType;
StateType State, N_State;

logic [7:0] [63:0] N_out_BUILD;
logic [7:0] [63:0] N_out_PROBE;

logic [7:0] N_valid_BUILD;
logic [7:0] N_valid_PROBE;

logic [7:0] N_last_BUILD;
logic [7:0] N_last_PROBE;

logic [31:0] count;
logic [31:0] N_count;

logic [7:0] [63:0] N_serialnum;

//logic seen_last_BUILD;
//logic seen_last_PROBE;

logic [31:0] debug;

logic tmp_BUILD;
logic N_tmp_BUILD;


logic tmp_PROBE;
logic N_tmp_PROBE;


always_ff@(posedge clk) begin
    	if(~resetn) begin
            State <= Build_phase;
            
            out_data_BUILD <= '0;
            out_valid_BUILD <= '0;
            out_last_BUILD <= '0;

            out_data_PROBE <= '0;
            out_valid_PROBE <= '0;
            out_last_PROBE <= '0;

            out_serialnum <= '0;
            count <= 0;

            tmp_BUILD <= 0;

        end

        else if(State == Build_phase) begin
            State <= N_State; 
            out_data_BUILD <= N_out_BUILD;
            out_valid_BUILD <= N_valid_BUILD;
            out_last_BUILD <= N_last_BUILD;
            tmp_BUILD <= N_tmp_BUILD;
            

        end
        else if(State == Probe_phase) begin
            out_data_PROBE <= N_out_PROBE;
            out_valid_PROBE <= N_valid_PROBE;
            out_last_PROBE <= N_last_PROBE;
            out_serialnum <= N_serialnum;
            count <= N_count;
            tmp_PROBE <= N_tmp_PROBE;
           
        end
        else begin
            debug <= 5;
            State <= N_State;
            out_data_BUILD <= out_data_BUILD;
            out_data_PROBE <= out_data_PROBE;

            for(int i=0; i<8; i++) begin
                if(out_ready_BUILD[i]) begin
                    out_valid_BUILD[i] <= 1'b0;
                end
                if(out_ready_PROBE[i]) begin
                    out_valid_PROBE[i] <= 1'b0;
                end
            end
        end
    end


always_comb begin
    // DEFAULT VALUES
   in_ready <= 1'b0;

    N_State <= Build_phase;

    N_tmp_BUILD <= tmp_BUILD;
    N_tmp_PROBE <= tmp_PROBE;
    
    

    case(State)
	    Build_phase: begin 
            if(&out_ready_BUILD) begin
                in_ready <= 1'b1;
                //Output data
                N_out_BUILD[0] <= in_data[63:0];
                N_out_BUILD[1] <= in_data[127:64];
                N_out_BUILD[2] <= in_data[191:128];
                N_out_BUILD[3] <= in_data[255:192];
                N_out_BUILD[4] <= in_data[319:256];
                N_out_BUILD[5] <= in_data[383:320];
                N_out_BUILD[6] <= in_data[447:384];
                N_out_BUILD[7] <= in_data[511:448];

                //Output valid
                N_valid_BUILD <= in_valid;

                // If "in_last" => we want to remain in BUILD_phase for one more cycle so we use the tmp_BUILD variable to ensure we change to PROBE after next cycle
                if(in_last) begin
                    N_tmp_BUILD <= 1;    
                end
               // When "tmp_BUILD" => we want to go to PROBE_phase next cycle and can invalidate all outputs
                if(tmp_BUILD) begin
                    N_State <= Probe_phase;
                    for(int i=0; i<8; i++) begin
                        N_last_BUILD[i] <= 1'b1;
                    end 
                    N_out_BUILD <= '0;
                    N_valid_BUILD <= '0;
                end
            end
            else begin
               // Not all output streams are ready => we need have to stall and invalidate all outputs of streams that are already ready again
                in_ready <= 1'b0;

                N_out_BUILD <= out_data_BUILD;
                N_last_BUILD <= out_last_BUILD;

                for(int i=0; i<8; i++) begin
                    if(out_ready_BUILD[i]) begin
                        N_valid_BUILD[i] <= 1'b0;
                    end
                    else begin
                        N_valid_BUILD[i] <= out_valid_BUILD[i];
                    end
                end
            end
            
            N_last_PROBE <= '0;
            
        end

        Probe_phase: begin
                if(&out_ready_PROBE & (count < curr_sn + MAX_IN_TRANSIT)) begin
                        //Output data
                        N_out_PROBE[0] <= in_data[63:0];
                        N_out_PROBE[1] <= in_data[127:64];
                        N_out_PROBE[2] <= in_data[191:128];
                        N_out_PROBE[3] <= in_data[255:192];
                        N_out_PROBE[4] <= in_data[319:256];
                        N_out_PROBE[5] <= in_data[383:320];
                        N_out_PROBE[6] <= in_data[447:384];
                        N_out_PROBE[7] <= in_data[511:448];

                        //Output valid
                        N_valid_PROBE <= in_valid;

                        //Output serialnum
                        for(int i=0; i<8; i++) begin
                            N_serialnum[i][31:0] <= count;
                            N_serialnum[i][63:32] <= i;
                        end

                        // Update counter
                        if(in_valid) begin
                            N_count <= count +1;
                        end
                        else begin
                            N_count <= count;
                        end

                        // Check if last
                        if(in_last) begin
                            N_tmp_PROBE <= 1;    
                        end
                        // last seen last cycle => now we are done and can invalidate all outputs and signal last processed
                        if(tmp_PROBE) begin
                            N_last_PROBE <= '1;
                            N_out_PROBE <= '0;
                            N_valid_PROBE <= '0;
                        end
                        

                        in_ready <= 1'b1;
                    
                end
                else begin

                        in_ready <= 1'b0;
                        N_out_PROBE <= out_data_PROBE;
                        N_last_PROBE <= out_last_PROBE;
                        N_serialnum <= out_serialnum;
                        N_count <= count;

                        for(int i=0; i<8; i++) begin
                            /*if(out_ready_BUILD[i]) begin
                                N_valid_BUILD[i] <= 1'b0;
                            end
                            else begin
                                N_valid_BUILD[i] <= out_valid_BUILD[i];
                            end*/

                            if(out_ready_PROBE[i]) begin
                                N_valid_PROBE[i] <= 1'b0;
                            end
                            else begin
                                N_valid_PROBE[i] <= out_valid_PROBE[i];
                            end
                        end
                end

                /*for(int i=0; i<8; i++) begin
                    if(out_ready_BUILD[i]) begin
                        N_valid_BUILD[i] <= 1'b0;
                    end
                    else begin
                        N_valid_BUILD[i] <= out_valid_BUILD[i];
                    end
                end*/

                N_State <= Probe_phase; // IS THIS NECESSARY? SHOULD I JUMP BACK TO BUILD PHASE??
        end

    endcase
end




endmodule