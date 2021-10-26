function vs = vecsums( v )
%vs = vecsums( v )
%   Set vs(i) to the sum of v(1:i) for all i.

    vs = zeros(size(v));
    total = 0;
    for i=1:length(v)
        total = total + v(i);
        vs(i) = total;
    end
end
