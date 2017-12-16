module add
  (
   input             clk,
   input             reset,
   input             req_valid,
   input [63:0]      req_in_1,
   input [63:0]      req_in_2,
   output reg [63:0] resp_result
   );

   reg [63:0]        x;
   reg [63:0]        y;


   always @(posedge clk) begin
      if(req_valid) begin
         x <= req_in_1;
         y <= req_in_2;
      end
   end

   always @(posedge clk) begin
      resp_result <= x + y;
   end

endmodule
