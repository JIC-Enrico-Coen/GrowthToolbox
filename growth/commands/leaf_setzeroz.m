function m = leaf_setzeroz( m, varargin )
%m = leaf_setzeroz( m )
%   Set the Z displacement of every node to zero, along whatever  axis (x,
%   y, or z) the mesh is flattest in.
%
%   Valid for foliate meshes only.
%
%   Equivalent GUI operation: the "Zero Z" button on the "Mesh editor"
%   panel.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    if isVolumetricMesh( m ), return; end
    if ~isempty( varargin )
        fprintf( 1, '%s: No arguments required, %d supplied.\n', ...
            mfilename(), length( varargin ) );
        return;
    end

    m = flattenMesh( m );
end

