function p = allProds( x, y, z )
    if nargin==2
        p = repmat( reshape(x,[],1), 1, numel(y) ) ...
            .* repmat( reshape(y,1,[]), numel(x), 1 );
    else
        p = repmat( reshape(x,[],1,1), [1, numel(y), numel(z)] ) ...
            .* repmat( reshape(y,1,[],1), [numel(x), 1, numel(z)] ) ...
            .* repmat( reshape(z,1,1,[]), [numel(x), numel(y), 1] );
    end
end
