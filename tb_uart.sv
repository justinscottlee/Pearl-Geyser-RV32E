`timescale 1ns / 1ps

`include "defines.vh"

module tb_uart;

uart_config_t uart_config1 = '{baud_rate: BAUD_9600,
                           data_bits: DATA_BITS_8,
                           stop_bits: STOP_BITS_1_5,
                           parity: PARITY_ODD,
                           bit_order: LSB_FIRST};

uart_config_t uart_config2 = '{baud_rate: BAUD_9600,
                           data_bits: DATA_BITS_8,
                           stop_bits: STOP_BITS_1_5,
                           parity: PARITY_ODD,
                           bit_order: LSB_FIRST};

logic clk;
logic rst_n;
logic tx_start;
logic [7:0] tx_data;
logic tx;
logic busy;

logic clear_rx_ready;
logic rx_ready;
logic [7:0] rx_data;
logic frame_error;
logic parity_error;

uart_transmitter dut1 (.clk(clk), .rst_n(rst_n), .tx_start(tx_start), .tx_data(tx_data), .tx(tx), .busy(busy), .uart_config(uart_config1));
uart_receiver dut2 (.clk(clk), .rst_n(rst_n), .rx(tx), .clear_rx_ready(clear_rx_ready), .rx_ready(rx_ready), .rx_data(rx_data), .frame_error(frame_error), .parity_error(parity_error), .uart_config(uart_config2));

always #271.267 clk = ~clk;

initial begin
    $dumpfile("tb_uart.vcd");
    $dumpvars(0, tb_uart);
    clk = 1;
    rst_n = 0;
    clear_rx_ready = 0;
    tx_start = 0;
    tx_data = 8'h72;
    #2000;
    rst_n = 1;
    tx_start = 1;
    #500;
    tx_start = 0;
    #1500000;
    clear_rx_ready = 1;
    #500;
    clear_rx_ready = 0;
    tx_start = 1;
    #500;
    tx_start = 0;
    tx_data = 8'h91;
    #1500000;
    $finish;
end

endmodule