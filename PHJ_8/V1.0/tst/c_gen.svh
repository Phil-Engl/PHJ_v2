import common::*;

// AXIS Generator
class c_gen;
  // Send to driver (mailbox)
  mailbox gen2drv;

  // Params
  c_struct_t params;

  // Completion
  event done;
  
  //
  // C-tor
  //
  function new(mailbox gen2drv, input c_struct_t params);
    this.gen2drv = gen2drv;
    this.params = params;
  endfunction
  


  function get_tuples(int file);
    //logic [511:0] tuples_hex;
    read_succ = $fgets(line_from_file, file);
      for (int i=0; i<8; i=i+1) begin
            r[i] = $sscanf(line_from_file.substr(i*16,(i+1)*16-1), "%h", single_tuple_hex[i]);
            //$display("hex: %h", single_tuple_hex[i]);
      end
      tuples_hex[63:0]    = single_tuple_hex[7];
      tuples_hex[127:64]  = single_tuple_hex[6];
      tuples_hex[191:128] = single_tuple_hex[5];
      tuples_hex[255:192] = single_tuple_hex[4];
      tuples_hex[319:256] = single_tuple_hex[3];
      tuples_hex[383:320] = single_tuple_hex[2];
      tuples_hex[447:384] = single_tuple_hex[1];
      tuples_hex[511:448] = single_tuple_hex[0];
      //return tuples_hex;
      /*tuples_hex[63:0]    = single_tuple_hex[0];
      tuples_hex[127:64]  = single_tuple_hex[1];
      tuples_hex[191:128] = single_tuple_hex[2];
      tuples_hex[255:192] = single_tuple_hex[3];
      tuples_hex[319:256] = single_tuple_hex[4];
      tuples_hex[383:320] = single_tuple_hex[5];
      tuples_hex[447:384] = single_tuple_hex[6];
      tuples_hex[511:448] = single_tuple_hex[7];*/

  endfunction
  //
  // Run
  // --------------------------------------------------------------------------
  // This is the function to edit if any custom stimulus is needed. 
  // By default it will generate random stimulus n_trs times.
  // --------------------------------------------------------------------------
  //

  int build_file;
  int probe_file;

  string line_from_file;
  logic read_succ;
  int r [7:0];
  bit [7:0][63:0] single_tuple_hex;
  logic [511:0] tuples_hex;

  int NUM_INPUT_LINES = 10;
  
  task run();
    c_trs trs;
    #(params.delay*CLK_PERIOD);

    build_file = $fopen("/scratch/phil/build_tuples.txt", "r");
    
    //for(int i = 0; i < params.n_trs; i++) begin
    for(int i = 0; i < NUM_INPUT_LINES; i++) begin
        trs = new();
        get_tuples(build_file);
        trs.tdata = tuples_hex;
        trs.tlast = i == (NUM_INPUT_LINES-1);
        trs.display("Gen");
        gen2drv.put(trs);
    end
    
    $fclose(build_file);
    probe_file = $fopen("/scratch/phil/probe_tuples.txt", "r");
    //repeat (100) @(posedge gen2drv.aclk);
    #(params.delay*CLK_PERIOD*100);

    
    for(int i = 0; i < NUM_INPUT_LINES; i++) begin
        trs = new();
        get_tuples(probe_file);
        trs.tdata = tuples_hex;
        trs.tlast = i == (NUM_INPUT_LINES-1);
        trs.display("Gen");
        gen2drv.put(trs);
    end

    $fclose(probe_file);


    -> done;
  endtask

endclass
