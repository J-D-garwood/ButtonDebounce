
`timescale 1ns / 1ps

module tb_top;

    // -----------------------------------------------------------------
    // Parameters
    // -----------------------------------------------------------------
    // Short debounce interval for simulation (per C2 ? don't use the
    // hardware value or sim will take forever). Decide how this maps
    // to your DUT's parameterisation (R3).
    localparam /* ... */ ;

    // Clock period ? pick something that makes the arithmetic easy.
    localparam /* CLK_PERIOD ... */ ;

    // -----------------------------------------------------------------
    // DUT signals
    // -----------------------------------------------------------------
    reg  clk;
    reg  rst_n;
    reg  key;
    wire led;

    // -----------------------------------------------------------------
    // Scoreboard / bookkeeping
    // -----------------------------------------------------------------
    integer fail_count;
    integer pulse_count;   // however you choose to observe pulses
    // ... whatever else you need to track expected vs actual

    // -----------------------------------------------------------------
    // DUT instantiation
    // -----------------------------------------------------------------
    // Instantiate with the SHORT debounce parameter here.
    // top #( ... ) dut ( .clk(clk), .rst_n(rst_n), .key(key), .led(led) );

    // -----------------------------------------------------------------
    // Clock generation
    // -----------------------------------------------------------------
    always #(5) clk = ~clk;

    // -----------------------------------------------------------------
    // Tasks ? build your vocabulary of stimulus/check operations
    // -----------------------------------------------------------------
    // task do_reset;        ...   // R6 / T7
    // task press_clean;     ...   // T1
    // task press_bouncy;    ...   // T2  (randomised chatter ? C2)
    // task release_bouncy;  ...   // T3
    // task glitch;          ...   // T4  (shorter than T_DEBOUNCE)
    // task hold_long;       ...   // T5
    // task check_pulse_count(expected); ... // increments fail_count on mismatch
    // task check_led_state(expected);   ...

    // -----------------------------------------------------------------
    // Pulse / LED observation
    // -----------------------------------------------------------------
    // How will you detect a "press pulse"? The LED toggles once per
    // press (R5), so LED transitions are one observable. Decide whether
    // you also probe an internal pulse signal.

    // -----------------------------------------------------------------
    // Main stimulus sequence
    // -----------------------------------------------------------------
    initial begin
        // init signals, apply reset

        // T1  ? clean press,           expect 1
        // T2  ? bouncy press,          expect 1
        // T3  ? bouncy release,        expect 0 press-pulses
        // T4  ? sub-threshold glitch,  expect 0
        // T5  ? long hold,             expect 1
        // T6  ? stable for exactly T_DEBOUNCE, and T_DEBOUNCE-1
        // T7  ? reset mid-debounce,    expect no stale pulse
        // T8  ? ten presses,           check final LED state

        // -------------------------------------------------------------
        // Final verdict (C2)
        // -------------------------------------------------------------
        // if (fail_count == 0) $display("PASS");
        // else                 $display("FAIL: %0d failures", fail_count);
        // $finish;
    end

    // -----------------------------------------------------------------
    // Safety timeout ? so a broken DUT can't hang the sim forever
    // -----------------------------------------------------------------
    // initial begin #(BIG); $display("TIMEOUT"); $finish; end

endmodule