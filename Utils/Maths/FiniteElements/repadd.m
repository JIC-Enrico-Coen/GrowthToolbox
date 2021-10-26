function vv = repadd( v, m )
%vv = repadd( v, m )
%   Add every element of the vector v to the whole matrix m, and abut the
%   resulting matrices along the first index.  If v has length V and M has
%   size [P,Q], then the result has size [V*P,Q].

    vv = reshape( repmat( v(:)', numel(m), 1 ) ...
                  + repmat( reshape( m', [], 1 ), 1, numel(v) ), ...
                  size(m,2), ...
                  [] )';
end
