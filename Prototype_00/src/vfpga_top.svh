always_comb axi_ctrl.tie_off_s();
always_comb notify.tie_off_m();
always_comb sq_rd.tie_off_m();
always_comb sq_wr.tie_off_m();
always_comb cq_rd.tie_off_s();
always_comb cq_wr.tie_off_s();

CompressionArbiter inst_arbiter (
    .clk(aclk),
    .rst_n(aresetn),
    .axis_host_recv(axis_host_recv[0]),
    .axis_host_send(axis_host_send[0])
);

// ILA
/*ila_PHJ_host inst_ila_PHJ_host (
    .clk(aclk),
    .probe0(axis_host_recv[0].tvalid),
    .probe1(axis_host_recv[0].tready),
    .probe2(axis_host_recv[0].tlast),
    .probe3(axis_host_send[0].tvalid),
    .probe4(axis_host_send[0].tready),
    .probe5(axis_host_send[0].tlast),
    .probe6(axis_host_recv[0].tdata),
    .probe7(axis_host_send[0].tdata)
);*/
