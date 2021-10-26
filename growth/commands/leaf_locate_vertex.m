function m = leaf_locate_vertex( m, varargin )
%m = leaf_locate_vertex( m, ... )
%   Ensure that certain degrees of freedom of a single node remain
%   constant.  This is ensured by translating the mesh so as to restore the
%   values of the specified coordinates, after each iteration.  Only a
%   single node can be constrained by this procedure.  To fix multiple
%   nodes, use leaf_fix_vertex.  Where the intention is simply to define a
%   point on the mesh as an unmoving reference point (e.g. the base of a
%   leaf), this procedure may give more accurate results than using
%   leaf_fix_vertex to fix a single node.
%
%   Options:
%
%       'vertex'    The vertex to be held stationary.  If the empty list is
%                   supplied, no vertex will be fixed and dfs is ignored.
%
%       'dfs'       A specification of which degrees of freedom are to be
%                   stationary and which unnconstrained. The syntax is the
%                   same as for leaf_fix_vertex.
%
%   It is only possible to fix a vertex in directions parallel to the
%   axes.
%
%   Equivalent GUI operation: clicking on the mesh while the Mesh editor
%   panel is selected and 'Locate' is selected in the Fix/Delete menu.  The
%   'x', 'y', and 'z' checkboxes specify which degrees of freedom to
%   constrain or unconstrain.
%
%   leaf_locate_vertex operates independently of leaf_fix_vertex.  The
%   growth of the mesh is calculated taking into account the constraints
%   imposed by leaf_fix_vertex.  Then the entire mesh (regardless of those
%   constraints) is rigidly translated so as to restore the position of the
%   vertex specified by leaf_locate_vertex.
%
%   See also: leaf_fix_vertex.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'dfs', 'xyz' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'vertex', 'dfs' );
    if ~ok, return; end
    if ~isempty( s.vertex )
        vx = s.vertex(1);
        if (vx < 1) || (vx > size(m.nodes,1))
            complain( mfilename(), 'Invalid vertex %d. Command ignored.' );
            return;
        end
    end
    if numel(s.vertex) > 1
        fprintf( 1, '%s: %d nodes supplied, only the first, %d, used.\n', ...
            mfilename(), numel(s.vertex), vx );
    end
    
    [fixdfbits,freedfbits] = convertXYZtoDFs( s.dfs );
    if isempty( s.vertex )
        m.globalDynamicProps.locatenode = 0;
        m.globalDynamicProps.locateDFs = [0 0 0];
    else
        m.globalDynamicProps.locatenode = vx;
        m.globalDynamicProps.locateDFs(fixdfbits) = true;
        m.globalDynamicProps.locateDFs(freedfbits) = false;
    end
end
