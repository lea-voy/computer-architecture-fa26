`include "game_of_life.sv"
`include "ws2812b.sv"
`include "controller.sv"

// game_of_life top level module

module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT, 
    output logic    _48b, 
    output logic    _45a
);

    // ========================================
    // PARAMETERS
    // ========================================
    
    // Each gen is 0.5 seconds
    localparam int GEN_INTERVAL = 6_000_000;

    // Color changes every 0.125 seconds
    localparam int COLOR_INTERVAL = 1_500_000;

    // Lower-brightness color palette
    localparam logic [23:0] PINK   = 24'h080002;
    localparam logic [23:0] PURPLE = 24'h040008;
    localparam logic [23:0] BLUE   = 24'h000008;
    localparam logic [23:0] MINT   = 24'h000802;


    // ========================================
    // SIGNAL DECLARATIONS
    // ========================================

    // Game of Life
    logic [63:0] board;
    logic reset_game = 1'b1;
    logic next_gen;
    logic [22:0] gen_counter = 0;

    // Color transitions
    logic [20:0] color_counter = 0;
    logic [4:0] color_phase = 0;
    logic [23:0] start_color;
    logic [23:0] end_color;
    logic [23:0] current_color;
    logic [23:0] pixel_color;

    // LED control and transmission
    logic [5:0] pixel;
    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;


    // ========================================
    // GAME OF LIFE
    // ========================================

    game_of_life game (
        .clk(clk),
        .reset(reset_game),
        .next_gen(next_gen),
        .board(board)
    );

    // Reset game on startup
    always_ff @(posedge clk) begin
        reset_game <= 1'b0;
    end

    // Count clock cycles btwn gens
    always_ff @(posedge clk) begin
        if (reset_game || next_gen)
            gen_counter <= 0;
        else
            gen_counter <= gen_counter + 1'b1;
    end

    assign next_gen = (gen_counter == GEN_INTERVAL - 1);


    // ========================================
    // COLOR TRANSITIONS
    // ========================================

    // Blend a single RGB channel between 2 values
    function automatic [7:0] blend_channel(
        input integer a,
        input integer b,
        input integer step
    );
        integer result;
        result = (a * (8 - step) + b * step) / 8;

        blend_channel = result[7:0];
    endfunction

    // Count clock cycles btwn color changes
    always_ff @(posedge clk) begin
        if (reset_game) begin
            color_counter <= 0;
            color_phase <= 0;
        end
        else if (color_counter == COLOR_INTERVAL - 1) begin
            color_counter <= 0;
            color_phase <= color_phase + 1'b1;
        end
        else begin
            color_counter <= color_counter + 1'b1;
        end
    end

    // Choose start + end colors for each transition
    always_comb begin
        case (color_phase[4:3])
            2'd0: begin
                start_color = PINK;
                end_color   = PURPLE;
            end

            2'd1: begin
                start_color = PURPLE;
                end_color   = BLUE;
            end

            2'd2: begin
                start_color = BLUE;
                end_color   = MINT;
            end

            default: begin
                start_color = MINT;
                end_color   = PINK;
            end
        endcase
    end
    
    // Blend each channel
    assign current_color = {
        blend_channel(start_color[23:16], end_color[23:16], int'(color_phase[2:0])),
        blend_channel(start_color[15:8],  end_color[15:8],  int'(color_phase[2:0])),
        blend_channel(start_color[7:0],   end_color[7:0],   int'(color_phase[2:0]))
    };


    // ========================================
    // LED MATRIX OUTPUT
    // ========================================

    // Only living cells are illuminated
    assign pixel_color =
        board[pixel] ? current_color : 24'h000000;

    // Coordinates LED refresh + transmission
    controller u5 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel), 
        .frame          ()
    );
    
    // Load selected pixel color in GRB order (like og example)
    always_ff @(posedge clk) begin
        if (load_sreg) begin
            shift_reg <= {
                pixel_color[15:8],  // Green
                pixel_color[23:16], // Red
                pixel_color[7:0]    // Blue
            };
        end
        else if (shift) begin
            shift_reg <= {shift_reg[22:0], 1'b0};
        end
    end

    // Generate WS2812B LED data signal
    ws2812b u4 (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Physical FPGA output pins
    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule