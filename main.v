// reset must become rst_n (the 
// pin constraints expect active low)

// I DON'T THINK THIS IS QUiTE WOKRING 
// THE WAY
// I WANT IT TO.. should turn on and stay on 
// with one press, not a hold... investigate
// futher
module main (
	input clk,
	input reset,
	input key,
	output led
);
	wire sync_to_DB;
	wire DB_to_ED;
	reg [26:0] T_DEBOUNCE_cycles = 30;
	wire pulse;

	synchroniser sync (
	.clk(clk),
	.reset(reset),
	.async_in(key),
	.sync_out(sync_to_DB)
	);
	
	debouncer DB (
	.clk(clk),
	.sig(sync_to_DB),
	.reset(reset),
	.T_DEBOUNCE_cycles(T_DEBOUNCE_cycles),
	.stable_out(DB_to_ED)
	);

	edgedetector ED (
	.in(DB_to_ED),
	.clk(clk),
	.reset(reset),
	.pulse(pulse)
	);
	reg led_state;
	assign led = led_state;
	always @(posedge clk) begin
		if (reset) begin
		led_state <= 1'b0;
		end else if (pulse) begin
			led_state <= ~led_state;
		end
	end
endmodule
