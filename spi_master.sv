`include "defines.vh"

module spi_master (
    input logic clk, rst_n,
    input logic tx_start,
    input logic miso,
    output logic mosi,
    output logic sclk,
    input logic [31:0] tx_data,
    output logic [31:0] rx_data,
    output logic busy,

    input spi_config_t spi_config
);

typedef enum {IDLE, START_DELAY, TRANSFER, STOP_DELAY} state_t;
state_t state = IDLE;

integer counter;
integer bit_index;

bit cpol, cpha;
integer frame_size;

always_comb begin
    cpol = (spi_config.spi_mode == SPI_MODE_2) | (spi_config.spi_mode == SPI_MODE_3);
    cpha = (spi_config.spi_mode == SPI_MODE_1) | (spi_config.spi_mode == SPI_MODE_3);
    case(spi_config.spi_frame_size)
        SPI_FRAME_SIZE_8: frame_size = 8;
        SPI_FRAME_SIZE_16: frame_size = 16;
        SPI_FRAME_SIZE_24: frame_size = 24;
        SPI_FRAME_SIZE_32: frame_size = 32;
        default: frame_size = 8;
    endcase
end

always @ (posedge clk) begin
    if (!rst_n) begin
        sclk <= cpol;
        bit_index <= 0;
        rx_data <= 32'd0;
        state <= IDLE;
        counter <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (tx_start) begin
                    if (cpol) begin
                        sclk <= ~sclk;
                    end
                    if (cpha ^ cpol) begin
                        state <= START_DELAY;
                    end else begin
                        state <= TRANSFER;
                    end
                    counter <= 0;
                    rx_data = 32'd0;
                end
            end
            START_DELAY: begin
                if (counter < (1 << spi_config.prescaler) - 1) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    sclk <= ~sclk;
                    state <= TRANSFER;
                end
            end
            TRANSFER: begin
                if (counter < (1 << spi_config.prescaler) - 1) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    sclk <= ~sclk;
                    if (sclk == cpol ^ cpha) begin
                        if (spi_config.bit_order == MSB_FIRST) begin
                            rx_data[frame_size - bit_index - 1] <= miso;
                        end else begin
                            rx_data[bit_index] <= miso;
                        end
                    end else begin
                        if (bit_index == frame_size - 1) begin
                            if (cpol & cpha) begin
                                state <= STOP_DELAY;
                            end else begin
                                state <= IDLE;
                                sclk <= cpol;
                                bit_index <= 0;
                            end
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end
                end
            end
            STOP_DELAY: begin
                if (counter < (1 << spi_config.prescaler) - 1) begin
                    counter <= counter + 1;
                end else begin
                    sclk <= ~sclk;
                    state <= IDLE;
                    bit_index <= 0;
                end
            end
        endcase
    end
end

assign busy = (state != IDLE);
assign mosi = (spi_config.bit_order == MSB_FIRST) ? tx_data[frame_size - bit_index - 1] : tx_data[bit_index];

endmodule