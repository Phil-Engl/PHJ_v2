import common::*;

// AXIS Scoreboard
class c_scb;
  // Mailbox handle
  mailbox mon2scb;
  mailbox drv2scb;

  // Params
  c_struct_t params;

  // Completion
  event done;
  
  // Fail flag
  integer fail;

  // Stream type
  integer strm_type;
  
  //
  // C-tor
  //
  function new(mailbox mon2scb, mailbox drv2scb, input c_struct_t params);
    this.mon2scb = mon2scb;
    this.drv2scb = drv2scb;
    this.params = params;
  endfunction
  
  //
  // Run
  // --------------------------------------------------------------------------
  // This is the function to edit if any custom stimulus is provided. 
  // By default it will not perform any checks and will only consume drv and mon interfaces.
  // --------------------------------------------------------------------------
  //

  // IN DEM FILE KANNSCH DA OUTPUT IN FILES SCHRIEBA!!!!!
function get_tuples(int file);
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
      
  endfunction



int ref_out_file = $fopen("/scratch/phil/reference_output.txt", "r");

string line_from_file;
logic read_succ;
int r [7:0];
bit [7:0][63:0] single_tuple_hex;
logic [511:0] tuples_hex;

logic last_seen;

int count;

int num_correct;
int num_wrong;


  task run;
    c_trs trs_mon;
    c_trs trs_drv;
    int i = 0;
    fail = 0;
    last_seen = 0;
    count = 0;
    num_correct = 0;
    num_wrong = 0;
    
    

    
    while (~last_seen) begin
      mon2scb.get(trs_mon);
      count++;
      
      
      get_tuples(ref_out_file);
        /*if(trs_mon.tdata == tuples_hex) begin
          trs_mon.display("CORRECT: ");
        end
        else begin
          trs_mon.display("FALSE: ");   
        end*/

      //assert (trs_mon.tdata == tuples_hex) $display("output count: %d", count);
      //else $error("Output is WRONG! %d", count);

      assert (trs_mon.tdata == tuples_hex) num_correct++;
      else num_wrong++;

      if (trs_mon.tlast) begin
        last_seen = 1;
      end
    end

    $display("correct: %d, wrong: %d", num_correct, num_wrong);
    -> done;
  endtask
  
endclass