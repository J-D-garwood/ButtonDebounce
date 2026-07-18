
`timescale 1ns/1ps

module synchroniser_tb;

    reg clk;
    reg reset;
    reg async_in;
    wire sync_out;

    // Instantiate the design under test
    synchroniser dut (
        .clk      (clk),
        .reset    (reset),
        .async_in (async_in),
        .sync_out (sync_out)
    );

    // 100 MHz clock: 10 ns period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // Dump waveforms for GTKWave / Questa
        $dumpfile("synchroniser_tb.vcd");
        $dumpvars(0, synchroniser_tb);

        // Clean reset
        async_in = 1'b0;
        reset    = 1'b1;
        #20;
        reset    = 1'b0;

        // Drive async_in at deliberately "off-beat" times (not multiples of 10 ns)
        // so it lands between clock edges, like a real asynchronous input.
        // sync_out should follow each change two rising edges later.
        #13 async_in = 1'b1;
        #27 async_in = 1'b0;
        #11 async_in = 1'b1;
        #33 async_in = 1'b0;
        #17 async_in = 1'b1;

        // Let it settle, then finish
        #100;

        $display("Simulation finished. Final sync_out = %b", sync_out);
        $finish;
    end

endmodule