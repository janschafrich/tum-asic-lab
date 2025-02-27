-- The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
-- Micha�l Peeters and Gilles Van Assche. For more information, feedback or
-- questions, please refer to our website: http://keccak.noekeon.org/

-- Implementation by the designers,
-- hereby denoted as "the implementer".

-- To the extent possible under law, the implementer has waived all copyright
-- and related or neighboring rights to the source code in this file.
-- http://creativecommons.org/publicdomain/zero/1.0/

	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
library work;
	use work.keccak_globals.all;


entity pe is
  
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    data_from_mem: in std_logic_vector(63 downto 0);
    data_to_mem: out std_logic_vector(63 downto 0);
    nr_round: in integer range 0 to 23;
    command: in std_logic_vector(7 downto 0) ;
    counter_plane_to_pe: in integer range 0 to 4;
    counter_sheet_to_pe: in integer range 0 to 4

);
    
end pe;

architecture rtl of pe is

--components


  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------
signal r1_out, r2_out, r3_out,rho_out, chi_out,iota: std_logic_vector(63 downto 0);
signal r1_in, r2_in, r3_in : std_logic_vector(63 downto 0);
 
  
begin  -- Rtl

 
 
 -- 3 registers
 
  reg_main : process (clk, rst_n)
    
  begin  -- process p_main
    if rst_n = '0' then                 -- asynchronous rst_n (active low)
		r1_out<=(others=>'0');
		r2_out<=(others=>'0');
		r3_out<=(others=>'0');
      

    elsif clk'event and clk = '1' then  -- rising clk edge
	
		r1_out<=r1_in;
		r2_out<=r2_in;
		r3_out<=r3_in;
  end if;
  end process reg_main;
  
  
--registers input
r1_in<= data_from_mem when command(0)='1' else
		data_from_mem xor r1_out when command(1)='1' else
		data_from_mem xor r3_out xor (r2_out(62 downto 0) & r2_out(63)) when command(2)='1' else
		r1_out;

r2_in<=r1_out when command(3)='1' else
	r2_out;
r3_in <= r2_out when command(3)='1' else
	r3_out;


data_to_mem<= r1_out when command(4)='1' else
			rho_out when command(5)='1' else
			chi_out when command(6)='1' else
			chi_out xor iota when command(7)='1' else
			(others=>'0');
			
chi_out <= r3_out xor( not(r2_out) and r1_out);

rho_out<=r1_out when (counter_plane_to_pe=0 and counter_sheet_to_pe=0) else
	r1_out(63-1 downto 0) & r1_out(63) when (counter_plane_to_pe=0 and counter_sheet_to_pe=1) else
	r1_out(63-62 downto 0) & r1_out(63 downto 64-62) when (counter_plane_to_pe=0 and counter_sheet_to_pe=2) else
	r1_out(63-28 downto 0) & r1_out(63 downto 64-28) when (counter_plane_to_pe=0 and counter_sheet_to_pe=3) else
	r1_out(63-27 downto 0) & r1_out(63 downto 64-27) when (counter_plane_to_pe=0 and counter_sheet_to_pe=4) else
	
	r1_out(63-36 downto 0) & r1_out(63 downto 64-36) when (counter_plane_to_pe=1 and counter_sheet_to_pe=0) else
	r1_out(63-44 downto 0) & r1_out(63 downto 64-44) when (counter_plane_to_pe=1 and counter_sheet_to_pe=1) else
	r1_out(63-6 downto 0) & r1_out(63 downto 64-6) when (counter_plane_to_pe=1 and counter_sheet_to_pe=2) else
	r1_out(63-55 downto 0) & r1_out(63 downto 64-55) when (counter_plane_to_pe=1 and counter_sheet_to_pe=3) else
	r1_out(63-20 downto 0) & r1_out(63 downto 64-20) when (counter_plane_to_pe=1 and counter_sheet_to_pe=4) else
	
	r1_out(63-3 downto 0) & r1_out(63 downto 64-3) when (counter_plane_to_pe=2 and counter_sheet_to_pe=0) else
	r1_out(63-10 downto 0) & r1_out(63 downto 64-10) when (counter_plane_to_pe=2 and counter_sheet_to_pe=1) else
	r1_out(63-43 downto 0) & r1_out(63 downto 64-43) when (counter_plane_to_pe=2 and counter_sheet_to_pe=2) else
	r1_out(63-25 downto 0) & r1_out(63 downto 64-25) when (counter_plane_to_pe=2 and counter_sheet_to_pe=3) else
	r1_out(63-39 downto 0) & r1_out(63 downto 64-39) when (counter_plane_to_pe=2 and counter_sheet_to_pe=4) else
	
	r1_out(63-41 downto 0) & r1_out(63 downto 64-41) when (counter_plane_to_pe=3 and counter_sheet_to_pe=0) else
	r1_out(63-45 downto 0) & r1_out(63 downto 64-45) when (counter_plane_to_pe=3 and counter_sheet_to_pe=1) else
	r1_out(63-15 downto 0) & r1_out(63 downto 64-15) when (counter_plane_to_pe=3 and counter_sheet_to_pe=2) else
	r1_out(63-21 downto 0) & r1_out(63 downto 64-21) when (counter_plane_to_pe=3 and counter_sheet_to_pe=3) else
	r1_out(63-8 downto 0) & r1_out(63 downto 64-8) when (counter_plane_to_pe=3 and counter_sheet_to_pe=4) else
	
	r1_out(63-18 downto 0) & r1_out(63 downto 64-18) when (counter_plane_to_pe=4 and counter_sheet_to_pe=0) else
	r1_out(63-2 downto 0) & r1_out(63 downto 64-2) when (counter_plane_to_pe=4 and counter_sheet_to_pe=1) else
	r1_out(63-61 downto 0) & r1_out(63 downto 64-61) when (counter_plane_to_pe=4 and counter_sheet_to_pe=2) else
	r1_out(63-56 downto 0) & r1_out(63 downto 64-56) when (counter_plane_to_pe=4 and counter_sheet_to_pe=3) else
	r1_out(63-14 downto 0) & r1_out(63 downto 64-14) when (counter_plane_to_pe=4 and counter_sheet_to_pe=4) else
	
	r1_out;

iota <=    X"0000000000000001" when nr_round=0  else
		X"0000000000008082" when nr_round=1 else
		X"800000000000808A" when nr_round=2 else
		X"8000000080008000" when nr_round=3 else
		X"000000000000808B" when nr_round=4 else
		X"0000000080000001" when nr_round=5 else
		X"8000000080008081" when nr_round=6 else
		X"8000000000008009" when nr_round=7 else
		X"000000000000008A" when nr_round=8 else
		X"0000000000000088" when nr_round=9 else
		X"0000000080008009" when nr_round=10 else
		X"000000008000000A" when nr_round=11 else
		X"000000008000808B" when nr_round=12 else
		X"800000000000008B" when nr_round=13 else
		X"8000000000008089" when nr_round=14 else
		X"8000000000008003" when nr_round=15 else
		X"8000000000008002" when nr_round=16 else
		X"8000000000000080" when nr_round=17 else
		X"000000000000800A" when nr_round=18 else
		X"800000008000000A" when nr_round=19 else
		X"8000000080008081" when nr_round=20 else
		X"8000000000008080" when nr_round=21 else
		X"0000000080000001" when nr_round=22 else
		X"8000000080008008" when nr_round=23 else
		X"0000000000000000";
end rtl;
