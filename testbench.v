`timescale 1ns/1ps
//=====================================================================
// tb_top.v  --  self-checking testbench for the debounced toggle top
//
// Harness is complete. T1 and T2 are worked examples.
// T3 .. T8 are yours to write.
//=====================================================================
module testbench;

    //-----------------------------------------------------------------
    // Parameters
    //-----------------------------------------------------------------
    localparam integer CLK_PERIOD = 20;         // ns  -> 50 MHz
    localparam integer T_DEB      = 30;         // debounce, in clk cycles
    localparam integer SETTLE     = 4 * T_DEB;  // safely past any decision point

    //-----------------------------------------------------------------
    // DUT
    //-----------------------------------------------------------------
    reg  clk = 1'b0;
    reg  rst_n;
    reg  key_n;          // active-low at the pin: 1 = released, 0 = pressed
    wire led;
    integer j;
    reg led_start;

    top #(.T_DEBOUNCE(T_DEB)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .key_n (key_n),
        .led   (led)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    //-----------------------------------------------------------------
    // Scoreboard
    //
    // We count LED toggles as a proxy for press-pulses. Sampled on the
    // NEGEDGE so we never race the DUT's non-blocking update at posedge.
    //
    // NOTE: this proxy cannot distinguish 0 pulses from 2 pulses -- the
    // LED returns to the same state either way. See the note under T2.
    //-----------------------------------------------------------------
    integer errors  = 0;
    integer toggles = 0;
    integer seed    = 32'hC0FFEE;   // change + record this to re-run a failure
    reg     led_d;

    always @(negedge clk) begin
        if (led !== led_d) toggles = toggles + 1;
        led_d <= led;
    end

    //-----------------------------------------------------------------
    // Helper tasks
    //-----------------------------------------------------------------
    task hold(input integer n);
        begin
            repeat (n) @(posedge clk);
        end
    endtask

    task do_reset;
        begin
            rst_n = 1'b0;
            key_n = 1'b1;
            hold(5);
            @(negedge clk);
            led_d   = led;      // prime the edge detector
            toggles = 0;
            rst_n   = 1'b1;
            hold(2);
        end
    endtask

    // Randomised chatter. Every dwell is strictly SHORTER than T_DEB,
    // which is what makes this bounce rather than a burst of real presses.
    task bounce(input integer n_edges);
        integer i, dwell;
        begin
            for (i = 0; i < n_edges; i = i + 1) begin
                dwell = 1 + ({$random(seed)} % (T_DEB - 2));
                hold(dwell);
                key_n = ~key_n;
            end
        end
    endtask

    task expect_pulses(input integer n, input [8*32:1] name);
        begin
            if (toggles !== n) begin
                $display("FAIL  %0s : expected %0d pulse(s), saw %0d",
                         name, n, toggles);
                errors = errors + 1;
            end else begin
                $display("PASS  %0s : %0d pulse(s)", name, n);
            end
            toggles = 0;
        end
    endtask

    task expect_led(input value, input [8*32:1] name);
        begin
            if (led !== value) begin
                $display("FAIL  %0s : led = %b, expected %b", name, led, value);
                errors = errors + 1;
            end else begin
                $display("PASS  %0s : led = %b", name, led);
            end
        end
    endtask

    //-----------------------------------------------------------------
    // Watchdog -- an unreachable @(posedge) should fail loudly, not hang
    //-----------------------------------------------------------------
    initial begin
        #10_000_000;                          // 10 ms of sim time
        $display("FATAL: watchdog expired -- testbench deadlocked");
        $display("=== %0d FAILURE(S) ===", errors + 1);
        $finish;
    end

    //-----------------------------------------------------------------
    // Waveforms
    //-----------------------------------------------------------------
    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, testbench);
    end

    //-----------------------------------------------------------------
    // Stimulus
    //-----------------------------------------------------------------
    initial begin
        $display("--- seed = %0h ---", seed);
        do_reset;
        expect_pulses(0, "T0 reset quiet");   // R6: no spurious pulse on reset

        //=============================================================
        // T1. Clean press, no bounce. One pulse expected.
        //=============================================================
        hold(5);
        key_n = 1'b0;                 // press
        hold(SETTLE);
        key_n = 1'b1;                 // release
        hold(SETTLE);
        expect_pulses(1, "T1 clean press");

        //=============================================================
        // T2. Press with realistic randomised bounce.
        //     EXACTLY one pulse expected.
        //
        //     This is the test the LED-toggle proxy is weakest on: if
        //     the DUT emitted two pulses the LED would land back where
        //     it started and toggles would read 0, not 2. Consider
        //     probing dut.<edge_detector>.pulse hierarchically instead,
        //     and say which you chose in the README.
        //=============================================================
        bounce(9);                    // chatter about the press
        key_n = 1'b0;                 // settles pressed
        hold(SETTLE);
        expect_pulses(1, "T2 bouncy press");

        //=============================================================
        // T3. Release with bounce. ZERO press-pulses expected.
        //     Key is currently LOW (still pressed) from T2.
        //=============================================================
	bounce(9);
	hold(SETTLE);
	expect_pulses(0, "T3 bouncy release");

        //=============================================================
        // T4. A glitch strictly shorter than T_DEBOUNCE, from a settled
        //     released state. Zero pulses expected.
        //     Careful: hold the glitch for FEWER than T_DEB cycles --
        //     your original version accepted a full press first.
        //=============================================================
        key_n = 1'b0;          // glitch low
	hold(T_DEB - 1);       // strictly shorter than the debounce interval
	key_n = 1'b1;          // back to released
	expect_pulses(0, "T4 short glitch");

        //=============================================================
        // T5. Press held for a very long time (say 10000 cycles).
        //     Exactly one pulse -- not one per cycle.
        //=============================================================
        key_n = 1'b0; 
	hold(10000);
	key_n = 1'b1;
	hold(SETTLE); 
	expect_pulses(1, "T5 held press");
	

        //=============================================================
        // T6. Boundary: stable for exactly T_DEB, and for T_DEB-1.
        //
        //     Think before you write this one. There are two synchroniser
        //     flops between the pin and the debouncer, so a level held
        //     for exactly T_DEB cycles AT THE PIN is not held for T_DEB
        //     cycles at the counter. Decide what your spec promises,
        //     write the expected pulse count that follows from it, and
        //     justify the number in your README. Do not tune the
        //     expectation until it matches whatever the RTL happens to do.
        //=============================================================
        key_n = 1'b0; 
	hold(T_DEB);
	key_n = 1'b1;
	hold(SETTLE); 
	expect_pulses(1, "T6 T_DEB len press");
	key_n = 1'b0; 
	hold(T_DEB-1);
	key_n = 1'b1;
	hold(SETTLE); 
	expect_pulses(0, "T6 T_DEB-1 len press");

        //=============================================================
        // T7. Reset asserted mid-debounce. No stale pulse on release.
        //     Assert rst_n low while the counter is partway through,
        //     release reset, and check zero pulses. Remember to re-prime
        //     led_d after reset if the LED is forced back to 0.
        //=============================================================
        key_n = 1'b0; 
	hold(T_DEB/2);
	do_reset;
	hold(SETTLE);
	expect_pulses(0, "T7 mid press reset");
	
        //=============================================================
        // T8. Ten presses in sequence. LED must end in the correct state.
        //     Check BOTH the pulse count (10) and the final level via
        //     expect_led(). Note your original `repeat (10) @(posedge clk)
        //     begin ... end` does not do what it looks like -- the
        //     @(posedge clk) binds as a delay on the repeat, not a loop
        //     body. Use `repeat (10) begin ... end`.
        //=============================================================
	led_start = led_d;
	begin
            for (j = 0; j < 10; j = j + 1) begin
             key_n = 1'b0; 
	     hold(SETTLE);
	     key_n = 1'b1;
	     hold(SETTLE); 
            end
        end
        expect_pulses(10, "T8 10 pulses");
	expect_led(led_start, "T8 final level");

	// temporary diagnostic -- delete once you know the answer
	key_n = 1'b0; hold(T_DEB + 1); key_n = 1'b1; hold(SETTLE);
	expect_pulses(1, "T6d T_DEB+1");

	key_n = 1'b0; hold(T_DEB + 2); key_n = 1'b1; hold(SETTLE);
	expect_pulses(1, "T6e T_DEB+2");

        //=============================================================
        // Summary
        //=============================================================
        if (errors == 0)
            $display("=== ALL TESTS PASSED ===");
        else
            $display("=== %0d FAILURE(S) ===", errors);
        $finish;
    end

endmodule