`timescale 1ns / 1ps

`include "top.sv"

module rainbow_tb;

    // Testbench signals
    logic clk = 0;
    wire RGB_R;
    wire RGB_G;
    wire RGB_B;

    // Simulated clock (10 ns cycle)
    always #5 clk = ~clk;

    // Simulate w/ smaller numbers
    top #(
        .PWM_INTERVAL (12),
        .COLOR_INTERVAL (24),
        .BRIGHTNESS_STEP (3)
    ) dut (
        .clk (clk),
        .RGB_R (RGB_R),
        .RGB_G (RGB_G),
        .RGB_B (RGB_B)
    );

    // Run simulation
    initial begin
        $dumpfile("rainbow.vcd");
        $dumpvars(0, rainbow_tb);

        repeat (700) @(negedge clk);

        $finish;
    end

endmodule