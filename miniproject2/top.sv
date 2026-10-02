`include "fade.sv"
`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200,       // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter COLOR_INTERVAL = 10000,
    parameter BRIGHTNESS_STEP = 6
)(
    input logic     clk, 
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

   // Brightness values from fade.sv
    logic [$clog2(PWM_INTERVAL + 1) - 1:0] red;
    logic [$clog2(PWM_INTERVAL + 1) - 1:0] green;
    logic [$clog2(PWM_INTERVAL + 1) - 1:0] blue;

    // PWM outputs
    logic red_out, green_out, blue_out;

    // Rainbow fading logic
    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL),
        .COLOR_INTERVAL (COLOR_INTERVAL),
        .BRIGHTNESS_STEP (BRIGHTNESS_STEP)
    ) u1 (
        .clk         (clk),
        .red         (red),
        .green       (green),
        .blue        (blue)
    );

    // Red PWM
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (red), 
        .pwm_out        (red_out)
    );

    // Green PWM
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u3 (
        .clk            (clk), 
        .pwm_value      (green), 
        .pwm_out        (green_out)
    );

    // Blue PWM
    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u4 (
        .clk            (clk), 
        .pwm_value      (blue), 
        .pwm_out        (blue_out)
    );

    assign RGB_R = ~red_out;
    assign RGB_G = ~green_out;
    assign RGB_B = ~blue_out;

endmodule