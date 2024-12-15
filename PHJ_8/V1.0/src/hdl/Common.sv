`timescale 1ns / 1ps

import lynxTypes::*;

package common;
    parameter integer HASH_WIDTH = 256;
    parameter integer LBA_WIDTH = 32;
    parameter integer DATA_NODE_IDX_WIDTH = 32;
    parameter integer NODE_IDX_WIDTH = 32;

    parameter integer PAGE_SIZE = 8192; // in Bytes
    parameter integer PAGE_SIZE_WIDTH = $clog2(PAGE_SIZE) + 1;
    parameter integer PAGE_BEATS = PAGE_SIZE / (lynxTypes::AXI_DATA_BITS / 8);    

    parameter integer COMP_DATA_BITS = 64;
    parameter integer COMP_CORES = 4;

    typedef enum logic[1:0] {WRITE, ERASE, READ, UPDATEHEADER} ssd_op_t;

    typedef struct packed {
        logic[HASH_WIDTH - 1:0]          sha3_hash;
        logic[LBA_WIDTH - 1:0]           ref_count;
        logic[DATA_NODE_IDX_WIDTH - 1:0] ssd_node_idx;
        logic[LBA_WIDTH - 1:0]           ssd_start;
        logic[LBA_WIDTH - 1:0]           ssd_len;
        logic[NODE_IDX_WIDTH - 1:0]      node_idx;
        ssd_op_t                         op_code;
    } ssd_instr_t;

    typedef logic[7:0] char_t;
    typedef logic[PAGE_SIZE_WIDTH - 1:0] page_size_t;
endpackage