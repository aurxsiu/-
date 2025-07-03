module ne (
    CLR,
    T3,
    C,
    Z,
    RSWA,
    RSWB,
    RSWC,
    W3,
    W2,
    W1,
    IR,
    LDZ,
    LDC,
    CIN,
    DRW,
    S,
    SEL,
    M,
    ABUS,
    SBUS,
    MBUS,
    PCINC,
    PCADD,
    ARINC,
    LPC,
    LAR,
    STOP,
    SELCTL,
    LONG,
    SHORT,
    LIR,
    MEMW
);

  input CLR, T3, C, Z, RSWA, RSWB, RSWC, W3, W2, W1;
  input [3:0] IR;
  output reg LDZ, LDC, CIN, DRW,M, ABUS, SBUS, MBUS,PCINC, PCADD, ARINC, LPC, LAR, STOP, SELCTL,LONG, SHORT, LIR, MEMW;
  output reg [3:0] S;
  output reg [3:0] SEL;

  reg ADD, SUB, SIGAND, SIGOR, SIGXOR, LD, ST, NOP, INC, JC, JZ, JMP, SIGOUT, CMP, STP;
  reg STO, SSTO;
  reg SWC, SWB, SWA;
  reg SYSW;
  //直接让STO为1,懒得用ssto


  //   时钟控制
  always @(negedge CLR or negedge T3) begin
    if (CLR == 0) begin
      // TODO:复原信号 
      STO  <= 0;
      SSTO <= 0;
    end else begin  //下面说明T3触发

      if ((~W1) & (~W2) & (~W3)) begin  //实际上就是W1,但是会慢一拍
        SWA <= RSWA;
        SWB <= RSWB;
        SWC <= RSWC;
      end else
        case ({
          SWA, SWB, SWC, SSTO, STO, W1, W2
        })
          7'b0010010: begin
            SSTO <= 1;
          end
          7'b0011001: begin
            STO <= 1;
          end
          7'b1000010: begin
            STO <= 1;
          end
          7'b0100010: begin
            STO <= 1;
          end
          7'b0000010: begin
            SSTO <= 1;
          end
          7'b0001001: begin
            STO <= 1;
          end
          default: ;
        endcase
    end
  end
  // 设置指令变量
  always @(SWC, SWB, SWA, IR) begin

    ADD <= 0;
    SUB <= 0;
    SIGAND <= 0;
    SIGOR <= 0;
    SIGXOR <= 0;
    LD <= 0;
    ST <= 0;
    NOP <= 0;
    INC <= 0;
    JC <= 0;
    JZ <= 0;
    JMP <= 0;
    SIGOUT <= 0;
    CMP <= 0;
    STP <= 0;



    if (SWC == 0 && SWB == 0 && SWA == 0) begin
      case (IR)
        // 4'B0000: ADD <= STO;
        // 4'B0001: SUB <= STO;
        // 4'B0010: SIGAND <= STO;
        // 4'B0011: SIGOR <= STO;
        // 4'B0100: INC <= STO;
        // 4'B0101: LD <= STO;
        // 4'B0110: ST <= STO;
        // 4'B0111: JC <= STO;
        // 4'B1000: JZ <= STO;
        // 4'B1001: JMP <= STO;
        // 4'B1010: SIGOUT <= STO;
        // 4'B1011: SIGXOR <= STO;
        // 4'B1100: SET <= STO;
        // 4'B1101: CMP <= STO;
        4'B0001: ADD <= 1;
        4'B0010: SUB <= 1;
        4'B0011: SIGAND <= 1;
        4'B0100: INC <= 1;
        4'B0101: LD <= 1;
        4'B0110: ST <= 1;
        4'B0111: JC <= 1;
        4'B1000: JZ <= 1;
        4'B1001: JMP <= 1;
        4'B1010: SIGOUT <= 1;
        4'B1011: SIGOR <= 1;
        4'B1100: SIGXOR <= 1;
        4'B1101: NOP <= 1;
        4'B1110: STP <= 1;
      endcase
    end
  end

  //设置执行指令
  always @(SWA, SWB, SWC, W1, W2, W3, STO,ADD, SUB, SIGAND, SIGOR, SIGXOR, LD, ST, NOP, INC, JC, JZ, JMP, SIGOUT, CMP, STP) begin  //个人觉得敏感信号够了,看情况吧
    LONG <= (W2 & (~SWA) & (~SWB) & ~(SWC)) & (LD | ST);

    LIR <= ((~SWC) & (~SWB) & (~SWA)) & (W1);

    PCINC <= ((~SWC) & (~SWB) & (~SWA)) & (W1);

    LDZ <= ((~SWC) & (~SWB) & (~SWA) & W2) & (ADD | SUB | SIGAND | INC | SIGOR | SIGXOR | CMP);

    LDC <= ((~SWC) & (~SWB) & (~SWA) & W2) & (ADD | SUB | INC | JMP);

    CIN <= (~SWC) & (~SWB) & (~SWA) & W2 & ADD;

    DRW <= (SWC & (~ SWB) & (~ SWA) & (W1 | W2)) | 
		   ( ((~ SWC) & (~ SWB) & (~ SWA)) & 
		     (((ADD | SUB | SIGAND | SIGOR | SIGXOR | INC  ) & W2) | 
		      (LD & W3)));

    M <= (~ SWC) & (~ SWB) & (~ SWA) & 
		 (((SIGAND | SIGOR | SIGXOR  | LD | ST | JMP | SIGOUT) & W2) | (ST & W3));

    ABUS <= (~ SWC) & (~ SWB) & (~ SWA) & 
			(((ADD | SUB | SIGAND | SIGOR | SIGXOR | LD | 
			   ST  | INC | JMP | SIGOUT) & W2) | 
			 (ST & W3)
			 );

    SBUS <= ((SWC & (~ SWB) & (~ SWA)) & (W1 | W2)) | 
			((~ SWC) & SWB & (~ SWA) & (~ STO) & W1) | 
			((~ SWC) & (~ SWB) & SWA & W1);

    MBUS <= ((~SWC) & SWB & (~SWA) & STO & W1) | ((~SWC) & (~SWB) & (~SWA) & LD & W3);

    PCINC <= ((~SWC) & (~SWB) & (~SWA)) & W1;

    PCADD <= (~SWC) & (~SWB) & (~SWA) & ((JC & C) | (JZ & Z)) & W2;

    LPC <= ((~SWC) & (~SWB) & (~SWA) & JMP & W2);

    LAR <= ((~ SWC) & SWB & (~ SWA) & (~ STO) & W1) | 
		   ((~ SWC) & (~ SWB) & SWA & W1 & (~ STO)) | 
		   ((~ SWC) & (~ SWB) & (~ SWA) & W2 & (LD | ST));

    ARINC <= ((~SWC) & SWB & (~SWA) & STO & W1) | ((~SWC) & (~SWB) & SWA & STO & W1);

    STOP <= (SWC & (~ SWB) & (~ SWA)) | 
			((~ SWC) & SWB & SWA) 	   | 
			((~ SWC) & SWB & (~ SWA)) | 
			((~ SWC) & (~ SWB) & SWA) | 
			((~ SWC) & (~ SWB) & (~ SWA) & 
			 ((STP & W2))
			 );


    SELCTL <= (((SWC & (~ SWB) & (~ SWA)) | 
				((~ SWC) & SWB & SWA)) & (W1 | W2)) | 
			  ((((~ SWC) & SWB & (~ SWA)) | 
			    ((~ SWC) & (~ SWB) & SWA)) & W1);


    SHORT <= ((~SWC) & (~SWB) & SWA & W1) | ((~SWC) & SWB & (~SWA) & W1);

    MEMW <= ((~SWC) & (~SWB) & SWA & STO & W1) | ((~SWC) & (~SWB) & (~SWA) & ST & W3);

    S[3] <= ((~ SWC) & (~ SWB) & (~ SWA)) & 
			((W2 & (ADD | SIGAND | SIGOR | LD | ST  | JMP | SIGOUT)) | 
			 (ST & W3)
			 );


    S[2] <= ((~SWC) & (~SWB) & (~SWA) & W2) & (SUB | SIGOR | SIGXOR | ST | JMP | CMP);


    S[1] <= ((~ SWC) & (~ SWB) & (~ SWA)) & 
			((W2 & (SUB | SIGAND | SIGOR | SIGXOR | 
			  LD | ST | JMP | SIGOUT | CMP)) | 
			  (ST & W3)
			 );

    S[0] <= (~SWC) & (~SWB) & (~SWA) & (ADD | SIGAND | ST | JMP) & W2;


    SEL[3] <= ((SWC & (~SWB) & (~SWA) & STO) & (W1 | W2)) | ((~SWC) & SWB & SWA & W2);

    SEL[2] <= (SWC & (~SWB) & (~SWA) & W2);

    SEL[1] <= (SWC & (~ SWB) & (~ SWA) & (~ STO) & W1) | 
			  (SWC & (~ SWB) & (~ SWA) & STO & W2)       | 
			  ((~ SWC) & SWB & SWA & W2);

    SEL[0] <= (SWC & (~ SWB) & (~ SWA) & (~ STO) & W1) | 
			  (SWC & (~ SWB) & (~ SWA) & STO & W1)       | 
			  ((~ SWC) & SWB & SWA & (W1 | W2));

  end

endmodule
