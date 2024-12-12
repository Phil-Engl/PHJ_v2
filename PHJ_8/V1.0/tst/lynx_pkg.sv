
/**
  * Copyright (c) 2021, Systems Group, ETH Zurich
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * 1. Redistributions of source code must retain the above copyright notice,
  * this list of conditions and the following disclaimer.
  * 2. Redistributions in binary form must reproduce the above copyright notice,
  * this list of conditions and the following disclaimer in the documentation
  * and/or other materials provided with the distribution.
  * 3. Neither the name of the copyright holder nor the names of its contributors
  * may be used to endorse or promote products derived from this software
  * without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  * EVEN IF ADVISED OF THE POSSIBILITY OF    SUCH DAMAGE.
  */

`define EN_STRM
`define EN_CRED_LOCAL
`define EN_CRED_REMOTE
`define EN_AVX
`define EN_WB
`define EN_NET_0
`define EN_ACLK
`define EN_NCLK
`define EN_XCH_0
`define EN_STATS
`define VITIS_HLS
	
package lynxTypes;

    // ========================---------------------------------------------
    // Util functions
    // ========================---------------------------------------------
    function integer clog2s;
    input [31:0] v;
    reg [31:0] value;
    begin
        value = v;
        if (value == 1) begin
            clog2s = 1;
        end
        else begin
            value = value-1;
            for (clog2s=0; value>0; clog2s=clog2s+1)
                value = value>>1;
        end
    end
    endfunction

    // ========================---------------------------------------------
    // Static
    // ========================---------------------------------------------

    // AXI
    parameter integer AXIL_DATA_BITS = 64;
    parameter integer AVX_DATA_BITS = 256;
    parameter integer AXI_DATA_BITS = 512;
    parameter integer AXI_ADDR_BITS = 64;
    parameter integer AXI_NET_BITS = 512;
    parameter integer AXI_DDR_BITS = 512;
    parameter integer AXI_TLB_BITS = 128;
    parameter integer AXI_ID_BITS = 6;
    parameter integer AXI_BPSS_BAR_BITS = 28;

    // TLB ram
    parameter integer TLB_S_ORDER = 10;
    parameter integer PG_S_BITS = 12;
    parameter integer N_S_ASSOC = 4;

    parameter integer TLB_L_ORDER = 9;
    parameter integer PG_L_BITS = 21;
    parameter integer N_L_ASSOC = 2;

    parameter integer TLB_DATA_BITS = 96;
    parameter integer N_TLB_ACTV = 16;

    parameter integer TLB_TMR_REF_CLR = 100000;
    parameter integer CACHE_MAX_SIZE = 32;

    // IRQ
    parameter integer IRQ_OFFL = 0;
    parameter integer IRQ_SYNC = 1;
    parameter integer IRQ_INVLDT = 2;
    parameter integer IRQ_PFAULT = 3;
    parameter integer IRQ_NOTIFY = 4;
    parameter integer IRQ_RCNFG = 5;

    // Data
    parameter integer ADDR_BITS = 64;
    parameter integer PADDR_BITS = 40;
    parameter integer VADDR_BITS = 48;
    parameter integer LEN_BITS = 28;
    parameter integer DEST_BITS = 4;
    parameter integer PID_BITS = 6;
    parameter integer HPID_BITS = 32;
    parameter integer USER_BITS = 4;
    parameter integer NOTIFY_BITS = 32;
    parameter integer BEAT_LOG_BITS = $clog2(AXI_DATA_BITS/8);
    parameter integer BLEN_BITS = LEN_BITS - BEAT_LOG_BITS;
    parameter integer OFFS_BITS = 6;
    parameter integer OPCODE_BITS = 5;
    parameter integer STRM_BITS = 2;

    parameter integer STRM_CARD = 0;
    parameter integer STRM_HOST = 1;
    parameter integer STRM_TCP = 2;
    parameter integer STRM_RDMA = 3;

    // Queue depth
    parameter integer QUEUE_DEPTH = 8;

    // Slices
    parameter integer N_REG_STAT_S0 = 2; // 2
    parameter integer N_REG_STAT_S1 = 2; // 2
    parameter integer N_REG_SHELL_S0 = 3; // 2
    parameter integer N_REG_SHELL_S1 = 2; // 2
    parameter integer N_REG_DYN_HOST_S0 = 3; // 4
    parameter integer N_REG_DYN_HOST_S1 = 3; // 3
    parameter integer N_REG_DYN_HOST_S2 = 3; // 3
    parameter integer N_REG_DYN_CARD_S0 = 3; // 4
    parameter integer N_REG_DYN_CARD_S1 = 3; // 3
    parameter integer N_REG_DYN_CARD_S2 = 3; // 3
    parameter integer N_REG_DYN_NET_S0 = 3; // 4
    parameter integer N_REG_DYN_NET_S1 = 3; // 3
    parameter integer N_REG_DYN_NET_S2 = 3; // 3
    parameter integer N_REG_NET_S0 = 6; // 4
    parameter integer N_REG_NET_S1 = 4; // 3
    parameter integer N_REG_NET_S2 = 5; // 4
    parameter integer N_REG_CLK_CNVRT = 4; // 5
    parameter integer N_REG_ECI_S0 = 3; // 3
    parameter integer N_REG_ECI_S1 = 2; // 2
    parameter integer N_REG_STA_DCPL = 3; // 3
    parameter integer N_REG_DYN_DCPL = 3; // 3
    parameter integer N_REG_PR = 4; // 4
    parameter integer NET_STATS_DELAY = 4; // 4
    parameter integer XDMA_STATS_DELAY = 4; // 4

    // Network
    parameter integer ARP_LUP_REQ_BITS = 32;
    parameter integer ARP_LUP_RSP_BITS = 56;
    parameter integer IP_ADDR_BITS = 32;
    parameter integer MAC_ADDR_BITS = 48;
    parameter integer DEF_MAC_ADDRESS = 48'hE59D02350A00; // LSB first, 00:0A:35:02:9D:E5
    parameter integer DEF_IP_ADDRESS = 32'hD1D4010B; // LSB first, 0B:01:D4:D1
    parameter integer NET_STRM_DOWN_THRS = 256;

    // Network buffers
    parameter integer MEM_CMD_BITS = 96;
    parameter integer MEM_STS_BITS = 8;

    // Network RDMA
    parameter integer APP_READ = 0;
    parameter integer APP_WRITE = 1;
    parameter integer APP_SEND = 2;
    parameter integer APP_IMMED = 3;

    parameter integer RC_SEND_FIRST = 5'h0;
    parameter integer RC_SEND_MIDDLE = 5'h1;
    parameter integer RC_SEND_LAST = 5'h2;
    parameter integer RC_SEND_ONLY = 5'h4;
    parameter integer RC_RDMA_WRITE_FIRST = 5'h6;
    parameter integer RC_RDMA_WRITE_MIDDLE = 5'h7;
    parameter integer RC_RDMA_WRITE_LAST = 5'h8;
    parameter integer RC_RDMA_WRITE_LAST_WITH_IMD = 5'h9;
    parameter integer RC_RDMA_WRITE_ONLY = 5'hA;
    parameter integer RC_RDMA_WRITE_ONLY_WIT_IMD = 5'hB;
    parameter integer RC_RDMA_READ_REQUEST = 5'hC;
    parameter integer RC_RDMA_READ_RESP_FIRST = 5'hD;
    parameter integer RC_RDMA_READ_RESP_MIDDLE = 5'hE;
    parameter integer RC_RDMA_READ_RESP_LAST = 5'hF;
    parameter integer RC_RDMA_READ_RESP_ONLY = 5'h10;
    parameter integer RC_ACK = 5'h11;

    parameter integer RDMA_ACK_BITS = 64;
    parameter integer RDMA_ACK_QPN_BITS = 10;
    parameter integer RDMA_ACK_SYNDROME_BITS = 8;
    parameter integer RDMA_ACK_PSN_BITS = 24;
    parameter integer RDMA_ACK_MSN_BITS = 24;
    parameter integer RDMA_BASE_REQ_BITS = 144;
    parameter integer RDMA_VADDR_BITS = 64;
    parameter integer RDMA_LEN_BITS = 32;
    parameter integer RDMA_REQ_BITS = 248;
    parameter integer RDMA_OPCODE_BITS = 5;
    parameter integer RDMA_QPN_BITS = 16;
    parameter integer RDMA_IMM_BITS = 32;
    parameter integer RDMA_QP_INTF_BITS = 168;
    parameter integer RDMA_QP_CONN_BITS = 184;
    parameter integer RDMA_LVADDR_OFFS = 0;
    parameter integer RDMA_RVADDR_OFFS = RDMA_VADDR_BITS;
    parameter integer RDMA_LEN_OFFS = 2*RDMA_VADDR_BITS;
    parameter integer RDMA_PARAMS_OFFS = 2*RDMA_VADDR_BITS + RDMA_LEN_BITS;
    parameter integer RDMA_MSN_BITS = 24;
    parameter integer RDMA_SNDRM_BITS = 8;
    parameter integer RDMA_N_RD_OUTSTANDING = 8;
    parameter integer RDMA_N_WR_OUTSTANDING = 16;
    parameter integer RDMA_MAX_SINGLE_READ = 32 * 1024;
    parameter integer RDMA_MODE_PARSE = 0;
    parameter integer RDMA_MODE_RAW = 1;
    parameter integer RDMA_WR_NET_THRS = 256; // beats
    parameter integer RDMA_MEM_SHIFT = 27;

    // Network TCP/IP
    parameter integer N_TCP_CHANNELS = 2;
    parameter integer TCP_PORT_OFFS = 49152;
    parameter integer TCP_PORT_ORDER = 10;
    parameter integer TCP_RSESSION_BITS = DEST_BITS + PID_BITS + DEST_BITS;
    parameter integer TCP_PORT_TABLE_DATA_BITS = 16;
    parameter integer TCP_PORT_REQ_BITS = 16;
    parameter integer TCP_PORT_RSP_BITS = 8;
    parameter integer TCP_OPEN_CONN_REQ_BITS = 48;
    parameter integer TCP_OPEN_CONN_RSP_BITS = 72;
    parameter integer TCP_CLOSE_CONN_REQ_BITS = 16;
    parameter integer TCP_NOTIFY_BITS = 88;
    parameter integer TCP_RD_PKG_REQ_BITS = 32;
    parameter integer TCP_RX_META_BITS = 16;
    parameter integer TCP_TX_META_BITS = 32;
    parameter integer TCP_TX_STAT_BITS = 64;

    parameter integer TCP_IP_ADDRESS_BITS = 32;
    parameter integer TCP_IP_PORT_BITS = 16;
    parameter integer TCP_SESSION_BITS = 16;
    parameter integer TCP_SUCCESS_BITS = 8;
    parameter integer TCP_LEN_BITS = 16;
    parameter integer TCP_REM_SPACE_BITS = 30;
    parameter integer TCP_ERROR_BITS = 2;
    parameter integer TCP_MEM_SHIFT = 0;
    parameter integer TCP_SID_BITS = 10;
    parameter integer TCP_OPCODE = 0;

    // ECI
    parameter integer N_LANES = 12;
    parameter integer N_LANES_GRPS = 3;
    parameter integer ECI_DATA_BITS = 1024;
    parameter integer ECI_ADDR_BITS = 40;
    parameter integer ECI_ID_BITS = 5;
    parameter integer ECI_WORD_BITS = 64;

    // ========================---------------------------------------------
    // Dynamic
    // ========================---------------------------------------------

    // SIM
    parameter CLK_PERIOD = 10ns;
    parameter RST_PERIOD = 20 * CLK_PERIOD;
    parameter AST_PERIOD = 40 * CLK_PERIOD;
    parameter TT = 2ns;
    parameter TA = 1ns;

    // Flow
    parameter string  FDEV = "u55c";
    
    parameter integer N_XCHAN = 3;
    parameter integer N_XCHAN_BITS = clog2s(N_XCHAN);
    parameter integer N_SCHAN = 2;
    parameter integer N_SCHAN_BITS = clog2s(2);
    parameter integer N_CHAN = 1;
    parameter integer N_CHAN_BITS = clog2s(1);
    
    parameter integer STAT_PROBE = 4276994270;
    parameter integer SHELL_PROBE = 4276994270;
    
    parameter integer N_REGIONS = 1;
    parameter integer N_REGIONS_BITS = clog2s(1);

    parameter integer N_OUTSTANDING = 8;
    parameter integer N_OUTSTANDING_REGION = 32;

    parameter integer PMTU_BYTES = 4096;
    
    parameter integer DDR_CHAN_SIZE = 0;
    parameter integer HBM_CHAN_SIZE = 34;
    
    parameter integer N_DDR_CHAN = 0;
    parameter integer N_DDR_CHAN_BITS = clog2s(0);
    parameter integer N_MEM_CHAN = 0;
    parameter integer N_MEM_CHAN_BITS = clog2s(0);
    parameter integer DDR_FRAG_SIZE = 1024;
    parameter integer PR_FLOW = 0;
    parameter integer RECONFIG_EOS_TIME = 1000000;

    parameter integer AVX_FLOW = 1;
    parameter integer BPSS_FLOW = 1;
    parameter integer WB_FLOW = 1;
    parameter integer STRM_FLOW = 1;
    parameter integer MEM_FLOW = 0;
    parameter integer RDMA_FLOW = 0;
    parameter integer TCP_FLOW = 0;
    parameter integer N_WBS = 2;
    parameter integer QSFP = 0;

    parameter integer N_CARD_AXI = 1;
    parameter integer N_STRM_AXI = 1;
    parameter integer N_RDMA_AXI = 1;

    // ========================---------------------------------------------
    // Structs
    // ========================---------------------------------------------

    // 
    // REQ
    //
    
    typedef struct packed {
        // Opcode
        logic [OPCODE_BITS-1:0] opcode;
        logic [STRM_BITS-1:0] strm;
        logic mode;
        logic rdma;
        logic remote;

        // ID
        logic [DEST_BITS-1:0] vfid; // rsrvd
        logic [PID_BITS-1:0] pid;
        logic [DEST_BITS-1:0] dest;

        // FLAGS
        logic last;

        // DESC
        logic [VADDR_BITS-1:0] vaddr;
        logic [LEN_BITS-1:0] len;

        // RSRVD
        logic actv; // rsrvd
        logic host; // rsrvd
        logic [OFFS_BITS-1:0] offs; // rsrvd

        logic [128-OFFS_BITS-2-VADDR_BITS-LEN_BITS-1-2*DEST_BITS-PID_BITS-3-STRM_BITS-OPCODE_BITS-1:0] rsrvd;
    } req_t;

    typedef struct packed {
        req_t req_1; // rd, local
        req_t req_2; // wr, remote
    } dreq_t;

    typedef struct packed {
        logic [OPCODE_BITS-1:0] opcode;
        logic [STRM_BITS-1:0] strm;
        logic remote;
        logic host;
        logic [DEST_BITS-1:0] dest;
        logic [PID_BITS-1:0] pid;
        logic [DEST_BITS-1:0] vfid;
        logic [32-OPCODE_BITS-STRM_BITS-2-DEST_BITS-PID_BITS-DEST_BITS-1:0] rsrvd;
    } ack_t;

    typedef struct packed {
        ack_t ack;
        logic last;
    } dack_t;

    typedef struct packed {
        logic [DEST_BITS-1:0] dest;
        logic [BLEN_BITS-1:0] len;
        logic [PID_BITS-1:0] pid;
    } mux_user_t;

    typedef struct packed {
        logic [N_REGIONS_BITS-1:0] vfid;
        logic [BLEN_BITS-1:0] len;
        logic last;
    } mux_host_t;

    typedef struct packed {
        logic [N_CHAN_BITS-1:0] chan;
        logic [BLEN_BITS-1:0] len;
        logic last;
    } mux_shell_t;

    // 
    // IRQ
    //

    typedef struct packed {
        logic success;
    } pf_t;

    typedef struct packed {
        logic lock;
        logic last;
        logic [HPID_BITS-1:0] hpid;
        logic [VADDR_BITS-1:0] vaddr;
        logic [LEN_BITS-1:0] len;
    } inv_t;

    typedef struct packed {
        logic [VADDR_BITS-1:0] vaddr;
        logic [LEN_BITS-1:0] len;
        logic [STRM_BITS-1:0] strm;
        logic [PID_BITS-1:0] pid;
    } irq_pft_t;

    typedef struct packed {
        logic [HPID_BITS-1:0] hpid;
    } irq_inv_t;

    typedef struct packed {
        logic [PID_BITS-1:0] pid;
        logic [31:0] value;
    } irq_not_t;

    //
    // WB
    //

    typedef struct packed {
        logic [PADDR_BITS-1:0] paddr;
        logic [32-1:0] value;
    } wback_t;

    //
    // DMA
    //

    typedef struct packed {
        // Req
        logic [PADDR_BITS-1:0] paddr;
        logic [LEN_BITS-1:0] len;
        logic last;

        logic [96-PADDR_BITS-LEN_BITS-1-1:0] rsrvd;
    } dma_req_t;

    typedef struct packed {
        logic done;
    } dma_rsp_t;

    typedef struct packed {
        // Req
        logic [PADDR_BITS-1:0] paddr_host;
        logic [PADDR_BITS-1:0] paddr_card;
        logic [LEN_BITS-1:0] len;
        logic last;

        // Completion
        logic [128-1-LEN_BITS-2*PADDR_BITS-1:0] rsrvd;
    } dma_isr_req_t;

    typedef struct packed {
        logic done;
    } dma_isr_rsp_t;

    //
    // RDMA
    //

    typedef struct packed {
        logic [47:0] vaddr;
        logic [31:0] r_key;
        logic [23:0] local_psn;
        logic [23:0] remote_psn;
        logic [23:0] qp_num;
        logic [31:0] new_state;
    } rdma_qp_ctx_t;

    typedef struct packed {
        logic [15:0] remote_udp_port;
        logic [127:0] remote_ip_address;
        logic [23:0] remote_qpn;
        logic [15:0] local_qpn;
    } rdma_qp_conn_t;

    //
    // TCP
    //

    typedef struct packed {
        logic [TCP_IP_PORT_BITS-1:0] ip_port;
    } tcp_listen_req_t;

    typedef struct packed {
        logic [DEST_BITS-1:0] dest;
        logic [PID_BITS-1:0] pid;
        logic [DEST_BITS-1:0] vfid;
        logic [TCP_IP_PORT_BITS-1:0] ip_port;
    } tcp_listen_req_r_t;

    typedef struct packed {
        logic [TCP_SUCCESS_BITS-1:0] open_port_success;
    } tcp_listen_rsp_t;

    typedef struct packed {
        logic [DEST_BITS-1:0] vfid;
        logic [TCP_SUCCESS_BITS-1:0] open_port_success;
    } tcp_listen_rsp_r_t;

    typedef struct packed {
        logic [TCP_IP_PORT_BITS-1:0] ip_port;
        logic [TCP_IP_ADDRESS_BITS-1:0] ip_address;
    } tcp_open_req_t;

    typedef struct packed {
        logic rsrvd;
        logic close;
        logic [DEST_BITS-1:0] dest;
        logic [PID_BITS-1:0] pid;
        logic [DEST_BITS-1:0] vfid;
        logic [TCP_IP_PORT_BITS-1:0] ip_port; 
        logic [TCP_IP_ADDRESS_BITS-1:0] ip_address;
    } tcp_open_req_r_t;

    typedef struct packed {
        logic [TCP_IP_PORT_BITS-1:0] ip_port;
        logic [TCP_IP_ADDRESS_BITS-1:0] ip_address;
        logic [TCP_SUCCESS_BITS-1:0] success;
        logic [TCP_SESSION_BITS-1:0] sid;
    } tcp_open_rsp_t;

    typedef struct packed {
        logic [PID_BITS-1:0] pid; //
        logic [DEST_BITS-1:0] vfid; //
        logic [TCP_SUCCESS_BITS-1:0] success; // 
    } tcp_open_rsp_r_t;

    typedef struct packed {
        logic [TCP_SESSION_BITS-1:0] sid;
    } tcp_close_req_t;

    typedef struct packed {
        logic [5:0] rsrvd;
        logic opened;
        logic closed;
        logic [TCP_IP_PORT_BITS-1:0] dst_port;
        logic [TCP_IP_ADDRESS_BITS-1:0] ip_address;
        logic [TCP_LEN_BITS-1:0] len;
        logic [TCP_SESSION_BITS-1:0] sid;
    } tcp_notify_t;

    typedef struct packed {
        logic [TCP_LEN_BITS-1:0] len;
        logic [TCP_SESSION_BITS-1:0] sid;
    } tcp_rd_pkg_t; 

    typedef struct packed {
        logic [TCP_LEN_BITS-1:0] len;
        logic [DEST_BITS-1:0] dest;
        logic [PID_BITS-1:0] pid;
        logic [DEST_BITS-1:0] vfid;
    } tcp_meta_r_t;

    typedef struct packed {
        logic [TCP_LEN_BITS-1:0] len;
        logic [TCP_SESSION_BITS-1:0] sid;
    } tcp_meta_t;

    typedef struct packed {
        logic [TCP_LEN_BITS-1:0] len;
        logic [TCP_SESSION_BITS-1:0] sid;
    } tcp_rx_meta_t;

    typedef struct packed {
        logic [TCP_LEN_BITS-1:0] len;
        logic [TCP_SESSION_BITS-1:0] sid;
    } tcp_tx_meta_t;

    typedef struct packed {
        logic [TCP_ERROR_BITS-1:0] error;
        logic [TCP_REM_SPACE_BITS-1:0] remaining_space;
        logic [TCP_LEN_BITS-1:0] len;
        logic [TCP_SESSION_BITS-1:0] sid;
    } tcp_tx_stat_t;

    typedef struct packed {
        logic [31:0] bpss_h2c_req_counter;
        logic [31:0] bpss_c2h_req_counter;
        logic [31:0] bpss_h2c_cmpl_counter;
        logic [31:0] bpss_c2h_cmpl_counter;
        logic [31:0] bpss_h2c_axis_counter;
        logic [31:0] bpss_c2h_axis_counter;
    } xdma_stat_t;

    typedef struct packed {
        logic [31:0] rx_pkg_counter;
        logic [31:0] tx_pkg_counter;
        logic [31:0] arp_rx_pkg_counter;
        logic [31:0] arp_tx_pkg_counter;
        logic [31:0] icmp_rx_pkg_counter;
        logic [31:0] icmp_tx_pkg_counter;
        logic [31:0] tcp_rx_pkg_counter;
        logic [31:0] tcp_tx_pkg_counter;
        logic [31:0] roce_rx_pkg_counter;
        logic [31:0] roce_tx_pkg_counter;
        logic [31:0] ibv_rx_pkg_counter;
        logic [31:0] ibv_tx_pkg_counter;
        logic [31:0] roce_psn_drop_counter;
        logic [31:0] roce_retrans_counter;
        logic [15:0] tcp_session_counter;
        logic axis_stream_down;
        logic [512 - (14*32+16+1) - 1:0] rsrvd; 
    } net_stat_t;

    // -----------------------------------------------------------------
    // Additional functions
    // -----------------------------------------------------------------
    function logic is_strm_local;
    input [STRM_BITS-1:0] strm;
    begin
        if (strm == STRM_HOST || strm == STRM_CARD) begin
            is_strm_local = 1'b1;
        end
        else begin
            is_strm_local = 1'b0;
        end
    end
    endfunction
    
    function logic is_opcode_rd_req;
    input [OPCODE_BITS-1:0] opcode;
    begin
        if (opcode == RC_RDMA_READ_REQUEST) begin
            is_opcode_rd_req = 1'b1;
        end
        else begin
            is_opcode_rd_req = 1'b0;
        end
    end
    endfunction

    function logic is_opcode_ack;
    input [OPCODE_BITS-1:0] opcode;
    begin
        if (opcode == RC_ACK) begin
            is_opcode_ack = 1'b1;
        end
        else begin
            is_opcode_ack = 1'b0;
        end
    end
    endfunction

    function logic is_opcode_rd_resp;
    input [OPCODE_BITS-1:0] opcode;
    begin
        if (opcode == RC_RDMA_READ_RESP_FIRST ||
            opcode == RC_RDMA_READ_RESP_MIDDLE ||
            opcode == RC_RDMA_READ_RESP_LAST ||
            opcode == RC_RDMA_READ_RESP_ONLY) begin
            is_opcode_rd_resp = 1'b1;
        end
        else begin
            is_opcode_rd_resp = 1'b0;
        end
    end
    endfunction

    function logic is_opcode_wr;
    input [OPCODE_BITS-1:0] opcode;
    begin
        if (opcode == RC_RDMA_WRITE_FIRST ||
            opcode == RC_RDMA_WRITE_MIDDLE ||
            opcode == RC_RDMA_WRITE_LAST ||
            opcode == RC_RDMA_WRITE_ONLY) begin
            is_opcode_wr = 1'b1;
        end
        else begin
            is_opcode_wr = 1'b0;
        end
    end
    endfunction

    function logic is_opcode_send;
    input [OPCODE_BITS-1:0] opcode;
    begin
        if (opcode == RC_SEND_FIRST ||
            opcode == RC_SEND_MIDDLE ||
            opcode == RC_SEND_LAST ||
            opcode == RC_SEND_ONLY) begin
            is_opcode_send = 1'b1;
        end
        else begin
            is_opcode_send = 1'b0;
        end
    end
    endfunction

endpackage