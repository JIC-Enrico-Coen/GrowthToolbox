function n = getNumberOfVolEdges( m )
%n = getNumberOfVolEdges( m )
%   Return the number of edges.
%   m can be either a GFtbox mesh or a volcells structure.

    if hasVolumetricCells( m )
        n = size( m.volcells.edgevxs, 1 );
    elseif isVolumetricCells( m )
        n = size( m.edgevxs, 1 );
    else
        n = 0;
    end
end