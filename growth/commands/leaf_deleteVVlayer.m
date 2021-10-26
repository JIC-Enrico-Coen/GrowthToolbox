function m = leaf_deleteVVlayer( m )
%m = leaf_deleteVVlayer( m, ... )
%   Delete the VV layer, if any.
%
%   Topics: VV layer.

    if isfield( m.secondlayer, 'vvlayer' )
        m.secondlayer = rmfield( m.secondlayer, 'vvlayer' );
    end
end