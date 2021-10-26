function g = tensorVector( t, v )
%g = tensorVector( t, v )
%   Given a growth tensor t in 2 or 3 dimensions, and a column vector v,
%   compute the growth in direction v (scaled as |v| squared),
%   i.e. g = v' t v.
%   t is assumed given in 3-vector format for 2 dimensions, or 6-vector
%   format for 3 dimensions.

    if length(t)==6
        tm = [ t(1), t(6), t(5);
               t(6), t(2), t(4);
               t(5), t(4), t(3) ];
    else
        tm = [ t(1), t(3);
               t(3), t(2) ];
    end
    g = v'*tm*v;
end
