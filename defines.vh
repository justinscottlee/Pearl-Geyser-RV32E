typedef enum {BAUD_9600, BAUD_19200, BAUD_38400, BAUD_57600, BAUD_115200} baud_rate_t;
typedef enum {DATA_BITS_5, DATA_BITS_6, DATA_BITS_7, DATA_BITS_8} data_bits_t;
typedef enum {STOP_BITS_1, STOP_BITS_1_5, STOP_BITS_2} stop_bits_t;
typedef enum {PARITY_NONE, PARITY_ODD, PARITY_EVEN} parity_t;

typedef enum {SPI_MODE_0, SPI_MODE_1, SPI_MODE_2, SPI_MODE_3} spi_mode_t;
typedef enum {SPI_FRAME_SIZE_8, SPI_FRAME_SIZE_16, SPI_FRAME_SIZE_24, SPI_FRAME_SIZE_32} spi_frame_size_t;

typedef enum {PSC_2, PSC_4, PSC_8, PSC_16, PSC_32, PSC_64, PSC_128, PSC_256} prescaler_t;
typedef enum {MSB_FIRST, LSB_FIRST} bit_order_t;

typedef struct {
    baud_rate_t baud_rate;
    data_bits_t data_bits;
    stop_bits_t stop_bits;
    parity_t parity;
    bit_order_t bit_order;
} uart_config_t;

typedef struct {
    spi_mode_t spi_mode;
    spi_frame_size_t spi_frame_size;
    prescaler_t prescaler;
    bit_order_t bit_order;
} spi_config_t;