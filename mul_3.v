module mul
  (
   input         clk,
   input         reset,
   input         req_valid,
   input         req_in_1_signed,
   input         req_in_2_signed,
   input [31:0]  req_in_1,
   input [31:0]  req_in_2,
   output [63:0] resp_result
   );

   reg [46:14]   ms;
   reg [64:0]    m;

   reg           x_signed;
   reg           y_signed;
   reg [32:0]    x;
   reg [31:0]    y;
   reg [67:0]    result;
   
   integer       i;

   wire [2:0]    br0 = {x[1:0],1'b0};
   wire [2:0]    br1 = x[3:1];
   wire [2:0]    br2 = x[5:3];
   wire [2:0]    br3 = x[15:13];
   wire [2:0]    br4 = x[17:15];
   wire [2:0]    br5 = x[19:17];

   wire [35:0]   by0, by1, by2;
   wire [35:0]   by3, by4, by5;

   wire          ng0 = (br0[2:1]==2'b10)|(br0[2:0]==3'b110);
   wire          ng1 = (br1[2:1]==2'b10)|(br1[2:0]==3'b110);
//   wire          ng2 = (br2[2:1]==2'b10)|(br2[2:0]==3'b110);
   reg           ng2;
   wire          ng3 = (br3[2:1]==2'b10)|(br3[2:0]==3'b110);
   wire          ng4 = (br4[2:1]==2'b10)|(br4[2:0]==3'b110);
//   wire          ng5 = (br5[2:1]==2'b10)|(br5[2:0]==3'b110);
   reg           ng5;
   wire          ng16 = 1'b0;

   booth booth0(.i(0), .y_signed(y_signed), .br(br0), .y(y), .by(by0));
   booth booth1(.i(1), .y_signed(y_signed), .br(br1), .y(y), .by(by1));
   booth booth2(.i(1), .y_signed(y_signed), .br(br2), .y(y), .by(by2));
   booth booth3(.i(1), .y_signed(y_signed), .br(br3), .y(y), .by(by3));
   booth booth4(.i(1), .y_signed(y_signed), .br(br4), .y(y), .by(by4));
   booth booth5(.i(1), .y_signed(y_signed), .br(br5), .y(y), .by(by5));

   always @ (posedge clk) begin
      if(req_valid) begin
         x_signed <= req_in_1_signed;
         y_signed <= req_in_2_signed;
         x <= {req_in_1_signed&req_in_1[31],req_in_1};
         y <= req_in_2;
         i <= 5;
      end else begin
         ng2 <= (br2[2:1]==2'b10)|(br2[2:0]==3'b110);
         if(i!=2)
           ng5 <= (br5[2:1]==2'b10)|(br5[2:0]==3'b110);
         else
           ng5 <= (br4[2:1]==2'b10)|(br4[2:0]==3'b110);
         case(i)
           5: begin
              ms[46:22] <= {3'b000,by0[35:14]}+{1'b0,by1[35:12]}+{1'b0,by2[33:10]} + {ng16,{18{1'b0}}};
              ms[21:14] <= 8'h00;
              m[64:8] <= {7'h00,by3[35:0],               by0[13:0]}+
                         {5'h00,by4[35:0],1'b0,ng3,      by1[11:0],1'b0,ng0}+
                         {3'h0 ,by5[35:0],1'b0,ng4,2'b00,by2[ 9:0],1'b0,ng1,2'b00};
              m[7:0]  <= 8'h00;
           end
           4,3: begin
              ms[46:22] <= {3'b000,ms[46],~ms[46],ms[45:26]}+{1'b0,by1[35:12]}+{1'b0,by2[33:10]};
              ms[21:14] <= ms[25:18];
              m[64:8] <= {3'b000, m[64], ~m[64], m[63:12]}+
                         {5'h00,by4[35:0],1'b0,ng5,      by1[11:0],1'b0,ng2}+
                         {3'h0 ,by5[33:0],1'b0,ng4,2'b00,by2[ 9:0],1'b0,ng1,2'b00};
              m[7:0]  <= m[11:4];
           end
           2: begin
              m[64:0] <= m[64:0]+
                         {1'b0,by4[35:0],1'b0,ng5,26'h0}+
                         {       ms[46], ~ms[46], ms[45:14],1'b0,ng2,12'h0000};
           end
           1: begin
              m[64:0] <= m[64:0]+
                         {1'b0,by3[33:0],1'b0,ng5,28'h0}+
                         {1'b0,by4[31:0],1'b0,ng3,30'h0};
           end
         endcase
         i<=i-1;
         x <= {{4{x[32]}},x[32:4]};
      end
   end

   assign resp_result = m;

endmodule

module booth
  (
   input         i,
   input         y_signed,
   input [2:0]   br,
   input [31:0]  y,
   output reg [35:0] by
   );

   wire          S = ((br==3'b000)|(br==3'b111)) ? 1'b0 : (y[31]&y_signed)^br[2] ;

   always @(*) begin
      case(br)
        3'b000: by[32:0] =  {33{1'b0}};
        3'b001: by[32:0] =  {y[31]&y_signed,y[31:0]};
        3'b010: by[32:0] =  {y[31]&y_signed,y[31:0]};
        3'b011: by[32:0] =  {y[31:0],1'b0};
        3'b100: by[32:0] = ~{y[31:0],1'b0};
        3'b101: by[32:0] = ~{y[31]&y_signed,y[31:0]};
        3'b110: by[32:0] = ~{y[31]&y_signed,y[31:0]};
        3'b111: by[32:0] =  {33{1'b0}};
      endcase
      if(i) by[35:33] = {2'b01,~S};
      else  by[35:33] = {~S,S,S};
   end
endmodule
