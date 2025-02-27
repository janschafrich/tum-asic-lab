-- The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
-- Micha�l Peeters and Gilles Van Assche. For more information, feedback or
-- questions, please refer to our website: http://keccak.noekeon.org/

-- Implementation by the designers,
-- hereby denoted as "the implementer".

-- To the extent possible under law, the implementer has waived all copyright
-- and related or neighboring rights to the source code in this file.
-- http://creativecommons.org/publicdomain/zero/1.0/
library work;
	use work.keccak_globals.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;



entity keccak_buffer is
  
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;    
    din_buffer_in     : in  std_logic_vector(63 downto 0);
    din_buffer_in_valid: in std_logic;
    last_block: in std_logic;
    din_buffer_full : out std_logic;
    din_buffer_out    : out std_logic_vector(1343 downto 0);
    dout_buffer_in : in std_logic_vector(511 downto 0);		-- reg_data_vector
    dout_buffer_out: out std_logic_vector(63 downto 0);
    dout_buffer_out_valid: out std_logic;
    ready: in std_logic);

end keccak_buffer;

architecture rtl of keccak_buffer is

--components


  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

 
signal mode, buffer_full: std_logic; --mode=0 input mode/ mode=1 output mode
signal count_in_words : unsigned(4 downto 0);


signal buffer_data: std_logic_vector(1343 downto 0);  -- SHAKE128 demands r = 1344, adapt the rest of the code!
 
  
begin  -- Rtl


 
 
 -- buffer
 
  p_main : process (clk, rst_n)
 variable count_out_words:integer range 0 to 8;		-- word 64 bit * 5 = 320
    
  begin  -- process p_main
    if rst_n = '0' then                 -- asynchronous rst_n (active low)
      buffer_data <= (others => '0');
      count_in_words <= (others => '0');
      count_out_words :=0;
      buffer_full <='0';
      mode<='0';      
      dout_buffer_out_valid<='0';
      
    elsif clk'event and clk = '1' then  -- rising clk edge
	
	
	if(last_block ='1' and ready='1') then
		mode<='1';
	end if;

	--input mode
	if (mode='0') then
		if(buffer_full='1' and ready ='1')  then
			buffer_full<='0';
			count_in_words<= (others=>'0');
			
		else -- mode='1'
			
			if (din_buffer_in_valid='1' and buffer_full='0') then
							--shift bits 1023:64 down to 959:0 -> shift 1343:64 -> 1280:0
					for i in 0 to 19 loop
						buffer_data( 63+(i*64) downto 0+(i*64) )<=buffer_data( 127+(i*64) downto 64+(i*64) );			
					end loop;
			
					--insert new input
					buffer_data(1343 downto 1280) <= din_buffer_in;  -- 64 bit

					if (count_in_words=20) then
						-- buffer full ready for being absorbed by the permutation
						buffer_full <= '1';
						count_in_words<= (others=>'0');
				
					else
				
						-- increment count_in_words
						count_in_words <= count_in_words + 1;				
					
					end if;		
			--	end if;
			end if;
		end if;

	else
		--output mode (mode='1'?)
		dout_buffer_out_valid<='1';	-- output mode
		if(count_out_words=0) then
			buffer_data(511 downto 0) <= dout_buffer_in;	-- reg_data_vector (state between permutations)
			count_out_words    		:=count_out_words+1;
			dout_buffer_out_valid	<='1';
		
			--for i in 0 to 2 loop
			--	buffer_data( 63+(i*64) downto 0+(i*64) )<=buffer_data( 127+(i*64) downto 64+(i*64) );
			--end loop;

		
		else
			if(count_out_words<8) then		-- 8 x 64 bit = 512 bit
				count_out_words			:= count_out_words+1;
				dout_buffer_out_valid	<= '1';
			
				-- shift 64 bit word by 64 bit down
				for i in 0 to 6 loop
					buffer_data( 63+(i*64) downto 0+(i*64) ) <= buffer_data( 127+(i*64) downto 64+(i*64) );
			
				end loop;
			else
				dout_buffer_out_valid<='0';
				count_out_words:=0;
				mode<='0';					
			end if;
		end if;
							
		
	end if;
    end if;
  end process p_main;

din_buffer_out  <= buffer_data;
dout_buffer_out <= buffer_data(63 downto 0);
din_buffer_full <= buffer_full;

end rtl;
