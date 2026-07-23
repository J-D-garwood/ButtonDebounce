
module top #(
	parameter T_DEBOUNCE = 3000
)(
	input clk,
	input rst_n,
	input key_n,
	output led
);
	wire sync_to_DB;
	wire DB_to_ED;
	wire pulse;

	wire key = ~key_n;
	synchroniser sync (
	.clk(clk),
	.rst_n(rst_n),
	.async_in(key),
	.sync_out(sync_to_DB)
	);
	
	debouncer #(.T_DEBOUNCE(T_DEBOUNCE)) DB (
	.clk(clk),
	.sig(sync_to_DB),
	.rst_n(rst_n),
	.stable_out(DB_to_ED)
	);

	edgedetector ED (
	.in(DB_to_ED),
	.clk(clk),
	.rst_n(rst_n),
	.pulse(pulse)
	);
	reg led_state;
	assign led = led_state;
	always @(posedge clk) begin
		if (!rst_n) begin
		led_state <= 1'b0;
		end else if (pulse) begin
			led_state <= ~led_state;
		end
	end
endmodule
