#include "common.h"
#include "mini_uart.h"
#include "printf.h"
#include "utils.h"
#include "irq.h"
#include "timer.h"
#include "i2c.h"
#include "spi.h"

void putc(void *p, char c){
    if (c == '\n')
    {
        uart_send('\r');
    }
    uart_send(c);
}

void kernel_main() {
    uart_init();
    init_printf(0, putc);
    irq_init_vectors();
    enable_interrupt_controller();
    irq_enable();
    //timer_init();
    
    uart_send_string("Rasperry PI Bare Metal OS Initializing...\n");

    uart_send_string("\tBoard: Raspberry PI 4\n");

    tfp_printf("\nException Level: %d\n", get_el());

    //uart_send_string("\n\nShow Timers:\n");
    //printf("Sleeping for 200 ms...");
    //timer_sleep(200);
    //printf("Sleeping for 200 ms...");
    //timer_sleep(200);
    //printf("Sleeping for 200 ms...");
    //timer_sleep(200);
    //printf("Sleeping for 2 seconds...");
    //timer_sleep(2000);
    //printf("Sleeping for 2 seconds...");
    //timer_sleep(2000);
    //printf("Sleeping for 5 seconds...");
    //timer_sleep(5000);

    
    //printf("Initializing I2C");
    //printf("Initializing I2C...\n");
    //i2c_init();
    //for (int i=0; i<10; i++) {
    //    char buffer[10];
    //    i2c_recv(21, buffer, 9);
    //    buffer[9] = 0;
    //    printf("Received: %s\n", buffer);
    //    timer_sleep(250);
    //}
    //for (u8 d=0; d<20; d++) {
    //    i2c_send(21, &d, 1);
    //    timer_sleep(250);
    //    printf("Sent: %d\n", d);
    //}
    //char *msg = "Hello Slave Device";
    //i2c_send(21, msg, 18);

    /*
        I2C RPI -> Arduino Connection
        GPIO2 -> A4
        GPIO3 -> A5
        GND   -> GND
    */

    //uart_send_string("\n\nDone\n");

    // Spi implementation:
    printf("Print to slave");
    spi_init();
    char * msg = "Hello Slave, Whatup?";
    u8 len = 20;
    spi_send(0, (uint8_t*)msg, len);

    while(1) {
        uart_send(uart_recv());
    }
}
