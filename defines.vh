typedef enum {BAUD_9600, BAUD_19200, BAUD_38400, BAUD_57600, BAUD_115200} baud_rate_t;
typedef enum {DATA_BITS_5, DATA_BITS_6, DATA_BITS_7, DATA_BITS_8} data_bits_t;
typedef enum {STOP_BITS_1, STOP_BITS_1_5, STOP_BITS_2} stop_bits_t;
typedef enum {PARITY_NONE, PARITY_ODD, PARITY_EVEN} parity_t;

typedef struct {
    baud_rate_t baud_rate;
    data_bits_t data_bits;
    stop_bits_t stop_bits;
    parity_t parity;
    bit lsb_first;
} uart_config_t;