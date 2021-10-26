function m = convertToNewFEMesh( m )
%m = convertToNewFEMesh( m )
%   UNTESTED, UNUSED
%   Convert an old-style mesh to new-style. The new-style mesh uses P6 and
%   T3 elements, not T4s.

    if ~isempty( m.FEsets )
        return;
    end
    
    m.FEsets(1).fe = FiniteElementType.MakeFEType( 'P6' );
    p6vxs = m.tricellvxs' * 2;
    p6vxs = [ p6vxs-1; p6vxs ];
    m.FEsets(1).fevxs = p6vxs';
    m.FEsets(2).fe = FiniteElementType.MakeFEType( 'T3' );
    m.FEsets(2).fevxs = m.tricellvxs;
    m.FEnodes = m.prismnodes;
    m = rmfield( m, {'nodes', 'prismnodes'} );
end
