
module synchroniser (
	input clk,
	input reset,
	input async_in,
	output reg sync_out
);
	reg Ds;

always @(posedge clk) begin
	if (reset) begin
		Ds <= 1'b0;
		sync_out<= 1'b0;
	end else begin
		Ds <= async_in;
		sync_out <= Ds;
	end
end
endmodule