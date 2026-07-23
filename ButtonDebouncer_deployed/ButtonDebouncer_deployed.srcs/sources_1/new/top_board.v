`timescale 1ns / 1ps
module top_board(
    input  sys_clk_p,
    input  sys_clk_n,
    input  rst_n,
    input  key_n,
    output led
    );

    wire clk;
    wire led_int;

    IBUFDS #(.IOSTANDARD("DIFF_SSTL15")) u_clk_buf (
        .I (sys_clk_p), .IB (sys_clk_n), .O (clk)
    );

    top #(.T_DEBOUNCE(4_000_000)) u_top (
        .clk (clk), .rst_n (rst_n), .key_n (key_n), .led (led_int)
    );

    // Carrier LED1 (L13) is active-low: driving 0 lights it.
    // top drives led_int with 1 = lit, so invert here.
    assign led = ~led_int;

endmodule