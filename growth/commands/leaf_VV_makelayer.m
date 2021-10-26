function m = leaf_VV_makelayer( m, varargin )
%m = leaf_VV_makelayer( m, ... )
%   Add a VV-style data structure to the mesh.  If the mesh already
%   contains a VV layer, it will be discarded.
%
%   The mesh must already contain a bio layer.  If it does not, this
%   procedure returns immediately.  A VV layer will be constructed in which
%   each VV cell lies exactly on top of a bio layer cell.
%
%   Options:
%   'edgedivisions' The number of segments, on average, that each segment
%                   of cell wall should be divided into.
%
%   Topics: VV layer.

    if isempty(m), return; end
    if ~hasNonemptySecondLayer(m), return; end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'edgedivisions', 4 );
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'edgedivisions' );
    if ~ok, return; end

    m = leaf_deleteVVlayer( m );
    vvxs = m.secondlayer.cell3dcoords;
    vcells = { m.secondlayer.cells.vxs };
    [m.secondlayer.vvlayer,ok] = vvFromCells( vvxs, vcells, s.edgedivisions );
    m.secondlayer.vvlayer.mainvxsbcs = m.secondlayer.vxBaryCoords;
    m.secondlayer.vvlayer.mainvxsFEM = m.secondlayer.vxFEMcell;
    if ~ok
        fprintf( 1, '%s: invalid mesh.\n', mfilename );
        return;
    end
end
