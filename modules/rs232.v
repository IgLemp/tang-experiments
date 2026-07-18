`timescale 1ns/1ps

module rs232 #(
  parameter integer unsigned CLOCK_FREQ = 27_000_000,
  parameter integer unsigned BAUD_RATE = 115200
) (
  input logic clk_i,
  input logic rst_i,

  input  logic rx_i,
  output logic tx_o,

  input  logic [7:0]data_i,
  input  logic send_str_i,

  output logic [7:0]data_o,
  output logic recv_str_o,

  output logic recv_busy_o,
  output logic send_busy_o
);

localparam integer unsigned CYCLE_TICKS      = CLOCK_FREQ / BAUD_RATE;
localparam integer unsigned HALF_CYCLE_TICKS = (CYCLE_TICKS - 1) / 2;

logic send_busy;
logic recv_busy;
logic [7:0]send_buffer;
logic [7:0]recv_buffer;
logic [3:0]bauds_sent;
logic [3:0]bauds_recv;

logic [$clog2(CYCLE_TICKS)-1:0]send_cycles;
logic [$clog2(CYCLE_TICKS)-1:0]recv_cycles;

logic rx_f;
logic rx_s;
logic rx_posedge;

assign rx_posedge = rx_s == 1 && rx_f == 0;

assign send_busy_o = send_busy;
assign recv_busy_o = recv_busy;

// testbench ///////////////////////////
initial begin
  $display("        CYCLE_TICKS = %d", CYCLE_TICKS);
  $display("   HALF_CYCLE_TICKS = %d", HALF_CYCLE_TICKS);
  $display("CYCLES BUFFER WIDTH = %d", $clog2(CYCLE_TICKS));
end

// SEND ////////////////////////////////////////////////////////////////////////
always_ff @(posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    send_busy <= 0;
    send_buffer <= 0;
    bauds_sent <= 0;
    send_cycles <= 0;
    tx_o <= 1;
  end else begin
    if (send_str_i & !send_busy) begin
      send_buffer <= data_i;
      bauds_sent <= 0;
      send_busy <= 1;
    end

    // Send start
    if (send_str_i == 1 && send_cycles == 0) tx_o <= 0;

    if (send_busy) begin
      // Send bit
      if (send_cycles == CYCLE_TICKS - 1 && bauds_sent != 8) begin
        send_buffer <= {1'b0, send_buffer[7:1]};
        tx_o <= send_buffer[0];
      end

      // Send end
      if (send_cycles == CYCLE_TICKS - 1 && bauds_sent == 8) tx_o <= 1;

      // Reset
      if (send_cycles == CYCLE_TICKS - 1 && bauds_sent == 9) begin
        bauds_sent <= 0;
        send_busy  <= 0;
        tx_o <= 1;
      end

      // Increment cycles
      if (send_cycles != CYCLE_TICKS - 1) begin
        send_cycles <= send_cycles + 1;
      end else begin
        send_cycles <= 0;
        if (bauds_sent != 9) bauds_sent <= bauds_sent + 1;
      end
    end
  end
end

// RECV ////////////////////////////////////////////////////////////////////////
always_ff @(posedge clk_i or posedge rst_i) begin
  if (rst_i) begin
    recv_busy <= 0;
    recv_buffer <= 0;
    bauds_recv <= 0;
    recv_cycles <= 0;
    data_o <= 0;
  end else begin
    // potentialy metastable to stable
    rx_f <= rx_i;
    rx_s <= rx_f;

    if (bauds_recv != 9 && recv_cycles != CYCLE_TICKS - 1)
      recv_str_o <= 0;

    if (rx_posedge == 1) begin
      if (recv_busy == 0) recv_busy <= 1;
    end

    if (recv_busy == 1) begin
      if (recv_cycles == HALF_CYCLE_TICKS && bauds_recv != 0 && bauds_recv != 9)
        recv_buffer <= {rx_s, recv_buffer[7:1]};

      if (bauds_recv == 9 && recv_cycles == CYCLE_TICKS - 1) begin
        recv_str_o <= 1;
        recv_busy <= 0;
        data_o <= recv_buffer;
        bauds_recv <= 0;
      end

      // Increment cycles
      if (recv_cycles != CYCLE_TICKS - 1) begin
        recv_cycles <= recv_cycles + 1;
      end else begin
        recv_cycles <= 0;
        if (bauds_recv != 9) bauds_recv <= bauds_recv + 1;
      end
    end
  end
end

endmodule

