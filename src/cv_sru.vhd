-- Super-resolution Unit (SRU) of clairvoyant
-- Created: 2024-08-15
-- Modified: 2024-08-17 (status: unknown)
-- Author: Kagan Dikmen (kagan.dikmen@tum.de)
-- Copyright (c) 2024, Kagan Dikmen

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;
use work.pp_utilities.all;

entity cv_sru is
    port (
        clk_in          : in std_logic;
        first_word_in   : in std_logic_vector(31 downto 0);
        second_word_in  : in std_logic_vector(31 downto 0);
        funct3_in       : in std_logic_vector(2 downto 0);

        data_out        : out std_logic_vector(31 downto 0)
    );
end entity cv_sru;

architecture behaviour of cv_sru is
    type storage_row is array(0 to 7) of std_logic_vector(7 downto 0);
    type storage is array(0 to 2) of storage_row;
    signal storage_unit     : storage := (others => (others => "00000000"));
    type overlap_buffer is array(0 to 2) of std_logic_vector(7 downto 0);
    signal overlap_buf      : overlap_buffer := (others => "00000000");
    signal ctr              : unsigned(2 downto 0) := "000";
    
    
begin
    process (clk_in)
        variable    tmp1,    tmp2,   tmp3,   tmp4,   tmp5,   tmp6,   tmp7,   tmp8, 
                    tmp9,    tmp10,  tmp11,  tmp12,  tmp13,  tmp14,  tmp15,  tmp16,
                    tmp17                                                                  : std_logic_vector(7 downto 0);
    begin
        if rising_edge(clk_in) then
            if funct3_in = "111" then --enhance
                
                if ctr = "000" then
                    storage_unit(0)(0) <= "00000000";
                else
                    tmp1 := std_logic_vector(unsigned(overlap_buf(0)) + unsigned(first_word_in    (31 downto 24)));
                    storage_unit(0)(0) <= "0" & tmp1(7 downto 1);
                end if;
                storage_unit(0)(1)  <= first_word_in    (31 downto 24);
                tmp2 := std_logic_vector(unsigned(first_word_in    (31 downto 24))    + unsigned(first_word_in    (23 downto 16)));
                storage_unit(0)(2)  <= "0" & tmp2(7 downto 1);
                storage_unit(0)(3)  <= first_word_in    (23 downto 16);
                tmp3 := std_logic_vector(unsigned(first_word_in    (23 downto 16))    + unsigned(first_word_in    (15 downto 8)));
                storage_unit(0)(4)  <= "0" & tmp3(7 downto 1);
                storage_unit(0)(5)  <= first_word_in    (15 downto 8);
                tmp4 := std_logic_vector(unsigned(first_word_in    (15 downto 8))     + unsigned(first_word_in    (7 downto 0)));
                storage_unit(0)(6)  <= "0" & tmp4(7 downto 1);
                storage_unit(0)(7)  <= first_word_in    (7 downto 0);
                
                if ctr = "000" then
                    storage_unit(1)(0) <= "00000000";
                else
                    tmp5 := std_logic_vector(unsigned(overlap_buf(1)) + unsigned(first_word_in    (31 downto 25)) + unsigned(second_word_in    (31 downto 25)));
                    storage_unit(1)(0) <= "0" & tmp5(7 downto 1);
                end if;
                tmp6 := std_logic_vector(unsigned(first_word_in    (31 downto 24))  + unsigned(second_word_in    (31 downto 24)));
                storage_unit(1)(1)  <= "0"   & tmp6(7 downto 1);
                tmp7 := std_logic_vector(unsigned(first_word_in    (31 downto 24))  + unsigned(first_word_in     (23 downto 16))   + unsigned(second_word_in    (31 downto 24))  + unsigned(second_word_in    (23 downto 16)));
                storage_unit(1)(2)  <= "00"  & tmp7(7 downto 2);
                tmp8 := std_logic_vector(unsigned(first_word_in    (23 downto 16))  + unsigned(second_word_in    (23 downto 16)));
                storage_unit(1)(3)  <= "0"   & tmp8(7 downto 1);
                tmp9 := std_logic_vector(unsigned(first_word_in    (23 downto 16))  + unsigned(first_word_in     (15 downto 8))    + unsigned(second_word_in    (23 downto 16))  + unsigned(second_word_in    (15 downto 8)));
                storage_unit(1)(4)  <= "00"  & tmp9(7 downto 2);
                tmp10 := std_logic_vector(unsigned(first_word_in    (15 downto 8))   + unsigned(second_word_in    (15 downto 8)));
                storage_unit(1)(5)  <= "0"   & tmp10(7 downto 1);
                tmp11 := std_logic_vector(unsigned(first_word_in    (15 downto 8))   + unsigned(first_word_in     (7 downto 0))     + unsigned(second_word_in    (15 downto 8))   + unsigned(second_word_in    (7 downto 0)));
                storage_unit(1)(6)  <= "00"  & tmp11(7 downto 2);
                tmp12 := std_logic_vector(unsigned(first_word_in    (7 downto 0))    + unsigned(second_word_in    (7 downto 0)));
                storage_unit(1)(7)  <= "0"   & tmp12(7 downto 1);
                
                if ctr = "000" then
                    storage_unit(2)(0) <= "00000000";
                else
                    tmp13 := std_logic_vector(unsigned(overlap_buf(2))   + unsigned(second_word_in    (31 downto 24)));
                    storage_unit(2)(0) <= "0" & tmp13(7 downto 1);
                end if;
                storage_unit(2)(1)  <= second_word_in    (31 downto 24);
                tmp14 := std_logic_vector(unsigned(second_word_in    (31 downto 24))   + unsigned(second_word_in    (23 downto 16)));
                storage_unit(2)(2)  <= "0" & tmp14(7 downto 1);
                storage_unit(2)(3)  <= second_word_in    (23 downto 16);
                tmp15 := std_logic_vector(unsigned(second_word_in    (23 downto 16))   + unsigned(second_word_in    (15 downto 8)));
                storage_unit(2)(4)  <= "0" & tmp15(7 downto 1);
                storage_unit(2)(5)  <= second_word_in    (15 downto 8);
                tmp16 := std_logic_vector(unsigned(second_word_in    (15 downto 8))    + unsigned(second_word_in    (7 downto 0)));
                storage_unit(2)(6)  <= "0" & tmp16(7 downto 1);
                storage_unit(2)(7)  <= second_word_in    (7 downto 0);

                overlap_buf(0)      <= first_word_in (7 downto 0);
                tmp17 := std_logic_vector(unsigned(first_word_in     (7 downto 0))     + unsigned(second_word_in    (7 downto 0)));
                overlap_buf(1)      <= "0" & tmp17(7 downto 1);
                overlap_buf(2)      <= second_word_in (7 downto 0);

                ctr <= ctr + 1;
            
            else
                storage_unit <= storage_unit;
                overlap_buf <= overlap_buf;
                ctr <= ctr;
            end if;
        end if;
    end process;

    process(funct3_in)  -- select between bytes to read from SRU buffer to the memory
    begin
        if funct3_in = "000" then
            data_out <= storage_unit(0)(0) & storage_unit(0)(1) & storage_unit(0)(2) & storage_unit(0)(3);
        elsif funct3_in = "001" then
            data_out <= storage_unit(0)(4) & storage_unit(0)(5) & storage_unit(0)(6) & storage_unit(0)(7);
        elsif funct3_in = "010" then
            data_out <= storage_unit(1)(0) & storage_unit(1)(1) & storage_unit(1)(2) & storage_unit(1)(3);
        elsif funct3_in = "011" then
            data_out <= storage_unit(1)(4) & storage_unit(1)(5) & storage_unit(1)(6) & storage_unit(1)(7);
        else
            data_out <= (others => '0');
        end if;
    end process;
    
end architecture behaviour;