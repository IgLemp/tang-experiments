module main #(
  parameter integer unsigned LEDS_NR = 6
) (
  input clk_i,
  input key_i,
  output [LEDS_NR-1:0] led_o
);

logic key = key_i;

logic [25:0] ctr_q;
logic [25:0] ctr_d;

// Sequential code (flip-flop)
always @(posedge clk) begin
  if (key) begin
    ctr_q <= ctr_d;
  end
end

// Combinational code (boolean logic)
assign ctr_d = ctr_q + 1'b1;
assign led = {ctr_q[25:25-(LEDS_NR - 2)], |ctr_q[25-(LEDS_NR - 1):25-(LEDS_NR)]};

endmodule
