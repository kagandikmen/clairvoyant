-- Super-resolution Unit (SRU) of clairvoyant
-- Created: 2024-08-15
-- Modified: 2024-09-01 (status: tested, working)
-- Author: Kagan Dikmen (kagan.dikmen@tum.de)

-- Copyright (c) 2024 Kagan Dikmen
-- See LICENSE for details

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pp_types.all;
use work.pp_utilities.all;

entity cv_sru is
    port (
        clk_in          : in std_logic;
        reset_in        : in std_logic;
        first_word_in   : in std_logic_vector(31 downto 0);
        second_word_in  : in std_logic_vector(31 downto 0);
        funct3_in       : in std_logic_vector(2 downto 0);
        en_enh_in       : in std_logic;
        data_out        : out std_logic_vector(31 downto 0)
    );
end entity cv_sru;

architecture behaviour of cv_sru is
    type storage_row is array(0 to 7) of std_logic_vector(7 downto 0);
    type storage is array(0 to 1) of storage_row;
    signal storage_unit     : storage; -- := (others => (others => "00000000"));
    --type overlap_buffer is array(0 to 2) of std_logic_vector(7 downto 0);
    signal overlap_buf1      : std_logic_vector(7 downto 0);
    signal overlap_buf2      : std_logic_vector(7 downto 0);
    signal ctr               : unsigned(15 downto 0); -- := (others => '0');
