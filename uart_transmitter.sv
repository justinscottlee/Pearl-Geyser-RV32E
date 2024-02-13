`include "defines.vh"

module uart_transmitter #(
    parameter CLK_FREQ = 1843200
)(
    input logic clk, rst,       // system clock and active low reset
    input logic tx_start,       // active high, start transmission
    input logic [7:0] tx_data,  // data to transmit
    output logic tx,            // serial data output
    output logic busy,          // active high, device is busy
    input uart_config_t uart_config
);

typedef enum {IDLE, START, DATA, PARITY, STOP} state_t;
state_t state = IDLE;

integer counter;    // clock divider counter to time baud period
integer bit_index;  // index to iterate through data bits
bit parity_bit;

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

always_ff @(posedge clk) begin
    if (!rst) begin
        tx <= 1'b1; // set tx to 1 for idle
        state <= IDLE;
    end else begin
        case (state)
            IDLE: begin
                if (tx_start) begin
                    tx <= 1'b0; // set tx to 0 for start bit
                    state <= START;
                    counter <= 0;
                end
            end
            START: begin
                if (counter < cycles_per_bit - 1) begin
                    counter <= counter + 1;
                end else begin
                    bit_index <= 0; // initialize bit index to 0 for DATA state
                    parity_bit <= (uart_config.parity == PARITY_ODD); // initialize parity bit
                    state <= DATA;
                    counter <= 0;
                end
            end
            DATA: begin
                // extract current bit from tx_data based on MSB/LSB-first
                automatic bit current_bit = uart_config.lsb_first ? tx_data[bit_index] : tx_data[data_bits - 1 - bit_index];
                tx <= current_bit; // set tx to current data bit
                if (counter < cycles_per_bit - 1) begin
                    counter <= counter + 1;
                end else begin
                    parity_bit <= parity_bit ^ current_bit; // flip parity bit with new '1'
                    counter <= 0;
                    if (bit_index < data_bits - 1) begin
                        bit_index <= bit_index + 1; // index next data bit
                    end else begin
                        if (uart_config.parity == PARITY_NONE) begin
                            tx <= 1'b1; // set tx to 1 for stop bit
                            state <= STOP;
                        end else begin
                            tx <= parity_bit ^ current_bit; // set tx to parity bit
                            state <= PARITY;
                        end
                    end
                end
            end
            PARITY: begin
                if (counter < cycles_per_bit - 1) begin
                    counter <= counter + 1;
                end else begin
                    tx <= 1'b1; // set tx to 1 for stop bit
                    state <= STOP;
                    counter <= 0;
                end
            end
            STOP: begin
                if (counter < stop_cycles - 1) begin
                    counter <= counter + 1;
                end else begin
                    state <= IDLE;
                end
            end
        endcase
    end
end

assign busy = (state != IDLE); // indicate busy if not in IDLE state

endmodule