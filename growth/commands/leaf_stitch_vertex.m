function m = leaf_stitch_vertex( m, varargin )
%m = leaf_stitch_vertex( m, dfs )
%   Constrain sets of vertexes of the mesh so that they move identically.
%
%   Arguments:
%       dfs: a cell array of vectors of degree of freedom indexes.  Dfs in
%            the same vector will be constrained to change identically.
%            No index may occur more than once anywhere in dfs.
%
%   Equivalent GUI operation: none.
%
%   Topics: Mesh editing, Simulation.

    if isempty(m), return; end
    [ok, dfs, args] = getTypedArg( mfilename(), 'cell', varargin, [] );
    if ~ok, return; end
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', ...
            mfilename, length(args) );
    end
    if isempty(dfs), return; end
    
    % Check that dfs contains no repetitions.
    m.globalDynamicProps.stitchDFs = dfs;
end
