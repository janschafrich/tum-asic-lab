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



entity keccak is
  
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    start : in std_logic;		    -- start computing the hash
    din     : in  std_logic_vector(63 downto 0);
    din_valid: in std_logic;		-- data in ready to be consumed
    buffer_full: out std_logic;		-- 
    last_block: in std_logic;    -- there is only one block - output mode, blocksize = r
    ready : out std_logic;		 -- permutation completed
    dout    : out std_logic_vector(63 downto 0);
    dout_valid : out std_logic);	-- hash ready to be read

end keccak;

architecture rtl of keccak is

--components

component keccak_round
port (

    round_in     : in  k_state;
    round_constant_signal    : in std_logic_vector(63 downto 0);
    round_out    : out k_state);

end component;

component keccak_round_constants_gen
port (
    round_number: in unsigned(4 downto 0);
    round_constant_signal_out: out std_logic_vector(63 downto 0));
 end component;


component keccak_buffer 
  
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;    
    din_buffer_in     : in  std_logic_vector(63 downto 0);
    din_buffer_in_valid: in std_logic;
    last_block: in std_logic;
    din_buffer_full : out std_logic;
    din_buffer_out    : out std_logic_vector(1343 downto 0);
    dout_buffer_in : in std_logic_vector(511 downto 0);
    dout_buffer_out: out std_logic_vector(63 downto 0);
    dout_buffer_out_valid: out std_logic;
    ready: in std_logic);

 end component;

  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

 
  signal reg_data,round_in,round_out: k_state;
  --signal zero_state : k_state;
  signal reg_data_vector: std_logic_vector (511 downto 0);
  signal counter_nr_rounds : unsigned(4 downto 0);
  --signal zero_lane: k_lane;
  signal din_buffer_full:std_logic;
  --signal zero_plane: k_plane;
  signal round_constant_signal: std_logic_vector(63 downto 0);
  signal din_buffer_out: std_logic_vector(1343 downto 0);
  signal permutation_computed : std_logic;
 
  
begin  -- Rtl

-- instantiations

round_map : keccak_round port map(round_in,round_constant_signal,round_out);
round_constants_gen: keccak_round_constants_gen port map(counter_nr_rounds,round_constant_signal);
buffer_in: keccak_buffer port map(
	clk, rst_n,
	din,din_valid,last_block, 
	din_buffer_full,din_buffer_out,
	dout_buffer_in 			=> reg_data_vector,
	dout_buffer_out 		=> dout,
	dout_buffer_out_valid 	=> dout_valid,
	ready 					=> permutation_computed);

-- constants signals
--zero_lane<= (others =>'0');

--i000: for x in 0 to 4 generate
--	zero_plane(x)<= zero_lane;
--end generate;

--i001: for y in 0 to 4 generate
--	zero_state(y)<= zero_plane;
--end generate;

--transform part of the state to a vector 512 bit
-- 320 bit of row = 0
i002: for col in 0 to 4 generate
	i003: for i in 0 to 63 generate		-- row, col, bit
		reg_data_vector(64*col+i) <= reg_data(0)(col)(i);
	end generate;
end generate;

-- 192 bit of of row 1 = 3 columns
i004: for col in 0 to 2 generate
	i005: for i in 0 to 63 generate		-- row, col, bit
		reg_data_vector(64*(5+col)+i) <= reg_data(1)(col)(i);
	end generate;
end generate;

 
 
 -- state register and counter of the number of rounds
 
  p_main : process (clk, rst_n)
    
  begin  -- process p_main
    if rst_n = '0' then                 -- asynchronous rst_n (active low)
      --reg_data <= zero_state;
      	for row in 0 to 4 loop
			for col in 0 to 4 loop
				for i in 0 to 63 loop
					reg_data(row)(col)(i)<='0';	-- init with zero
				end loop;
			end loop;
		end loop;
      counter_nr_rounds <= (others => '0');
      permutation_computed <='1';
    elsif clk'event and clk = '1' then  -- rising clk edge

	if (start='1') then
		--reg_data <= zero_state;
		for row in 0 to 4 loop
			for col in 0 to 4 loop
				for i in 0 to 63 loop
					reg_data(row)(col)(i)<='0';		-- init with zero
				end loop;
			end loop;
		end loop;
		counter_nr_rounds <= (others => '0');	
		permutation_computed<='1';		
	else -- start='0'
		if(din_buffer_full ='1' and permutation_computed='1') then
			counter_nr_rounds(4 downto 0)<= (others => '0');
			counter_nr_rounds(0)<='1';
			permutation_computed<='0';
			reg_data<= round_out;
		else -- if start='0' and permutation_computed='0' and buffer_full='0'
			if( counter_nr_rounds < 24 and permutation_computed='0') then			
				counter_nr_rounds <= counter_nr_rounds + 1;
				reg_data<= round_out;			-- write round output to stateregister
							
			end if;
			if( counter_nr_rounds = 23) then	-- after 24 rounds permutation result is available
				permutation_computed<='1';
				counter_nr_rounds<= (others => '0');
			end if;
		end if;
		
	end if;
    end if;
  end process p_main;

--input mapping


--capacity part  4 * 64 + 5 *64
	i01: for col in 1 to 4 generate
		i02: for i in 0 to 63 generate
			round_in(4)(col)(i)<= reg_data(4)(col)(i);

		
		end generate;	
	end generate;

	-- i03: for col in 0 to 1 generate
	-- 	i04: for i in 0 to 63 generate
	-- 		round_in(4)(col)(i)<= reg_data(4)(col)(i);

		
	-- 	end generate;	
	-- end generate;
--rate part		4 * 5 * 64 + 64  = 1344   () first rate, than capacity
i10: for row in 0 to 3 generate
	i11: for col in 0 to 4 generate
		i12: for i in 0 to 63 generate
			round_in(row)(col)(i)<= reg_data(row)(col)(i) xor (din_buffer_out((row*64*5)+(col*64)+i) and (din_buffer_full and permutation_computed));
		end generate;	
	end generate;
end generate;

-- last row, first columns
i13: for i in 0 to 63 generate
			round_in(4)(0)(i)<= reg_data(4)(0)(i) xor (din_buffer_out((4*64*5)+(0*64)+i) and (din_buffer_full and permutation_computed));
end generate;	

	

ready		<=	permutation_computed;
buffer_full	<=	din_buffer_full;
end rtl;
