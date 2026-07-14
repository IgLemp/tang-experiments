`timescale 1ns/1ps

module rs232_tb();
  localparam integer unsigned CLOCK_FREQ = 100_000_000;
  localparam integer unsigned BAUD_RATE = 115200;
  localparam integer unsigned CYCLE_TICKS = CLOCK_FREQ / BAUD_RATE;
  logic clk_i;
  logic rst_i;

  logic rx_i;
  logic tx_o;

  logic [7:0]data_i;
  logic send_str_i;

  logic [7:0]data_o;
  logic recv_str_o;

  logic recv_busy_o;
  logic send_busy_o;

  rs232 #(.CLOCK_FREQ(CLOCK_FREQ), .BAUD_RATE(BAUD_RATE))rs232(.*);

  always #0.5 clk_i = ~clk_i;

  initial begin
    $dumpfile("rs232_tb.vcd");
    $dumpvars(0, rs232_tb);

    clk_i = 0;
    rst_i = 0;
    rx_i = 1;

    data_i = 0;
    send_str_i = 0;

    reset();
    send_msg();
    recv_msg();

    #1800

    $finish;
  end

task static reset();
  #1 rst_i = 0;
  #1 rst_i = 1;
  #1 rst_i = 0;
endtask

task static send_msg();
  #1 data_i = 8'b01011101;
  #1 send_str_i <= 0;
  #1 send_str_i <= 1;
  #1 send_str_i <= 0;
endtask;

task static recv_msg();
  #1 data_i = 8'b01011101;
  #CYCLE_TICKS rx_i = 0;
  #CYCLE_TICKS rx_i = data_i[0];
  #CYCLE_TICKS rx_i = data_i[1];
  #CYCLE_TICKS rx_i = data_i[2];
  #CYCLE_TICKS rx_i = data_i[3];
  #CYCLE_TICKS rx_i = data_i[4];
  #CYCLE_TICKS rx_i = data_i[5];
  #CYCLE_TICKS rx_i = data_i[6];
  #CYCLE_TICKS rx_i = data_i[7];
  #CYCLE_TICKS rx_i = 1;
endtask;

endmodule

