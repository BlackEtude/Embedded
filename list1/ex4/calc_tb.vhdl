entity calc_tb is
end calc_tb;

architecture behav of calc_tb is
   component calc
     port (a, b, c : in bit; x, y : out bit);
   end component;

   for calc_0: calc use entity work.calc;
   signal a, b, c, x, y : bit;
begin
   calc_0: calc port map (a => a, b => b, c => c, x => x, y => y);

   process
      type pattern_type is record
         a, b, c : bit;
         x, y : bit;
      end record;
      type pattern_array is array (natural range <>) of pattern_type;
      constant patterns : pattern_array :=
        (('0', '0', '0', '0', '0'),
         ('0', '0', '1', '0', '0'),
         ('0', '1', '0', '0', '1'),
         ('0', '1', '1', '0', '0'),
         ('1', '0', '0', '1', '0'),
         ('1', '0', '1', '0', '1'),
         ('1', '1', '0', '0', '0'),
         ('1', '1', '1', '0', '1'));
   begin
      for i in patterns'range loop
         a <= patterns(i).a;
         b <= patterns(i).b;
         c <= patterns(i).c;
         wait for 1 ns;
         assert x = patterns(i).x
            report "bad x value" severity error;
         assert y = patterns(i).y
            report "bad y value" severity error;
      end loop;
      assert false report "end of test" severity note;
      wait;
   end process;
end behav;