interface uart_if(input logic clk);
  logic rst_n;
  logic [15:0] baud_div;
  logic parity_en, parity_odd;

  logic tx_start;
  logic [7:0] tx_data;
  logic tx, tx_busy, tx_done;

  logic rx;
  logic [7:0] rx_data;
  logic rx_valid, parity_error, framing_error;
endinterface
