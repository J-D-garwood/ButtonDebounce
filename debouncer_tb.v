
`timescale 1ms/1us

module debouncer_tb;

    reg clk;
    reg sig;
    reg reset;
    reg [26:0] cycles;
    wire stable_out;

    // Instantiate the design under test
    debouncer dut (
        .clk        (clk),
        .sig        (sig),
        .reset      (reset),
	.T_DEBOUNCE_cycles	(cycles),
        .stable_out (stable_out)
    );

    // 100 MHz clock: 10 ns period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // Dump waveforms for GTKWave / your viewer of choice
        $dumpfile("debouncer_tb.vcd");
        $dumpvars(0, debouncer_tb);

        // Start with a clean reset
        sig   = 1'b0;
        reset = 1'b1;
	cycles = 10;
        #20;
        reset = 1'b0;

        // Simulate a bouncing button press: sig chatters before settling
        #10 sig = 1'b1;
        #10 sig = 1'b0;
        #10 sig = 1'b1;
        #10 sig = 1'b0;
        #10 sig = 1'b1;   // finally held high from here on

        // Hold steady long enough for the counter to cross the threshold.
        // At 10 ns/cycle, 300000 counts is ~3 ms of sim time.
        #3500;

        // Release the button and let it bounce again on the way down
        #10 sig = 1'b0;
        #10 sig = 1'b1;
        #10 sig = 1'b0;   // held low from here on

        #3500;

        $display("Simulation finished. Final stable_out = %b", stable_out);
        $finish;
    end

endmodule