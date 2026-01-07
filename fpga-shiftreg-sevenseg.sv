module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

logic [3:0] temp, temp1, temp2;
 
shift_reg shift(.clk(hz100), .reset(reset), .en(pb[1]),
                  .Q({left[7:0], red, right[7:0]}));

one_up_counter one(.clk(left[7]), .en(pb[1]), .reset(reset), .out(temp));
one_up_counter two(.clk(temp[3] & temp[0]), .en(pb[1]), .reset(reset), .out(temp1));
one_up_counter three(.clk(temp1[3] & temp1[0]), .en(pb[1]), .reset(reset), .out(temp2));

ssdec s0(.in(temp), .out(ss0[7:0]), .enable(1'b1));
ssdec s1(.in(temp1), .out(ss1[7:0]), .enable(~(temp1 == 0) | ~(temp2 == 0)));
ssdec s2(.in(temp2), .out(ss2[7:0]), .enable(~(temp2 == 0)));
 
endmodule


module one_up_counter(
  input logic clk, en, reset,
  output logic [3:0] out
);

  logic [3:0] next_out;
 
  always_ff @ (negedge clk, posedge reset) begin
    if(reset == 1)
      out <= 0;
    else if(en == 1)
      out <= next_out;
  end
 
  always_comb begin
    if(out == 4'd9)
      next_out = 0;
    else begin
      next_out[0] = ~out[0];
      next_out[1] = out[1] ^ out[0];
      next_out[2] = out[2] ^ &(out[1:0]);
      next_out[3] = out[3] ^ &(out[2:0]);
    end
  end


endmodule

module shift_reg(
  input logic clk, reset, en,
  output logic [16:0] Q
);

  logic [16:0] NEXT_Q;
 
  always_ff @ (posedge clk, posedge reset) begin
    if(reset == 1)
      Q <= 17'b0;
    else if(en == 1)
      Q <= NEXT_Q;
  end
 
  always_comb begin
      if(Q == 17'b11111111111111111)
        NEXT_Q = 17'b0;
      else begin
        NEXT_Q[0] = 1'b1;
        NEXT_Q[1] = Q[0];
        NEXT_Q[2] = Q[1];
        NEXT_Q[3] = Q[2];
        NEXT_Q[4] = Q[3];
        NEXT_Q[5] = Q[4];
        NEXT_Q[6] = Q[5];
        NEXT_Q[7] = Q[6];
        NEXT_Q[8] = Q[7];
        NEXT_Q[9] = Q[8];
        NEXT_Q[10] = Q[9];
        NEXT_Q[11] = Q[10];
        NEXT_Q[12] = Q[11];
        NEXT_Q[13] = Q[12];
        NEXT_Q[14] = Q[13];
        NEXT_Q[15] = Q[14];
        NEXT_Q[16] = Q[15];
      end
    end

endmodule

module ssdec (input logic [3:0]in, output logic [7:0]out, input logic enable);
   
    logic [7:0] SEG7 [15:0];
    assign SEG7[4'h0] = 8'b00111111;
    assign SEG7[4'h1] = 8'b00000110;
    assign SEG7[4'h2] = 8'b01011011;
    assign SEG7[4'h3] = 8'b01001111;
    assign SEG7[4'h4] = 8'b01100110;
    assign SEG7[4'h5] = 8'b01101101;
    assign SEG7[4'h6] = 8'b01111101;
    assign SEG7[4'h7] = 8'b00000111;
    assign SEG7[4'h8] = 8'b01111111;
    assign SEG7[4'h9] = 8'b01100111;
    assign SEG7[4'ha] = 8'b01110111;
    assign SEG7[4'hb] = 8'b01111100;
    assign SEG7[4'hc] = 8'b00111001;
    assign SEG7[4'hd] = 8'b01011110;
    assign SEG7[4'he] = 8'b01111001;
    assign SEG7[4'hf] = 8'b01110001;
   
   
    assign out = enable == 1?SEG7[in]:0;

endmodule
