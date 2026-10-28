`timescale 1ns/1ps

module game_of_life_tb;

    logic clk = 0;
    logic reset = 0;
    logic next_gen = 0;

    logic [63:0] board;

    // Instantiate Game of Life module
    game_of_life dut (
        .clk(clk),
        .reset(reset),
        .next_gen(next_gen),
        .board(board)
    );

    // Clock toggles every 5 ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("game_of_life.vcd");
        $dumpvars(0, game_of_life_tb);

        // Reset the game
        @(negedge clk);
        reset = 1;

        @(posedge clk);
        #1;
        $display("Initial board: %h", board);

        if (board !== 64'h0100000000000081)
            $error("Initial corner pattern incorrect!");
        else
            $display("Initial corner pattern passed!");

        @(negedge clk);
        reset = 0;

        // Advance one generation
        next_gen = 1;

        @(posedge clk);
        #1;
        $display("Generation 1: %h", board);

        if (board !== 64'h8100000000000081)
            $error("Wraparound generation 1 incorrect!");
        else
            $display("Wraparound generation 1 passed!");

        @(negedge clk);
        next_gen = 0;

        // Advance another generation
        @(negedge clk);
        next_gen = 1;

        @(posedge clk);
        #1;

        $display("Generation 2: %h", board);

        if (board !== 64'h8100000000000081)
            $error("Wraparound generation 2 incorrect!");
        else
            $display("Wraparound generation 2 passed!");

        @(negedge clk);
        next_gen = 0;

        $finish;
    end

endmodule