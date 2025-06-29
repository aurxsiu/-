signal SySW: std_logic;
begin
    process(SySW)
    begin
        if (SySW'event and SySW = '1') then		
			-- synchronizate SWC/B/A if SySW is at the rising edge
				SWC <= RSWC; SWB <= RSWB; SWA <= RSWA;
			end if;
    end process