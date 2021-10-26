function tv = transportvectors( m, mi )
%tv = transportvectors( m, mi )
%   Calculate the global transport field for morphogen mi, from the local
%   transport field stored in m.transportfield{mi}.

    if isempty( m.transportfield{mi} )
        tv = [];
        return;
    end
    if all( m.transportfield{mi}(:)==0 )
        tv = [];
        return;
    end
    tv = repmat( reshape( m.transportfield{mi}', [], 1 ), 1, 3 ) ...
            .* m.nodes(m.tricellvxs',:);
    tv = reshape( tv, 3, [], 3 );
    tv = sum( tv, 1 );
    tv = permute( tv, [2 3 1] );
end
