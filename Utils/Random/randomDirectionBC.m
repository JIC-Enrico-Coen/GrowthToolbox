function dirbc = randomDirectionBC( n )
%dirbc = randomDirectionBC( n )
%   Generate n random directional barycentric coordinates.

    dirbc = randn(n,3);
    dirbc = dirbc - repmat( mean(dirbc,2), 1, size(dirbc,2) );
    dirbc = dirbc ./ repmat( sqrt(sum(dirbc.^2,2)), 1, size(dirbc,2) );
end

