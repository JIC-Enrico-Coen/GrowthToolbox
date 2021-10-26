function m = addall( v, w )
% Add every element of vector v to every element of vector w, giving a
% matrix of size [numel(v),numel(w)].  v and w can have any shape; both
% will be reshaped to vectors.

    m = repmat( v(:), 1, numel(w) ) + repmat( w(:)', numel(v), 1 );
end
