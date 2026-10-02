// Rainbow fading logic

module fade #(
    parameter PWM_INTERVAL = 1200,
    parameter COLOR_INTERVAL = 10000,
    parameter BRIGHTNESS_STEP = 6
)(
    input logic clk, 

    output logic [$clog2(PWM_INTERVAL + 1) - 1:0] red,
    output logic [$clog2(PWM_INTERVAL + 1) - 1:0] green,
    output logic [$clog2(PWM_INTERVAL + 1) - 1:0] blue
);
    // Counter for timing brightness
    logic [$clog2(COLOR_INTERVAL) - 1:0] count = 0;

    // Current color stage (0 to 5)
    logic [2:0] color = 0;

    // Current brightness stage (0 to 1200)
    logic [$clog2(PWM_INTERVAL + 1) - 1:0] brightness = 0;

    // Color counter
    always_ff @(posedge clk) begin
        if (count == COLOR_INTERVAL - 1) begin
            count <= 0;

            // moving to next color
            if (brightness == PWM_INTERVAL) begin
                brightness <= 0;

                if (color == 5)
                    color <= 0;
                else
                    color <= color + 1;
            end
            else begin
                brightness <= brightness + BRIGHTNESS_STEP;
            end
        end
        else begin
            count <= count + 1;
        end
    end

    // RGB brightness
    always_comb begin
        red = 0;
        green = 0;
        blue = 0;

        case (color)
            3'd0: begin // Red -> Yellow
                red = PWM_INTERVAL;
                green = brightness;
            end
            3'd1: begin // Yellow -> Green
                red = PWM_INTERVAL - brightness;
                green = PWM_INTERVAL;
            end
            3'd2: begin // Green -> Cyan
                green = PWM_INTERVAL;
                blue = brightness;
            end
            3'd3: begin // Cyan -> Blue
                green = PWM_INTERVAL - brightness;
                blue = PWM_INTERVAL;
            end
            3'd4: begin // Blue -> Magenta
                red = brightness;
                blue = PWM_INTERVAL;
            end
            3'd5: begin // Magenta -> Red
                red = PWM_INTERVAL;
                blue = PWM_INTERVAL - brightness;
            end
            default: begin // Shouldn't reach here
                red = 0;
                green = 0;
                blue = 0;
            end
        endcase
    end

endmodule