function r = genrand( df, n )
%r = genrand( df, n )
%   df is a cumulative distribution function over its subscript range.
%   This function generates n random elements drawn from that distribution.
%   Where consecutive members of cumdist are equal, the last element of the
%   run will always be chosen.

    r = zeros(1,n);
    for i=1:n
        r(i) = binsearchupper( df, rand() );
    end
end
