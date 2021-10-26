function m = leaf_fliporientation( m, varargin )
%m = leaf_fliporientation( m )
%   Interchange the two surfaces of the mesh.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    if ~isempty(varargin)
        fprintf( 1, '%s: no arguments required, %d arguments ignored.\n', ...
            mfilename(), length(varargin) );
    end
    
    m = flipOrientation( m );
end
