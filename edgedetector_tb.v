
`timescale 1ms/1us

module edgedetector_tb;

    reg clk;
    reg reset;
    reg in;
    wire pulse;

    edgedetector dut (
	.in(in),
	.clk(clk),
	.reset(reset),
	.pulse(pulse)
);

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // Dump waveforms for GTKWave / Questa
        $dumpfile("edgedetector_tb.vcd");
        $dumpvars(0, edgedetector_tb);
	
	in = 1'b0;
	reset = 1'b1;
	#20;
	reset = 1'b0;
	#12 in = 1'b1;
	#20 in = 1'b0;
	#40 in = 1'b1;
	#41 in = 1'b0;
	#6 in = 1'b1;
	#89 in = 1'b0;
	#10 in = 1'b1;
	#40 in = 1'b0;
	#50;
	$display("Simulation finished. Final sync_out = %b", pulse);
        $finish;
    end
    
endmodule
