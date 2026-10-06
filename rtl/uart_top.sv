module uart_top(uart_if vif);
  uart_tx u_tx(
    .clk(vif.clk), .rst_n(vif.rst_n), .baud_div(vif.baud_div),
    .parity_en(vif.parity_en), .parity_odd(vif.parity_odd),
    .tx_start(vif.tx_start), .tx_data(vif.tx_data),
    .tx(vif.tx), .tx_busy(vif.tx_busy), .tx_done(vif.tx_done)
  );

  uart_rx u_rx(
    .clk(vif.clk), .rst_n(vif.rst_n), .baud_div(vif.baud_div),
    .parity_en(vif.parity_en), .parity_odd(vif.parity_odd),
    .rx(vif.rx), .rx_data(vif.rx_data), .rx_valid(vif.rx_valid),
    .parity_error(vif.parity_error), .framing_error(vif.framing_error)
  );
endmodule
