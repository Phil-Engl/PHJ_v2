`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ETH Zürich
// Engineer: Philipp Engljähringer
// 
// Create Date: 06/03/2024 01:15:37 PM
// Module Name: Partitioned_Hash_Join
// Project Name: Partitioned_Hash_Join
// Target Devices: xcvu47p-fsvh2892-2L-e
// Tool Versions: 2022.2
// Description: Full Partitioned_Hash_Join module
// 
// Dependencies: murmur_8way, HashTable, DD8_3bit
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Partitioned_Hash_Join#(
    parameter INPUT_SIZE = 64,
    parameter ROW_BITS = 4,
    parameter COL_BITS = 2,
    parameter MAX_IN_TRANSIT = 4
    )(

    input logic clk,
    input logic resetn,
 
    input logic [511:0] in_data,
    input logic [7:0] in_valid,
    output logic in_ready,
    input logic in_last,
    
    input logic out_ready,
    output logic [1023:0] out_data,
    output logic out_valid,
    output logic out_last,
    output logic [127:0] out_keep
    );

   

    logic [1:0] [7:0][63:0] out_data_CONV;
    logic [1:0] [7:0] out_valid_CONV;
    logic [1:0] [7:0] out_last_processed_CONV;
    logic [7:0] [63:0] out_serialnum_CONV;

    logic [1:0] [7:0] in_ready_hash;
    logic [1:0] [7:0] [63:0] out_data_hash;
    logic [1:0] [7:0] [31:0] out_tag_hash;
    logic [1:0] [7:0] out_valid_hash;
    logic [1:0] [7:0] out_last_processed_hash;
    logic [7:0] [63:0] out_serialnum_hash;

    logic [1:0] [7:0] in_ready_DD8;
    logic [1:0] [7:0] [INPUT_SIZE-1:0] out_data_DD8;
    logic [1:0] [7:0] [31:0] out_tag_DD8;
    logic [1:0] [7:0] out_valid_DD8;
    logic [1:0] [7:0] out_last_processed_DD8;
    logic [7:0] [63:0] out_serialnum_DD8;

    logic [1:0][7:0] in_ready_HT;
    logic [7:0] [127:0] out_data_HT;
    logic [7:0] out_valid_HT;
    logic [7:0] out_last_processed_HT;
    logic [7:0] [63:0] out_serialnum_HT;
    logic [7:0] out_was_joined_HT;

    logic  [7:0] in_ready_DD82;
    logic [7:0] [127:0] out_data_DD82;
    logic [7:0] out_valid_DD82;
    logic [7:0] out_last_processed_DD82;
    logic [7:0] [63:0] out_serialnum_DD82;
    logic [7:0] [31:0] out_tag_DD82;
    logic [7:0] out_was_joined_DD82;

    logic [7:0] in_ready_SaR;
    logic [7:0] [127:0] out_data_SaR;
    logic [7:0] out_valid_SaR;
    logic [7:0] next_in_storagev2;
    logic [7:0] out_last_processed_SaR;

    logic  release_next;
    logic [31:0] next_CC;
    logic out_last_processed_CC;

    logic [7:0] in_ready_rta;

    logic [31:0] to_release;
    logic [7:0] release_data;


CONV_AXI_to_STREAM  #(
  .INPUT_SIZE(INPUT_SIZE),
  .MAX_IN_TRANSIT(MAX_IN_TRANSIT)
) axi_conv (
    .clk(clk),
    .resetn(resetn),

    .in_data(in_data),
    .in_valid(in_valid),
    .in_ready(in_ready),
    .in_last(in_last),
    
    .out_ready_BUILD(in_ready_hash[0]),
    .out_data_BUILD(out_data_CONV[0]),
    .out_valid_BUILD(out_valid_CONV[0]),
    .out_last_BUILD(out_last_processed_CONV[0]),
    
    .out_ready_PROBE(in_ready_hash[1]),
    .out_data_PROBE(out_data_CONV[1]),
    .out_valid_PROBE(out_valid_CONV[1]),
    .out_last_PROBE(out_last_processed_CONV[1]),
    .out_serialnum(out_serialnum_CONV),
    .curr_sn(next_CC)
);

murmur_multi  #(
  .NUM_HASHER(8)
)murmur_inst_build(
        .clk(clk),
        .resetn(resetn),

        .in_ready(in_ready_hash[0]),
        .in_data(out_data_CONV[0]),
        .in_valid(out_valid_CONV[0]),
        .in_last_processed(out_last_processed_CONV[0]),
        .in_serialnum(),
        
        .out_ready(in_ready_DD8[0]),
        .out_tuple(out_data_hash[0]),
        .out_tag(out_tag_hash[0]),
        .out_valid(out_valid_hash[0]),
        .out_last_processed(out_last_processed_hash[0]),
        .out_serialnum()
    );

murmur_multi  #(
  .NUM_HASHER(8)
) murmur_inst_probe (
        .clk(clk),
        .resetn(resetn),
        
        .in_ready(in_ready_hash[1]),
        .in_data(out_data_CONV[1]),
        .in_valid(out_valid_CONV[1]),
        .in_last_processed(out_last_processed_CONV[1]),
        .in_serialnum(out_serialnum_CONV),
        
        .out_ready(in_ready_DD8[1]),
        .out_tuple(out_data_hash[1]),
        .out_tag(out_tag_hash[1]),
        .out_valid(out_valid_hash[1]),
        .out_last_processed(out_last_processed_hash[1]),
        .out_serialnum(out_serialnum_hash)
    );

  
DD8_3bit #(
    .INPUT_SIZE(INPUT_SIZE),
    .decision_bit(31)
) DD_build (
    .clk(clk),
    .resetn(resetn),

    .in_ready(in_ready_DD8[0]),
    .in_data(out_data_hash[0]),
    .in_tag(out_tag_hash[0]),
    .in_valid(out_valid_hash[0]),
    .in_last_processed(out_last_processed_hash[0]),
    .in_serialnum(),

    .out_ready(in_ready_HT[0]),
    .out_data(out_data_DD8[0]),
    .out_tag(out_tag_DD8[0]),
    .out_valid(out_valid_DD8[0]),
    .out_last_processed(out_last_processed_DD8[0]),
    .out_serialnum()
  );


  DD8_3bit #(
    .INPUT_SIZE(INPUT_SIZE),
    .decision_bit(31)
  ) DD_probe (
    .clk(clk),
    .resetn(resetn),

    .in_ready(in_ready_DD8[1]),
    .in_data(out_data_hash[1]),
    .in_tag(out_tag_hash[1]),
    .in_valid(out_valid_hash[1]),
    .in_last_processed(out_last_processed_hash[1]),
    .in_serialnum(out_serialnum_hash),

    .out_ready(in_ready_HT[1]),
    .out_data(out_data_DD8[1]),
    .out_tag(out_tag_DD8[1]),
    .out_valid(out_valid_DD8[1]),
    .out_last_processed(out_last_processed_DD8[1]),
    .out_serialnum(out_serialnum_DD8)
  );

genvar i;
for (i =0; i<8; i=i+1) begin
    HashTableV9 #(
            .TUPLE_SIZE(INPUT_SIZE),
            .ROW_BITS(ROW_BITS),
            .COL_BITS(COL_BITS)
        ) ht_000 (
            .clk(clk),
            .resetn(resetn),

            .in_ready_BUILD(in_ready_HT[0][i]),
            .in_data_BUILD(out_data_DD8[0][i]),
            .in_hash_BUILD(out_tag_DD8[0][i]),
            .in_valid_BUILD(out_valid_DD8[0][i]),
            .in_last_processed_BUILD(out_last_processed_DD8[0][i]),

            .in_ready_PROBE(in_ready_HT[1][i]),
            .in_data_PROBE(out_data_DD8[1][i]),
            .in_hash_PROBE(out_tag_DD8[1][i]),
            .in_valid_PROBE(out_valid_DD8[1][i]),
            .in_last_processed_PROBE(out_last_processed_DD8[1][i]),
            .in_serialnum(out_serialnum_DD8[i]),

            .out_ready(in_ready_DD82[i]),
            .out_data(out_data_HT[i]),
            .out_valid(out_valid_HT[i]),
            .out_last_processed(out_last_processed_HT[i]),
            .out_serialnum(out_serialnum_HT[i]),
            .out_was_joined(out_was_joined_HT[i])
        );

        
end

DD8_3bit #(
    .INPUT_SIZE(128),
    .decision_bit(2)
  ) DD_out (
    .clk(clk),
    .resetn(resetn),

    .in_ready(in_ready_DD82),
    .in_data(out_data_HT),
    .in_tag({out_serialnum_HT[7][63:32], out_serialnum_HT[6][63:32], out_serialnum_HT[5][63:32], out_serialnum_HT[4][63:32], out_serialnum_HT[3][63:32], out_serialnum_HT[2][63:32], out_serialnum_HT[1][63:32], out_serialnum_HT[0][63:32]}),
    .in_valid(out_valid_HT),
    .in_last_processed(out_last_processed_HT),
    .in_serialnum(out_serialnum_HT),
    .in_was_joined(out_was_joined_HT),

    .out_ready(in_ready_SaR),
    .out_data(out_data_DD82),
    .out_tag(out_tag_DD82),
    .out_valid(out_valid_DD82),
    .out_last_processed(out_last_processed_DD82),
    .out_serialnum(out_serialnum_DD82),
    .out_was_joined(out_was_joined_DD82)
  );

  

genvar j;
for (j =0; j<8; j=j+1) begin
  
  store_and_release #(
    .DATA_SIZE(2*INPUT_SIZE),
    .MAX_NUM(MAX_IN_TRANSIT)
  ) SaRv3 (
    .clk(clk),
    .resetn(resetn),
    .in_ready(in_ready_SaR[j]),
    .in_data(out_data_DD82[j]),
    .in_valid(out_valid_DD82[j]),
    .in_serialnum(out_serialnum_DD82[j][31:0]),
    .in_joined(out_was_joined_DD82[j]),
    .out_ready(in_ready_rta[j]),
    .out_data(out_data_SaR[j]),
    .out_valid(out_valid_SaR[j]),
    .next_in_storage(next_in_storagev2[j]),
    .release_data(release_data[j]),
    .next(next_CC),
    .in_last_processed(out_last_processed_DD82[j]),
    .local_last_processed(out_last_processed_SaR[j])
  );
end


Command_and_Control # (
    .NUM_STORAGES(8)
) CaC (
    .clk(clk),
    .resetn(resetn),
    .in_is_stored(next_in_storagev2),
    .release_data(release_data),
    .next(next_CC),
    .local_last_processed(out_last_processed_SaR),
    .last_processed(out_last_processed_CC),
    .out_ready(in_ready_rta)
);


CONV_STREAM_to_AXI rta (
    .clk(clk),
    .rst_n(resetn),
    .in_ready(in_ready_rta),
    .in_data(out_data_SaR),
    .in_valid(out_valid_SaR),
    .in_last({out_last_processed_CC, out_last_processed_CC, out_last_processed_CC, out_last_processed_CC, out_last_processed_CC, out_last_processed_CC, out_last_processed_CC, out_last_processed_CC}),

    .ready_4_output(out_ready),
    .out_data(out_data),
    .out_keep(out_keep),
    .out_valid(out_valid),
    .out_last(out_last)
);


/*ila_PHJ_host inst_ila_PHJ_host (
    .clk(clk),
    .probe0(out_valid_hash[0]),
    .probe1(in_ready_DD8[0]),
    .probe2(out_last_processed_hash[0]),
    .probe3(out_valid_DD8[0]),
    .probe4(in_ready_HT[0]),
    .probe5(out_last_processed_DD8[0]),
    .probe6(out_data_hash[0]),
    .probe7(out_data_DD8[0])
);*/


endmodule
