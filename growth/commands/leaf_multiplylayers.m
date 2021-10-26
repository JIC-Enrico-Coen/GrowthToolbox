function [m,ok] = leaf_multiplylayers( m, varargin )
%[m,ok] = leaf_multiplylayers( m, varargin )
%   Replace a single-layer mesh by a mesh of multiple layers glued together.
%   This should not be called if the mesh is already a multiple-layer mesh,
%   or already contains any vertexes that are stitched together.
%
%   Options:
%
%   layers: The number of layers to make.  The default value is 2.
%
%   force: Normally this procedure will not act on a mesh that already
%       contains constraints that force some nodes to have equal
%       displacements.  If 'force' is true then any such constraints will
%       be deleted and the mesh will be multiplied.  The default is false.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'layers', 2, 'force', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'layers', 'force' );
    if ~ok, return; end
    
    if ~isempty( m.globalDynamicProps.stitchDFs )
        if ~s.force
            ok = false;
            fprintf( 1, '%s: The mesh already has some nodes stitched together -- cannot multiply layers.\n', ...
                mfilename() );
            return;
        end
        m.globalDynamicProps.stitchDFs = [];
    end

    m = multiplyLayers( m, s.layers );
end
