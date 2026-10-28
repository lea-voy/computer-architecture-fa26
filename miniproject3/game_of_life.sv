module game_of_life (
    input logic clk,
    input logic reset,
    input logic next_gen,
    output logic [63:0] board
);

    // Stores calculated next gen
    logic [63:0] next_board;

    // Load initial board from seed.mem
    logic [7:0] seed [0:7];

    initial begin
        $readmemh("seed.mem", seed);
    end

    function automatic int count_neighbors(
        input logic [63:0] current_board,
        input int i
    );
        int row;
        int col;
        int neighbor_row;
        int neighbor_col;
        int neighbor_index;
        int count;

        // Find cell's coordinates
        row = i / 8;
        col = i % 8;

        count = 0;

        // TODO: Visit 8 neighboring cells
        for (int dr = -1; dr <= 1; dr++) begin
            for (int dc = -1; dc <= 1; dc++) begin
                if (!(dr == 0 && dc == 0)) begin
                    // Calculate neighbor position
                    neighbor_row = (row + dr + 8) % 8;
                    neighbor_col = (col + dc + 8) % 8;

                    neighbor_index = neighbor_row * 8 + neighbor_col;

                    // Check if neighbor is alive
                    count = count + int'(current_board[neighbor_index]);
                end
            end
        end

        count_neighbors = count;
    endfunction

    // TODO: Calculate next gen using neighbor counts
    always_comb begin
        int neighbor_count;

        for (int i = 0; i < 64; i++) begin
            // Count  cell's neighbors, apply rules to next board
            neighbor_count = count_neighbors(board, i);
            
            if (neighbor_count == 3)
                next_board[i] = 1'b1;
            else if (neighbor_count == 2) 
                next_board[i] = board[i];
            else
                next_board[i] = 1'b0;
        end
    end

    // TODO: Update board when next_gen is asserted
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int r = 0; r < 8; r++) begin
                board[8*r +: 8] <= seed[r];
            end
        end
        else if (next_gen) begin
            board <= next_board;
        end
    end

endmodule