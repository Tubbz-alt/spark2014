package body T2Q4
is

  procedure Clear (A: in out ArrayType; L,U: in IndexType)
  is
  begin
    for I in IndexType range L..U loop
      A(I) := 0;
      --# assert (for all N in IndexType range L..I => (A(N) = 0)) and
      --#        (for all N in IndexType => ((N<L or N>I) -> A(N) = A~(N))) and
      --#        U = U% and L <= I;
    end loop;
  end Clear;

end T2Q4;
