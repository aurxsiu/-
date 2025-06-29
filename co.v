module co (
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

  reg ADD, SUB, SIGAND, SIGOR, SIGXOR, LD, ST, SET, INC, JC, JZ, JMP, SIGOUT, CMP, STP;
  reg STO, SSTO;
  reg SWC, SWB, SWA;
  reg SYSW;

  always @(SWC, SWB, SWA, IR, STO) begin
    ADD <= 0;
    SUB <= 0;
    SIGAND <= 0;
    SIGOR <= 0;
    SIGXOR <= 0;
    LD <= 0;
    ST <= 0;
    SET <= 0;
    INC <= 0;
    JC <= 0;
    JZ <= 0;
    JMP <= 0;
    SIGOUT <= 0;
    CMP <= 0;
    STP <= 0;



    if (SWC == 0 && SWB == 0 && SWA == 0 && STO == 0) begin
      case (IR)
        4'B0000: ADD <= STO;
        4'B0001: SUB <= STO;
        4'B0010: SIGAND <= STO;
        4'B0011: SIGOR <= STO;
        4'B0100: INC <= STO;
        4'B0101: LD <= STO;
        4'B0110: ST <= STO;
        4'B0111: JC <= STO;
        4'B1000: JZ <= STO;
        4'B1001: JMP <= STO;
        4'B1010: SIGOUT <= STO;
        4'B1011: SIGXOR <= STO;
        4'B1100: SET <= STO;
        4'B1101: CMP <= STO;
        4'B1110: STP <= STO;
      endcase
    end
  end

  always @(CLR, SYSW, SSTO) begin
    if (CLR == 0) begin
      STO <= 0;
      SWC <= 1;
      SWB <= 1;
      SWA <= 1;
    end else if (SYSW == 1) begin
      SWC <= RSWC;
      SWB <= RSWB;
      SWA <= RSWA;
    end
    if (SSTO == 0) begin
      STO <= 1;
    end
  end

  always @(T3, SWC, SWB, SWA, W1, W2, STO) begin
    if (T3 == 1) begin
      LIR <= ((~ SWC) & (~ SWB) & (~ SWA)) & 
		   ((W2 & (~ STO)) |
			((ADD | SUB | SIGAND | SIGOR | SIGXOR | 
			 SET | INC | SIGOUT | CMP) & W1) |
			 ((LD | ST | JMP) & W2) |
			 (JC & C & W2) |
			 (JZ & Z & W2) |
			 (JC & (~ C) & W1) |
			 (JZ & (~ Z) & W1));
    end

    SSTO <= (((SWC & (~ SWB) & (~ SWA)) & W2 & (~ STO)) | 
			 (((~ SWC) & SWB & (~ SWA)) & W1 & (~ STO)) | 
			 (((~ SWC) & (~ SWB) & SWA) & W1 & (~ STO)) | 
			 ((~ SWC) & (~ SWB) & (~ SWA) & W2 & (~ STO))
			 ) & T3;

    SYSW <= SWC & SWB & SWA & W1;
  end

  always @(T3, SWC, SWB, SWA, W1, W2, STO,IR,ADD, SUB, SIGAND, SIGOR, SIGXOR, LD, ST, SET, INC, JC, JZ, JMP, SIGOUT, CMP, STP) begin


    LDZ <= ((~ SWC) & (~ SWB) & (~ SWA) & W1) & 
		   (ADD | SUB | SIGAND | INC | SIGOR | SIGXOR | SET | CMP);

    LDC <= ((~SWC) & (~SWB) & (~SWA) & W1) & (ADD | SUB | INC | JMP);

    CIN <= (~SWC) & (~SWB) & (~SWA) & W1 & ADD;

    DRW <= (SWC & (~ SWB) & (~ SWA) & (W1 | W2)) | 
		   ( ((~ SWC) & (~ SWB) & (~ SWA)) & 
		     (((ADD | SUB | SIGAND | SIGOR | SIGXOR | INC  | SET) & W1) | 
		      (LD & W2)));

    M <= (~ SWC) & (~ SWB) & (~ SWA) & 
		 (((SIGAND | SIGOR | SIGXOR | LD | ST | SET | JMP | SIGOUT) & W1) | (ST & W2));

    ABUS <= (~ SWC) & (~ SWB) & (~ SWA) & 
			(((ADD | SUB | SIGAND | SIGOR | SIGXOR | LD | 
			   ST | SET | INC | JMP | SIGOUT) & W1) | 
			 (ST & W2)
			 );

    SBUS <= ((SWC & (~ SWB) & (~ SWA)) & (W1 | W2)) | 
			((~ SWC) & SWB & (~ SWA) & (~ STO) & W1) | 
			((~ SWC) & (~ SWB) & SWA & W1) | 
			((~ SWC) & (~ SWB) & (~ SWA) & (~ STO) & W1);

    MBUS <= ((~SWC) & SWB & (~SWA) & STO & W1) | ((~SWC) & (~SWB) & (~SWA) & LD & W2);

    PCINC <= ((~ SWC) & (~ SWB) & (~ SWA)) & 
		     ((W2 & (~ STO)) |
			  ((ADD | SUB | SIGAND | SIGOR | SIGXOR | 
			   SET | INC | SIGOUT | CMP) & W1) |
			   ((LD | ST | JMP) & W2) |
			   (JC & C & W2) |
			   (JZ & Z & W2) |
			   (JC & (~ C) & W1) |
			   (JZ & (~ Z) & W1));

    PCADD <= (~SWC) & (~SWB) & (~SWA) & ((JC & C) | (JZ & Z)) & W1;

    LPC <= ((~SWC) & (~SWB) & (~SWA) & JMP & W1) | ((~SWC) & (~SWB) & (~SWA) & W1 & (~STO));

    LAR <= ((~ SWC) & SWB & (~ SWA) & (~ STO) & W1) | 
		   ((~ SWC) & (~ SWB) & SWA & W1 & (~ STO)) | 
		   ((~ SWC) & (~ SWB) & (~ SWA) & W1 & (LD | ST));

    ARINC <= ((~SWC) & SWB & (~SWA) & STO & W1) | ((~SWC) & (~SWB) & SWA & STO & W1);

    STOP <= (SWC & (~ SWB) & (~ SWA)) | 
			((~ SWC) & SWB & SWA) 	   | 
			((~ SWC) & SWB & (~ SWA)) | 
			((~ SWC) & (~ SWB) & SWA) | 
			((~ SWC) & (~ SWB) & (~ SWA) & 
			 (((~ STO) & W1) | (STO & STP & W1))
			 );


    SELCTL <= (((SWC & (~ SWB) & (~ SWA)) | 
				((~ SWC) & SWB & SWA)) & (W1 | W2)) | 
			  ((((~ SWC) & SWB & (~ SWA)) | 
			    ((~ SWC) & (~ SWB) & SWA)) & W1) | 
			  ((~ SWC) & (~ SWB) & (~ SWA) & W1 & (~ STO));

    LONG <= 0;

    SHORT <= ((~ SWC) & (~ SWB) & SWA & W1) | 
			 ((~ SWC) & SWB & (~ SWA) & W1) |
			 ((~ SWC) & (~ SWB) & (~ SWA) & 
			   (W1 & (ADD | SUB | SIGAND | SIGOR | SIGXOR | CMP |
			    SET | INC | (JC & (~ C)) | (JZ & (~ Z)) | SIGOUT)));

    MEMW <= ((~SWC) & (~SWB) & SWA & STO & W1) | ((~SWC) & (~SWB) & (~SWA) & ST & W2);

    S[3] <= ((~ SWC) & (~ SWB) & (~ SWA)) & 
			((W1 & (ADD | SIGAND | SIGOR | LD | ST | SET | JMP | SIGOUT)) | 
			 (ST & W2)
			 );


    S[2] <= ((~SWC) & (~SWB) & (~SWA) & W1) & (SUB | SIGOR | SIGXOR | ST | SET | JMP | CMP);


    S[1] <= ((~ SWC) & (~ SWB) & (~ SWA)) & 
			((W1 & (SUB | SIGAND | SIGOR | SIGXOR | 
			  LD | ST | JMP | SIGOUT | CMP)) | 
			  (ST & W2)
			 );

    S[0] <= (~SWC) & (~SWB) & (~SWA) & (ADD | SIGAND | ST | JMP) & W1;


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
