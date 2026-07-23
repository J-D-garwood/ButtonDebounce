//Early draft - I think we can do better than this!!
module debouncer #(
	parameter T_DEBOUNCE = 3000
)(
	input clk,
	input sig,
	input rst_n,
	output reg stable_out
);
	localparam CW = $clog2(T_DEBOUNCE+1);
	reg [CW-1:0] counter;
	
	reg prev;

	always @(posedge clk) begin
		prev <= sig;
		if(!rst_n) begin
			counter <= 1;
			stable_out <= 1'b0;
		end else begin
			if (prev == sig) begin
				if (counter < T_DEBOUNCE - 1) begin
					counter <= counter + 1'b1;
				end else begin
					stable_out <= sig;
				end
			end else begin
				counter <= 1;
			end
		end
	end
endmodule