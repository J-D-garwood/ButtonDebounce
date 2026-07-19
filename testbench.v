`timescale 1ms/1us
//
// Minimal smoke test for main.v -- just presses the key once and
// watches led toggle. No bounce modelling, no boundary cases.
// Reset is currently active-HIGH to match main.v's current port.
//
module testbench;

    reg  clk;
    reg  reset;
    reg  key;
    wire led;

    main dut (
        .clk   (clk),
        .reset (reset),
        .key   (key),
        .led   (led)
    );

    // clock: 20us period
    initial clk = 1'b0;
    always #0.01 clk = ~clk;

    initial begin
        reset = 1'b1;
        key   = 1'b0;
        repeat (5) @(posedge clk);
        reset = 1'b0;

        $display("t=%0t reset released, led=%b", $time, led);

        // simple clean press, no bounce
        repeat (5) @(posedge clk);
        key = 1'b1;
        $display("t=%0t key pressed, led=%b", $time, led);

        // hold long enough for sync + debounce + edge detect to settle
        repeat (100) @(posedge clk);
        $display("t=%0t after settle, led=%b", $time, led);

        // release
        key = 1'b0;
        $display("t=%0t key released, led=%b", $time, led);

        repeat (100) @(posedge clk);
        $display("t=%0t final, led=%b", $time, led);

        $finish;
    end

endmodule