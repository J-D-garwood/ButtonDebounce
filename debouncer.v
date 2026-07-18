//Early draft - I think we can do better than this!!
module debouncer (
	input clk,
	input sig,
	input reset,
	input [26:0] T_DEBOUNCE_cycles,
	output reg stable_out
);
	reg [26:0] counter;
	
	reg prev;

	always @(posedge clk) begin
		if (reset) begin
			prev <= 1'b0;
			stable_out <= 1'b0;
			counter <= 27'b0;
		end else if (prev == sig) begin
			counter <= counter + 1'b1;
		end else begin
			counter <= 1'b0;
		end
		
		if (counter > T_DEBOUNCE_cycles) begin
			stable_out <= sig;
			counter <= 1'b0;
		end
		prev <= sig;
	end

endmodule