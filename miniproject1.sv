// blinking light

module top(
    input logic     clk, 
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    // CLK frequency is 12MHz, so 6,000,000 cycles is 0.5s, and that means 2,000,000 cycles is a sixth of a second
    parameter COLOR_INTERVAL = 2000000;
    logic [$clog2(COLOR_INTERVAL) - 1:0] count = 0;
    logic [$clog2(6) - 1:0] color = 0;
    logic red, green, blue;

    always_comb begin
        case (color)
            3'd0: begin // Red
                red = 1'b0;
                green = 1'b1;
                blue = 1'b1;
            end
            3'd1: begin // Yellow
                red = 1'b0;
                green = 1'b0;
                blue = 1'b1;
            end
            3'd2: begin // Green
                red = 1'b1;
                green = 1'b0;
                blue = 1'b1;
            end
            3'd3: begin // Cyan
                red = 1'b1;
                green = 1'b0;
                blue = 1'b0;
            end
            3'd4: begin // Blue
                red = 1'b1;
                green = 1'b1;
                blue = 1'b0;
            end
            3'd5: begin // Magenta
                red = 1'b0;
                green = 1'b1;
                blue = 1'b0;
            end
            3'd6: begin // Shouldn't reach here, filling bits
                red = 1'b0;
                green = 1'b0;
                blue = 1'b0;
            end
            3'd7: begin // Shouldn't reach here, filling bits
                red = 1'b0;
                green = 1'b0;
                blue = 1'b0;
            end
            default: begin // Shouldn't reach here either
                red = 1'b0;
                green = 1'b0;
                blue = 1'b0;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (count == COLOR_INTERVAL - 1) begin
            count <= 0;
            color <= color + 1;
        end
        else begin
            count <= count + 1;
        end
        if (color>5) begin
            color <= 0;
        end

    end

    assign RGB_R = red;
    assign RGB_G = green;
    assign RGB_B = blue;

endmodule