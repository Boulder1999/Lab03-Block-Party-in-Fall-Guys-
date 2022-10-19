module BP(
  clk,
  rst_n,
  in_valid,
  guy,
  in0,
  in1,
  in2,
  in3,
  in4,
  in5,
  in6,
  in7,
  
  out_valid,
  out
);
parameter IDLE=2'd0,LOAD=2'd1,OUT=2'd2;
reg [1:0]ns ,cs ;
input             clk, rst_n;
input             in_valid;
input       [2:0] guy;
input       [1:0] in0, in1, in2, in3, in4, in5, in6, in7;
output reg        out_valid;
output reg  [1:0] out;
reg [3:0]prev_pos;
reg [5:0]counter;
reg [5:0]cnta,cnt,cntc;
reg [5:0]cycle_gap[0:31];
reg [3:0]idx_gap[0:31];
reg [1:0]type_wall[0:31];
integer i;
reg [5:0]cnt2,cnt1;
reg [3:0]abs;

always@(*)
begin
  if(idx_gap[cnt1][3]) 
  begin
    abs=~(idx_gap[cnt1])+4'd1;
  end
  else begin
    abs=idx_gap[cnt1];
  end
end

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    cs <= IDLE ;
  end
  else begin
    cs <= ns ;
  end
end

always@(*)
begin
  case(cs)
  IDLE:begin
    if(in_valid)
    begin
      ns = LOAD ;
    end
    else begin
      ns = IDLE ;
    end
  end
  LOAD:begin
    if(in_valid)
    begin
      ns = LOAD;
    end
    else begin
      ns = OUT ; 
    end
  end
  OUT:begin
    if(counter < 6'd63)
    begin
      ns = OUT ;
    end
    else begin
      ns = IDLE ;
    end
  end
  default:ns = IDLE ;
  endcase
end

always@(posedge clk or negedge rst_n)begin//NOofOB
  if(!rst_n)
  begin
    cnt<=6'd0;
  end
  else if(ns == IDLE)
  begin
      cnt<= 6'd0 ;
  end
  else if(ns == LOAD)
  begin
    if(in7!=2'b0)
    begin
      cnt<=cnt+6'd1;
    end
  end
end
always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    for(i=0;i<32;i=i+1)
    begin
      idx_gap[i]<=0;
    end
  end
  else if( ns == IDLE)
  begin
    for(i=0;i<32;i=i+1)
    begin
      idx_gap[i]<=0;
    end
  end
  else if(ns == LOAD)
  begin
    if(in7 != 2'b00) begin
      if( in0 != 2'b11)begin
        idx_gap[cnt]<= $signed($signed(4'd7)-prev_pos);
      end
      else if(in1 != 2'b11) begin
        idx_gap[cnt]<= $signed($signed(4'd6)-prev_pos);
      end
      else if(in2 != 2'b11) begin
        idx_gap[cnt]<= $signed($signed(4'd5)-prev_pos);
      end
      else if(in3 != 2'b11) begin
        idx_gap[cnt]<= $signed($signed(4'd4)-prev_pos);
      end
      else if(in4 != 2'b11) begin
        idx_gap[cnt]<= $signed($signed(4'd3)-prev_pos);
      end
      else if(in5 != 2'b11) begin
        idx_gap[cnt]<= $signed($signed(4'd2)-prev_pos);
      end
      else if(in6 != 2'b11) begin
        idx_gap[cnt]<= $signed($signed(4'd1)-prev_pos);
      end
      else if(in7 != 2'b11) begin
       idx_gap[cnt]<= $signed($signed(4'd0)-prev_pos);
      end
    end
  end
end


always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    prev_pos<=0;
  end
  else if(cs == IDLE  && in_valid)
  begin
    prev_pos<=7-guy;
  end
  else if(ns == LOAD)
  begin
    if(in7 != 2'b00) begin
      if( in0 != 2'b11)begin
        prev_pos<= $signed(4'd7);
      end
      else if(in1 != 2'b11) begin
        prev_pos<=$signed(4'd6);
      end
      else if(in2 != 2'b11) begin
        prev_pos<=$signed(4'd5);
      end
      else if(in3 != 2'b11) begin
        prev_pos<=$signed(4'd4);
      end
      else if(in4 != 2'b11) begin
        prev_pos<=$signed(4'd3);
      end
      else if(in5 != 2'b11) begin
        prev_pos<=$signed(4'd2);
      end
      else if(in6 != 2'b11) begin
        prev_pos<=$signed(4'd1);
      end
      else if(in7 != 2'b11) begin
        prev_pos<=$signed(4'd0);
      end
    end
  end
end


always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
  begin
    for(i=0;i<32;i=i+1)
    begin
      type_wall[i]<=2'b00;
    end
  end
  else if (ns == IDLE )
  begin
    for(i=0;i<32;i=i+1)
    begin
      type_wall[i]<=2'b00;
    end
  end
  else if(ns == LOAD)
  begin
   if(in0 == 2'b01 || in1 == 2'b01 || in2 == 2'b01 ||in3 == 2'b01 || in4 == 2'b01 || in5 == 2'b01 ||in6 == 2'b01 || in7 == 2'b01 )//junp
    begin
        type_wall[cnt]<=2'b01;
    end
    else if(in0 == 2'b10 || in1 == 2'b10 || in2 == 2'b10 ||in3 == 2'b10 || in4 == 2'b10 || in5 == 2'b10 ||in6 == 2'b10 || in7 == 2'b10)//noj
    begin
        type_wall[cnt]<=2'b10;
    end
  end
end

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    counter <= 6'd0;
  end
  else if( ns == IDLE )
  begin
    counter <=  6'd0;
  end
  else if( cs == OUT )
  begin
    counter <= counter + 6'd1;
  end
end

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    out_valid <= 1'b0;
  end
  else if( ns == IDLE) begin
    out_valid <= 1'b0;
  end
  else if( cs == OUT )
  begin
    out_valid<=1'b1;
  end
end
always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    for(i=0;i<32;i=i+1)
    begin
      cycle_gap[i]<=0;
    end
  end
  else if(ns == IDLE)
  begin
    for(i=0;i<32;i=i+1)
    begin
      cycle_gap[i]<=0;
    end
  end
  else if( ns == LOAD)
  begin
    if(in7!=2'b00)
    begin
      cycle_gap[cnt]<=cntc-cnta;
    end
  end
end


always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
  begin
    cntc<=6'd0;
  end
  else if(ns == IDLE)
  begin
      cntc<= 6'd0 ;
  end
  else if(ns == LOAD)
  begin
      cntc<=cntc+6'd1;
  end
end

always@(posedge clk or negedge rst_n)begin
  if(!rst_n)
  begin
    cnta <= 6'd0;
  end
  else if(ns ==IDLE)
  begin
    cnta<=6'd0;
  end
  else if( ns == LOAD)  
  begin
   if({in7}!=2'b0)
    begin
        cnta <= cntc;
    end
  end
end

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    cnt1<=6'd0;
    cnt2<=6'd0;
  end
  else if(ns == IDLE)
  begin
    cnt1<=6'd0;
    cnt2<=6'd0;
  end
  else if(cs == OUT)
  begin
    if(cycle_gap[cnt1]-1==cnt2)
    begin
      cnt1<=cnt1+6'd1;
      cnt2<=6'd0;
    end
    else begin
      cnt2<=cnt2+6'd1;
    end
  end
end
always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) begin
    out <= 2'b0;
  
  end
  else if(ns == IDLE)
  begin
    out<=2'b0;

  end
  else if(cs == OUT)
  begin
    if(abs >  cnt2 )
    begin
     if(!idx_gap[cnt1][3])
      begin
        out<=2'b10;
 
      end
      else if(idx_gap[cnt1][3])
      begin
        out<=2'b01;
   
      end
    end
    else if(abs < cnt2 || abs == cnt2)
    begin
      if(cycle_gap[cnt1]-6'd1>cnt2  )
      begin
        out<=2'b00;
      end
      else if(cycle_gap[cnt1]-6'd1==cnt2)
      begin
        if(type_wall[cnt1]==2'b01)
        begin
          out<=2'b11;
        end
        else if(type_wall[cnt1]==2'b10)
        begin
          out<=2'b00;
        end
        else begin
          out<=2'b00;
        end
      end
    end
  end
end

endmodule
