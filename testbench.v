`timescale 1ms/1us
//
// REVIEW CLAUDE FEEBACK FROM LAST SESSION TO FIX TESTBENCH
//
module testbench;

    reg  clk;
    reg  rst_n;
    reg  key;
    wire led;

    top #(.T_DEBOUNCE(30)) dut(
        .clk   (clk),
        .rst_n (rst_n),
        .key_n   (key),
        .led   (led)
    );

    // clock: 20us period
    initial clk = 1'b0;
    always #0.01 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        key_n   = 1'b1;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;

        $display("t=%0t reset released, led=%b", $time, led);

        // T1. simple clean press, no bounce. One pulse expected
        repeat (5) @(posedge clk);
        key_n = 1'b0;
        repeat (100) @(posedge clk);
        key_n = 1'b1;
        repeat (100) @(posedge clk);
	

	//T2. A press w. a realistic bounce
	repeat (10) begin
            #10 key_n = ~key_n;
        end
	key_n = 1'b0;
	repeat (100) @(posedge clk);


	//T3. Release w. a bounce. Zero press-pulses expected
	repeat (10) begin
            #10 key_n = ~key_n;
        end
	key_n = 1'b1;
	repeat (100) @(posedge clk);

	//T4. a glitch shorter than T_DEBOUNCE. Zero pulses expected.
	key_n = 1'b0;
	repeat (100) @(posedge clk);
	repeat (10) begin
            #10 key_n = ~key_n;
        end
	key_n = 1'b1;
	repeat (50) @(posedge clk);

	key_n = 1'b1;
        $finish;

	// T5. A press held for a very long time. Exactly one pulse expected ? not one per cycle.
	key_n = 1'b0;
        repeat (10000) @(posedge clk);
        key_n = 1'b1;
        repeat (100) @(posedge clk);

	// T6. Boundary condition: an input held stable for exactly T_DEBOUNCE, 
	// and for T_DEBOUNCE - 1. Off-by-one errors in the counter live precisely here.
	key_n = 1'b0;
        repeat (30) @(posedge clk);
        key_n = 1'b1;
        repeat (100) @(posedge clk);
	key_n = 1'b0;
        repeat (29) @(posedge clk);

	//T7. Reset asserted in the middle of a debounce interval. 
	// The design must not emit a stale pulse on release of reset.
	repeat (5) @(posedge clk);
        key_n = 1'b0;
        repeat (20) @(posedge clk);
	rst_n = 1'b0;
	repeat (100) @(posedge clk);
	key_n   = 1'b1;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;

	// T8. Ten presses in sequence. 
	//The LED must end in the correct state.
	repeat (10) @(posedge clk) begin
		repeat (5) @(posedge clk);
        	key_n = 1'b0;
        	repeat (100) @(posedge clk);
        	key_n = 1'b1;
        	repeat (100) @(posedge clk);
	end
    end
endmodule