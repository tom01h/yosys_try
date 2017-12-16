module fmul
  (
   input             clk,
   input             reset,
   input             req,
   input [31:0]      x,
   input [31:0]      y,
   output reg [31:0] rslt,
   output reg [4:0]  flag
   );

   wire [7:0]    expx = (x[30:23]==8'h00) ? 8'h01 : x[30:23];
   wire [7:0]    expy = (y[30:23]==8'h00) ? 8'h01 : y[30:23];
   wire [9:0]    expm = expx + expy - 127 + 1;
   reg [9:0]     expr;

   wire          sgnr = x[31]^y[31];

   wire [23:0]   fracx = {(x[30:23]!=8'h00),x[22:0]};
   wire [23:0]   fracy = {(y[30:23]!=8'h00),y[22:0]};
   wire [47:0]   fracm = fracx * fracy;
   reg [25:0]    fracr;
   reg [30:0]    guard;
   wire          rnd;

   wire [5:0]    nrmsft;                                        // expr >= nrmsft : subnormal output
   wire [56:0]   nrmi,nrm0,nrm1,nrm2,nrm3,nrm4,nrm5;

   assign nrmsft[5] =  (expr[8:5]!=4'h0) & (~(|nrmi[56:24])|(&nrmi[56:24]));
   assign nrmsft[4] = (((expr[8:4]&{3'h7,~nrmsft[5],  1'b1})!=5'h00) & (~(|nrm5[56:40])|(&nrm5[56:40])));
   assign nrmsft[3] = (((expr[8:3]&{3'h7,~nrmsft[5:4],1'b1})!=6'h00) & (~(|nrm4[56:48])|(&nrm4[56:48])));
   assign nrmsft[2] = (((expr[8:2]&{3'h7,~nrmsft[5:3],1'b1})!=7'h00) & (~(|nrm3[56:52])|(&nrm3[56:52])));
   assign nrmsft[1] = (((expr[8:1]&{3'h7,~nrmsft[5:2],1'b1})!=8'h00) & (~(|nrm2[56:54])|(&nrm2[56:54])));
   assign nrmsft[0] = (((expr[8:0]&{3'h7,~nrmsft[5:1],1'b1})!=9'h00) & (~(|nrm1[56:55])|(&nrm1[56:55])));

   assign nrmi = {fracr,guard};
   assign nrm5 = (~nrmsft[5]) ? nrmi : {nrmi[24:0], 32'h0000};
   assign nrm4 = (~nrmsft[4]) ? nrm5 : {nrm5[40:0], 16'h0000};
   assign nrm3 = (~nrmsft[3]) ? nrm4 : {nrm4[48:0], 8'h00};
   assign nrm2 = (~nrmsft[2]) ? nrm3 : {nrm3[52:0], 4'h0};
   assign nrm1 = (~nrmsft[1]) ? nrm2 : {nrm2[54:0], 2'b00};
   assign nrm0 = (~nrmsft[0]) ? nrm1 : {nrm1[55:0], 1'b0};
   wire [1:0] ssn = {nrm0[30],(|nrm0[29:0])};
   wire [2:0] grsn = {nrm0[32:31],(|ssn)};

   assign rnd = (grsn[1:0]==2'b11)|(grsn[2:1]==2'b11);

   wire [9:0]  expn = expr-nrmsft+(nrm0[56]^nrm0[55]); // subnormal(+0) or normal(+1)

   always @(*) begin
      if((expm==0)|expm[9])begin
         expr = expm+26;
         {fracr[25:0],guard[30:0]} <= {26'h0, 3'h0, fracm[47:20], (|fracm[19:0])};
      end else begin
         expr = expm;
         {fracr[25:0],guard[30:0]} <= {3'h0, fracm[47:0], 7'h00};
      end
   end
   always @(*) begin
      rslt[31] = sgnr;
      flag = 0;
      if((x[30:23]==8'hff)&(x[22:0]!=0))begin
         rslt = x|32'h00400000;
         flag[4]=~x[22]|((y[30:23]==8'hff)&~y[22]&(y[21:0]!=0));
      end else if((y[30:23]==8'hff)&(y[22:0]!=0))begin
         rslt = y|32'h00400000;
         flag[4]=~y[22]|((x[30:23]==8'hff)&~x[22]&(x[21:0]!=0));
      end else if(x[30:23]==8'hff)begin
         if(y[30:0]==0)begin
            rslt = 32'hffc00000;
            flag[4] = 1'b1;
         end else begin
            rslt[31:0] = {x[31]^y[31],x[30:0]};
         end
      end else if(y[30:23]==8'hff)begin
         if(x[30:0]==0)begin
            rslt = 32'hffc00000;
            flag[4] = 1'b1;
         end else begin
            rslt[31:0] = {x[31]^y[31],y[30:0]};
         end
      end else if({fracr,guard}==0)begin
         rslt[30:0] = 31'h00000000;
      end else if(expn[9])begin
         rslt[30:0] = 31'h00000000;
         flag[0] = 1'b1;
         flag[1] = 1'b1;
      end else if((expn[8:0]>=9'h0ff)&(~expn[9]))begin
         rslt[30:0] = 31'h7f800000;
         flag[0] = 1'b1;
         flag[2] = 1'b1;
      end else begin
         rslt[30:0] = {expn[7:0],nrm0[54:32]}+rnd;
         flag[0]=|grsn[1:0];
         flag[1]=((rslt[30:23]==8'h00)|((expn[7:0]==8'h00)&~ssn[1]))&(flag[0]);
         flag[2]=(rslt[30:23]==8'hff);
      end
   end

endmodule