begin
    process (clk_in)
        variable    tmp1,   tmp2,   tmp3,   tmp4,   tmp5,   tmp6,   tmp7,   tmp8, 
                    tmp9,   tmp10,  tmp11,  tmp12,  tmp13,  tmp14,  tmp15,  tmp16,
                    tmp17,  tmp18,  tmp19,  tmp20,  tmp21,  tmp22,  tmp23,  tmp24   : unsigned(15 downto 0);
    begin
        if rising_edge(clk_in) then
            if reset_in = '1' then
                storage_unit    <= (others => (others => "00000000"));
                overlap_buf1    <= (others => '0');
                overlap_buf2    <= (others => '0');
                ctr             <= (others => '0');
                
            elsif en_enh_in = '1' and funct3_in = "110" then    -- reset counter
                
                storage_unit <= storage_unit;
                overlap_buf1 <= overlap_buf1;
                overlap_buf2 <= overlap_buf2;
                ctr <= (others => '0');
                
            elsif en_enh_in = '1' and funct3_in = "111" then    -- enhance
                
                if ctr = 0 then
                    storage_unit(0)(0)  <= "00000000";
                else
                    tmp1                := ("00000000" & unsigned(overlap_buf1(7 downto 0))) + ( "00000000" & unsigned(first_word_in(7 downto 0)));
                    storage_unit(0)(0)  <= std_logic_vector(tmp1(8 downto 1));
                end if;
                
                storage_unit(0)(1)  <= first_word_in    (31 downto 24);
                
                tmp2                := ("00000000" & unsigned(first_word_in    (31 downto 24)))   + ("00000000" & unsigned(first_word_in    (23 downto 16)));
                storage_unit(0)(2)  <= std_logic_vector(tmp2(8 downto 1));
                
                storage_unit(0)(3)  <= first_word_in    (23 downto 16);
                
                tmp3                := ("00000000" & unsigned(first_word_in    (23 downto 16)))    + ("00000000" & unsigned(first_word_in    (15 downto 8)));
                storage_unit(0)(4)  <= std_logic_vector(tmp3(8 downto 1));
                
                storage_unit(0)(5)  <= first_word_in    (15 downto 8);
                
                tmp4                := ("00000000" & unsigned(first_word_in    (15 downto 8)))    + ("00000000" & unsigned(first_word_in    (7 downto 0)));
                storage_unit(0)(6)  <= std_logic_vector(tmp4(8 downto 1));
                
                storage_unit(0)(7)  <= first_word_in    (7 downto 0);
                
                if ctr = 0 then
                    storage_unit(1)(0) <= "00000000";
                else                
                    tmp5                := ("00000000" & unsigned(overlap_buf1(7 downto 0))) + ("00000000" & unsigned(overlap_buf2(7 downto 0)));
                    tmp6                := ("00000000" & unsigned(first_word_in    (7 downto 0))) + ("00000000" & unsigned(second_word_in    (7 downto 0)));
                    storage_unit(1)(0)  <= std_logic_vector(tmp5(9 downto 2) + tmp6(9 downto 2));   
                end if;
                
                tmp7                := ("00000000" & unsigned(first_word_in    (31 downto 24)))  + ("00000000" & unsigned(second_word_in    (31 downto 24)));
                storage_unit(1)(1)  <= std_logic_vector(tmp7(8 downto 1));
                
                tmp8                := ("00000000" & unsigned(first_word_in    (31 downto 24)))  + ("00000000" & unsigned(first_word_in     (23 downto 16)));
                tmp9                := ("00000000" & unsigned(second_word_in    (31 downto 24)))  + ("00000000" & unsigned(second_word_in    (23 downto 16)));
                storage_unit(1)(2)  <= std_logic_vector(tmp8(9 downto 2) + tmp9(9 downto 2));
                
                tmp10               := ("00000000" & unsigned(first_word_in    (23 downto 16)))  + ("00000000" & unsigned(second_word_in    (23 downto 16)));
                storage_unit(1)(3)  <= std_logic_vector(tmp10(8 downto 1));
                
                tmp11               := ("00000000" & unsigned(first_word_in    (23 downto 16)))  + ("00000000" & unsigned(first_word_in     (15 downto 8)));
                tmp12               := ("00000000" & unsigned(second_word_in    (23 downto 16)))  + ("00000000" & unsigned(second_word_in    (15 downto 8)));
                storage_unit(1)(4)  <= std_logic_vector(tmp11(9 downto 2) + tmp12(9 downto 2));
                
                tmp13               := ("00000000" & unsigned(first_word_in    (15 downto 8)))  + ("00000000" & unsigned(second_word_in    (15 downto 8)));
                storage_unit(1)(5)  <= std_logic_vector(tmp13(8 downto 1));
                
                tmp14               := ("00000000" & unsigned(first_word_in    (15 downto 8)))   + ("00000000" & unsigned(first_word_in     (7 downto 0)));
                tmp15               := ("00000000" & unsigned(second_word_in    (15 downto 8)))   + ("00000000" & unsigned(second_word_in    (7 downto 0)));
                storage_unit(1)(6)  <= std_logic_vector(tmp14(9 downto 2) + tmp15(9 downto 2));
                
                tmp16               := ("00000000" & unsigned(first_word_in    (7 downto 0)))    + ("00000000" & unsigned(second_word_in    (7 downto 0)));
                storage_unit(1)(7)  <= std_logic_vector(tmp16(8 downto 1));

                overlap_buf1      <= first_word_in  (31 downto 24);
                overlap_buf2      <= second_word_in (31 downto 24);

                ctr <= ctr + 1;
                
            else
                storage_unit <= storage_unit;
                overlap_buf1 <= overlap_buf1;
                overlap_buf2 <= overlap_buf2;
                ctr <= ctr;
            end if;
        end if;
    end process;

    process(funct3_in)  -- select between bytes to read from SRU buffer to the memory
    begin
        if funct3_in = "000" then
            data_out <= storage_unit(0)(5) & storage_unit(0)(6) & storage_unit(0)(7) & storage_unit(0)(0);
        elsif funct3_in = "001" then
            data_out <= storage_unit(0)(1) & storage_unit(0)(2) & storage_unit(0)(3) & storage_unit(0)(4);
        elsif funct3_in = "010" then
            data_out <= storage_unit(1)(5) & storage_unit(1)(6) & storage_unit(1)(7) & storage_unit(1)(0);
        elsif funct3_in = "011" then
            data_out <= storage_unit(1)(1) & storage_unit(1)(2) & storage_unit(1)(3) & storage_unit(1)(4);
        else
            data_out <= (others => '0');
        end if;
    end process;
    
end architecture behaviour;