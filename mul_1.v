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

   reg           x_signed;
   reg           y_signed;
   reg [31:0]    x;
   reg [31:0]    y;
   reg [31:0]    xh, xl;


   always @(posedge clk) begin
      if(req_valid) begin
         x_signed <= req_in_1_signed;
         y_signed <= req_in_2_signed;
         x <= req_in_1;
         y <= req_in_2;
      end
   end

   wire [2:0]    br0 = {x[1:0],1'b0};
   wire [2:0]    br1 = x[3:1];
   wire [2:0]    br2 = x[5:3];
   wire [2:0]    br3 = x[7:5];
   wire [2:0]    br4 = x[9:7];
   wire [2:0]    br5 = x[11:9];
   wire [2:0]    br6 = x[13:11];
   wire [2:0]    br7 = x[15:13];
   wire [2:0]    br8 = x[17:15];
   wire [2:0]    br9 = x[19:17];
   wire [2:0]    br10 = x[21:19];
   wire [2:0]    br11 = x[23:21];
   wire [2:0]    br12 = x[25:23];
   wire [2:0]    br13 = x[27:25];
   wire [2:0]    br14 = x[29:27];
   wire [2:0]    br15 = x[31:29];
   wire [2:0]    br16 = (x_signed) ? {3{x[31]}} : {2'b00,x[31]};

   wire          ng0 = (br0[2:1]==2'b10)|(br0[2:0]==3'b110);
   wire          ng1 = (br1[2:1]==2'b10)|(br1[2:0]==3'b110);
   wire          ng2 = (br2[2:1]==2'b10)|(br2[2:0]==3'b110);
   wire          ng3 = (br3[2:1]==2'b10)|(br3[2:0]==3'b110);
   wire          ng4 = (br4[2:1]==2'b10)|(br4[2:0]==3'b110);
   wire          ng5 = (br5[2:1]==2'b10)|(br5[2:0]==3'b110);
   wire          ng6 = (br6[2:1]==2'b10)|(br6[2:0]==3'b110);
   wire          ng7 = (br7[2:1]==2'b10)|(br7[2:0]==3'b110);
   wire          ng8 = (br8[2:1]==2'b10)|(br8[2:0]==3'b110);
   wire          ng9 = (br9[2:1]==2'b10)|(br9[2:0]==3'b110);
   wire          ng10 = (br10[2:1]==2'b10)|(br10[2:0]==3'b110);
   wire          ng11 = (br11[2:1]==2'b10)|(br11[2:0]==3'b110);
   wire          ng12 = (br12[2:1]==2'b10)|(br12[2:0]==3'b110);
   wire          ng13 = (br13[2:1]==2'b10)|(br13[2:0]==3'b110);
   wire          ng14 = (br14[2:1]==2'b10)|(br14[2:0]==3'b110);
   wire          ng15 = (br15[2:1]==2'b10)|(br15[2:0]==3'b110);
   wire          ng16 = 1'b0; //(br16[2:1]==2'b10)|(br16[2:0]==3'b110);

   wire [35:0]   by0, by1, by2, by3, by4, by5, by6, by7, by8;
   wire [35:0]   by9, by10, by11, by12, by13, by14, by15, by16;

   booth booth0(.i(0), .y_signed(y_signed), .br(br0), .y(y), .by(by0));
   booth booth1(.i(1), .y_signed(y_signed), .br(br1), .y(y), .by(by1));
   booth booth2(.i(1), .y_signed(y_signed), .br(br2), .y(y), .by(by2));
   booth booth3(.i(1), .y_signed(y_signed), .br(br3), .y(y), .by(by3));
   booth booth4(.i(1), .y_signed(y_signed), .br(br4), .y(y), .by(by4));
   booth booth5(.i(1), .y_signed(y_signed), .br(br5), .y(y), .by(by5));
   booth booth6(.i(1), .y_signed(y_signed), .br(br6), .y(y), .by(by6));
   booth booth7(.i(1), .y_signed(y_signed), .br(br7), .y(y), .by(by7));
   booth booth8(.i(1), .y_signed(y_signed), .br(br8), .y(y), .by(by8));
   booth booth9(.i(1), .y_signed(y_signed), .br(br9), .y(y), .by(by9));
   booth booth10(.i(1), .y_signed(y_signed), .br(br10), .y(y), .by(by10));
   booth booth11(.i(1), .y_signed(y_signed), .br(br11), .y(y), .by(by11));
   booth booth12(.i(1), .y_signed(y_signed), .br(br12), .y(y), .by(by12));
   booth booth13(.i(1), .y_signed(y_signed), .br(br13), .y(y), .by(by13));
   booth booth14(.i(1), .y_signed(y_signed), .br(br14), .y(y), .by(by14));
   booth booth15(.i(1), .y_signed(y_signed), .br(br15), .y(y), .by(by15));
   booth booth16(.i(1), .y_signed(y_signed), .br(br16), .y(y), .by(by16));

   assign resp_result = (({1'b0,by0}+ng0)) +
                        (({1'b0,by1}+ng1)<<2) +
                        (({1'b0,by2}+ng2)<<4) +
                        (({1'b0,by3}+ng3)<<6) +
                        (({1'b0,by4}+ng4)<<8) +
                        (({1'b0,by5}+ng5)<<10) +
                        (({1'b0,by6}+ng6)<<12) +
                        (({1'b0,by7}+ng7)<<14) +
                        (({1'b0,by8}+ng8)<<16) +
                        (({1'b0,by9}+ng9)<<18) +
                        (({1'b0,by10}+ng10)<<20) +
                        (({1'b0,by11}+ng11)<<22) +
                        (({1'b0,by12}+ng12)<<24) +
                        (({1'b0,by13}+ng13)<<26) +
                        (({1'b0,by14}+ng14)<<28) +
                        (({1'b0,by15}+ng15)<<30) +
                        (({1'b0,by16}+ng16)<<32);

endmodule

module booth
  (
   input             i,
   input             y_signed,
   input [2:0]       br,
   input [31:0]      y,
   output reg [35:0] by
   );

   wire              S = ((br==3'b000)|(br==3'b111)) ? 1'b0 : (y[31]&y_signed)^br[2] ;

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
