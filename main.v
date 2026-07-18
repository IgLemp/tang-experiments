`timescale 1ns/1ps

module main #(
  parameter integer unsigned LEDS_NR = 6
) (
  input clk_i,
  input key_i,
  input rst_i,
  input  RXD_i,
  output TXD_o,
  output [5:0] led_o
);

localparam integer unsigned CLOCK_FREQ = 27_000_000;
localparam integer unsigned BAUD_RATE = 115200;

logic rx_i;
logic tx_o;

logic [7:0]data_i;
logic send_str_i;

logic [7:0]data_o;
logic recv_str_o;

logic recv_busy_o;
logic send_busy_o;

assign rx_i = RXD_i;
assign TXD_o = tx_o;

assign data_i = data_o;
assign send_str_i = recv_str_o;

assign led_o[5:0] = ~data_o[5:0];

rs232 #(
  .CLOCK_FREQ(CLOCK_FREQ),
  .BAUD_RATE(BAUD_RATE)
) rs232_inst (.*);

endmodule
