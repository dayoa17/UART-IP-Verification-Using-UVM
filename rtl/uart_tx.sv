module uart_tx(
  input logic clk, rst_n,
  input logic [15:0] baud_div,
  input logic parity_en, parity_odd,
  input logic tx_start,
  input logic [7:0] tx_data,
  output logic tx, tx_busy, tx_done
);
  typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP} state_t;
  state_t state;
  logic [15:0] cnt;
  logic [2:0] bit_idx;
  logic [7:0] shreg;
  logic parity_bit;

  wire tick = (cnt == baud_div-1);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state<=IDLE; cnt<='0; bit_idx<='0; shreg<='0;
      tx<=1'b1; tx_busy<=1'b0; tx_done<=1'b0; parity_bit<=1'b0;
    end else begin
      tx_done <= 1'b0;
      if (state==IDLE || tick) cnt <= '0;
      else cnt <= cnt + 1'b1;

      case (state)
        IDLE: begin
          tx<=1'b1; tx_busy<=1'b0;
          if (tx_start) begin
            shreg<=tx_data; bit_idx<='0; tx_busy<=1'b1; tx<=1'b0;
            parity_bit <= (^tx_data) ^ parity_odd;
            state<=START;
          end
        end
        START: if (tick) begin
          tx<=shreg[0]; shreg<={1'b0,shreg[7:1]}; state<=DATA;
        end
        DATA: if (tick) begin
          if (bit_idx==3'd7) begin
            if (parity_en) begin tx<=parity_bit; state<=PARITY; end
            else begin tx<=1'b1; state<=STOP; end
          end else begin
            bit_idx<=bit_idx+1'b1; tx<=shreg[0]; shreg<={1'b0,shreg[7:1]};
          end
        end
        PARITY: if (tick) begin tx<=1'b1; state<=STOP; end
        STOP: if (tick) begin tx<=1'b1; tx_busy<=1'b0; tx_done<=1'b1; state<=IDLE; end
        default: state<=IDLE;
      endcase
    end
  end
endmodule
