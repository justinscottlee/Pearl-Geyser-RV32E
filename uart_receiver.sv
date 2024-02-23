`include "defines.vh"

module uart_receiver #(
    parameter CLK_FREQ = 1843200
)(
    input logic clk, rst_n,     // system clock and active low reset
    input logic rx,             // serial data input
    input logic clear_rx_ready, // active high, clear the rx_ready signal after the data has been read
    output logic rx_ready,      // active high, received data is ready to be read
    output logic [7:0] rx_data, // data received
    output logic frame_error,   // active high, framing error
    output logic parity_error,  // active high, parity error
    input uart_config_t uart_config
);

typedef enum {IDLE, START, DATA, PARITY, STOP} state_t;
state_t state = IDLE;

integer counter;    // clock divider counter to time baud period
integer bit_index;  // index to iterate through data bits
bit calculated_parity_bit;

integer cycles_per_bit; // clock cycles per baud period
integer stop_cycles;    // clocks cycles to output stop bit
integer data_bits;      // number of data bits to transmit

// calculate timing and other parameters based on uart_config
always_comb begin
    automatic integer baud_rate;
    case (uart_config.baud_rate)
    BAUD_9600:      baud_rate = 9600;
    BAUD_19200:     baud_rate = 19200;
    BAUD_38400:     baud_rate = 38400;
    BAUD_57600:     baud_rate = 57600;
    BAUD_115200:    baud_rate = 115200;
    default:        baud_rate = 9600;
    endcase
    cycles_per_bit = CLK_FREQ / baud_rate;
    
    case (uart_config.stop_bits)
    STOP_BITS_1:    stop_cycles = cycles_per_bit;
    STOP_BITS_1_5:  stop_cycles = 3*cycles_per_bit/2;
    STOP_BITS_2:    stop_cycles = 2*cycles_per_bit;
    default:        stop_cycles = cycles_per_bit;
    endcase
    
    data_bits = uart_config.data_bits + 5; // data_bits_t enum starts with 5
end

always_ff @ (posedge clk) begin
    if (!rst_n) begin
        // reset all outputs and enter idle state
        rx_ready <= 1'b0;
        frame_error <= 1'b0;
        parity_error <= 1'b0;
        rx_data <= 8'b0;
        state <= IDLE;
    end else begin
        case (state)
            IDLE: begin
                if (clear_rx_ready) begin // another device signals that the data has been read
                    // reset all outputs after data is read
                    rx_ready <= 1'b0;
                    frame_error <= 1'b0;
                    parity_error <= 1'b0;
                    rx_data <= 8'b0;
                end
                if (rx == 1'b0 && rx_ready == 1'b0) begin // start of new data transmission
                    state <= START;
                    counter <= 0;
                end
            end
            START: begin
                if (counter < cycles_per_bit / 2) begin // initially wait half a bit period to sample the center of each bit
                    counter <= counter + 1;
                end else begin
                    calculated_parity_bit <= (uart_config.parity == PARITY_ODD); // initialize parity bit
                    bit_index <= 0; // initialize bit index to 0 for DATA state
                    state <= DATA;
                    counter <= 0;
                end
            end
            DATA: begin
                if (counter < cycles_per_bit - 1) begin
                    counter <= counter + 1;
                end else begin
                    rx_data[(uart_config.bit_order == LSB_FIRST) ? bit_index : (data_bits - bit_index - 1)] <= rx; // insert next data bit into rx_data
                    calculated_parity_bit <= calculated_parity_bit ^ rx; // flip parity bit with new '1'
                    counter <= 0;
                    if (bit_index < data_bits - 1) begin
                        bit_index <= bit_index + 1; // index next data bit
                    end else begin
                        state <= (uart_config.parity == PARITY_NONE) ? STOP : PARITY;
                    end
                end
            end
            PARITY: begin
                if (counter < cycles_per_bit - 1) begin
                    counter <= counter + 1;
                end else begin
                    parity_error <= (rx != calculated_parity_bit); // verify actual parity bit received matches calculated parity bit
                    state <= STOP;
                    counter <= 0;
                end
            end
            STOP: begin
                if (counter < stop_cycles - 1) begin
                    counter <= counter + 1;
                end else begin
                    frame_error <= (rx == 1'b0); // verify the bit received is HIGH indicated either STOP or IDLE state
                    rx_ready <= 1'b1; // indicate received data is ready before going into IDLE state
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule