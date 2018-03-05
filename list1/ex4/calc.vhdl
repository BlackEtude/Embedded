entity calc is
	port (a, b, c : in bit; x, y : out bit);
end calc;

architecture rtl of calc is
	signal u1 : bit;
	signal u2 : bit;
	signal u3 : bit;

	begin
	u1 <= a or b;
	u2 <= b nor c;
	u3 <= a xor c;
	x <= (not u1) nor (not u2);
	y <= (not u2) and (not u3);
end rtl;