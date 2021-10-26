function m = leaf_fix_vertex( m, varargin )
%m = leaf_fix_vertex( m, ... )
%   Constrain vertexes of the mesh so that they are only free to move along
%   certain axes; or remove such constraints.
%
%   Options:
%       'vertex'    The vertexes to be constrained or unconstrained.  This
%                   argument is required.  It can be either a boolean map
%                   of all the vertexes, a list of vertex indexes, or the
%                   string 'all' or 'none'.
%
%                   For a new-style mesh these are indexes into
%                   m.FEnodes.  For an old-style mesh, they are indexes
%                   into m.nodes, which are interpreted as fixing the
%                   vertexes in m.prismnodes on both the A and B sides.
%                   Vertexes not specified by 'vertex' will have their
%                   constraints unchanged.
%
%                   Older versions (up to version 5454, 2016-08-30 15:40)
%                   interpreted the empty array as meaning all vertexes.
%                   This has been changed.  The empty array now means no
%                   vertexes.  To easily specify all vertexes, use the
%                   string 'all'.
%
%       'dfs'       The degrees of freedom to be constrained.  This can be
%                   either a subset of 'xyz,  or a string consisting of
%                   substrings each beginning with '+' or '-' followed by a
%                   subset of 'xyz'.  In the first case the specifed
%                   degrees of freedom are made fixed and all others made
%                   free.  In the second case the degrees of freedom
%                   following a '+' are made fixed, those following a '-'
%                   are made free, and those not mentioned anywhere have
%                   their status left unchanged.  For example, '+x-y' will
%                   cause the specified vertexes  to be fixed in the x
%                   direction and free in the y direction, and their
%                   freedom in the z direction will be unchanged.
%
%                   If dfs is the empty string, this means to remove all
%                   constraints, i.e. the same as '-xyz'.
%
%       'side'      This applies only to old-style meshes.  By default,
%                   corresponding vertexes on the A and B sides are
%                   constrained together.  If 'side' is 'A' or 'B', the
%                   specified vertexes are constrained only on the A or B
%                   side respectively.  If you want to specify some
%                   constraints on the A side and some on the B side, use
%                   two calls of leaf_fix_vertex.
%
%   To remove all constraints from all vertexes, do this:
%
%       m = leaf_fix_vertex( m, 'vertex', 'all', 'dfs', '' );
%
%   It is only possible to constrain vertexes in directions parallel to the
%   axes.
%
%   Invalid vertex indexes will be detected, warned about, and ignored.
%   Invalid characters in the 'dfs' string will be ignored.
%
%   Equivalent GUI operation: clicking on the mesh while the Mesh editor
%   panel is selected and 'Fix' is selected in the mouse-mode menu.  The
%   'x', 'y', and 'z' checkboxes specify which degrees of freedom to
%   constrain or unconstrain.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'dfs', 'xyz', 'side', '' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'vertex', 'dfs', 'side' );
    if ~ok, return; end
    
    if isempty( s.vertex )
        % WARNING: an older version interpreted this as meaning all
        % vertexes.  This now means no vertexes.
        rev = GFtboxRevision();
        if rev >= 5454
            warning( [ '%s: Supplying the empty array as the ''vertex'' argument previously ' ...
                       'meant all vertexes. This ', ...
                       'behaviour has been changed from version 5455 onwards.  The empty array ', ...
                       'now means the empty set of vertexes.  To easily specify all vertexes, use ''all''', ...
                       ' as the ''vertex'' argument.' ], ...
                mfilename() );
        end
    end
    
    numnodes = getNumberOfVertexes( m );
    if strcmp( s.vertex, 'all' )
        s.vertex = 1:numnodes;
    elseif islogical( s.vertex )
        s.vertex = find( s.vertex );
    end
    
    [fixdfbits,freedfbits] = convertXYZtoDFs( s.dfs );
    if any( s.vertex < 1 )
        beep;
        fprintf( 1, '** %s: invalid vertex indexes < 1 found:', mfilename() );
        fprintf( 1, ' %d', s.vertex(s.vertex < 1) );
        fprintf( 1, '\n    Invalid values ignored.\n' );
        s.vertex = s.vertex(s.vertex >= 1);
    end
    if any( s.vertex > numnodes )
        beep;
        fprintf( 1, '** %s: some vertex indexes exceed the number of nodes (%d):', ...
            mfilename(), numnodes );
        fprintf( 1, ' %d', s.vertex( s.vertex > numnodes ) );
        fprintf( 1, '\n    Invalid values ignored.\n' );
        s.vertex = s.vertex( s.vertex <= numnodes );
    end
    if isVolumetricMesh( m )
        for i=1:3
            m.fixedDFmap(s.vertex,fixdfbits) = true;
            m.fixedDFmap(s.vertex,freedfbits) = false;
        end
    else
        vxsB = 2*s.vertex(:)';
        vxsA = vxsB-1;
        switch upper( s.side )
            case 'A'
                m.fixedDFmap(vxsA,fixdfbits) = true;
                m.fixedDFmap(vxsA,freedfbits) = false;
            case 'B'
                m.fixedDFmap(vxsB,fixdfbits) = true;
                m.fixedDFmap(vxsB,freedfbits) = false;
            otherwise
                m.fixedDFmap(vxsA,fixdfbits) = true;
                m.fixedDFmap(vxsA,freedfbits) = false;
                m.fixedDFmap(vxsB,fixdfbits) = true;
                m.fixedDFmap(vxsB,freedfbits) = false;
        end
    end
end
