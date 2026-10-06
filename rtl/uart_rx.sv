module uart_rx(
  input logic clk, rst_n,
  input logic [15:0] baud_div,
  input logic parity_en, parity_odd,
  input logic rx,
  output logic [7:0] rx_data,
  output logic rx_valid, parity_error, framing_error
);
  typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP} state_t;
  state_t state;
  logic [15:0] cnt;
  logic [2:0] bit_idx;
  logic [7:0] shreg;
  logic [15:0] half_div;

  always_comb begin
    half_div = baud_div >> 1;
    if (half_div==0) half_div = 1;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state<=IDLE; cnt<='0; bit_idx<='0; shreg<='0; rx_data<='0;
      rx_valid<=1'b0; parity_error<=1'b0; framing_error<=1'b0;
    end else begin
      rx_valid <= 1'b0;
      case (state)
        IDLE: begin
          cnt<='0; parity_error<=1'b0; framing_error<=1'b0;
          if (!rx) state<=START;
        end
        START: begin
          if (cnt==half_div-1) begin
            cnt<='0;
            if (!rx) begin bit_idx<='0; state<=DATA; end
            else state<=IDLE;
          end else cnt<=cnt+1'b1;
        end
        DATA: begin
          if (cnt==baud_div-1) begin
            cnt<='0; shreg[bit_idx]<=rx;
            if (bit_idx==3'd7) begin
              if (parity_en) state<=PARITY; else state<=STOP;
            end else bit_idx<=bit_idx+1'b1;
          end else cnt<=cnt+1'b1;
        end
        PARITY: begin
          if (cnt==baud_div-1) begin
            cnt<='0;
            parity_error <= (rx != ((^shreg) ^ parity_odd));
            state<=STOP;
          end else cnt<=cnt+1'b1;
        end
        STOP: begin
          if (cnt==baud_div-1) begin
            cnt<='0; framing_error<=!rx; rx_data<=shreg; rx_valid<=1'b1; state<=IDLE;
          end else cnt<=cnt+1'b1;
        end
        default: state<=IDLE;
      endcase
    end
  end
endmodule
