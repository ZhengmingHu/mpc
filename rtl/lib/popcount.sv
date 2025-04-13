module pop_count #(
    parameter INPUT_WIDTH = 4,
    parameter OUTPUT_WIDTH = $clog2(INPUT_WIDTH)
) (
    input wire [INPUT_WIDTH-1:0] in,
    output reg [OUTPUT_WIDTH-1:0] count
);

integer i;

always @(*) begin
    count = 0;
    for (i = 0; i < INPUT_WIDTH; i = i + 1) begin
        if (in[i])
            count = count + 1;
    end
end

endmodule