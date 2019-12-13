module Seven_Segment(in0,in1,in2,in3,a,b,c,d,e,f,g);
input in0,in1,in2,in3;
output a,b,c,d,e,f,g;

assign a = !((!in0 & in1 & in3) | (!in0 & !in1 & !in3) | (!in0 & in2) | (in1 & in2) | (in0 & !in3) | (in0 & !in1 & !in2));
assign b = !((!in0 & !in1) | (!in0 & in2 & in3) | (in0 & !in1 & !in3) | (in0 & !in2 & in3) | (!in0 & !in2 & !in3));
assign c = !((!in0 & !in1 & !in2)  | (!in0 & !in1 & in3) | (!in0 & in1) | (in0 & !in1) | (!in2 & in3));
assign d = !((!in0 & !in1 & in2) | (in1 & in2 & !in3) | (!in1 & !in2 & !in3) | (!in1 & in2 & in3) | (in0 & in1 & !in2) | (in1 & !in2 &in3));
assign e = !((in2 & !in3) | (in0 & in1) | (in0 & in2) | (!in1 & !in2 & !in3));
assign g = !((in2 & !in3) | (in0 & !in1) | (in0 & in1 & in3) | (!in0 & in1 & !in2) | (!in0 & !in1 & in2));
assign f = !((!in2 & !in3) | (in0 & !in1) | (in0 & in2) | (!in0 & in1 & !in3) | (!in0 & in1 & !in2));
endmodule
