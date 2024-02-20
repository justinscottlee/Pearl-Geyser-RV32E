`timescale 1ns / 1ps

`include "defines.vh"

module tb_spi_master;

spi_config_t spi_config = '{spi_mode: SPI_MODE_0,
                           spi_frame_size: SPI_FRAME_SIZE_8,
                           prescaler: PSC_2,
                           bit_order: MSB_FIRST};

logic clk, rst_n;
logic tx_start;
logic miso, mosi, sclk;
logic [31:0] tx_data;
logic [31:0] rx_data;
logic busy;

spi_master dut (.clk(clk), .rst_n(rst_n), .tx_start(tx_start), .miso(miso), .mosi(mosi), .sclk(sclk), .tx_data(tx_data), .rx_data(rx_data), .busy(busy), .spi_config(spi_config));

always #10 clk = ~clk;
//always #7.5 miso = ~miso;

initial begin
    $dumpfile("tb_uart.vcd");
    $dumpvars(0, tb_uart);
    clk = 1;
    rst_n = 0;
    tx_start = 0;
    tx_data = 8'h72;
    miso = 1;
    #50;
    rst_n = 1;
    tx_start = 1;
    #50;
    tx_start = 0;
    #1000;
    $finish;
end

endmodule