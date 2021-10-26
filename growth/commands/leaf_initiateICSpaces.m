function m = leaf_initiateICSpaces( m, varargin )
%m = leaf_initiateICSpaces( m, ... )
%   Create intercellular spaces at some of the vertexes of the bio layer.
%   If m has no bio layer, nothing happens.  A vertex will be considered
%   eligible for splitting if all of the following hold:
%
%   1.  3 or more cells meet there.
%   2.  The vertex is not on the edge of the second layer, or bordering an
%       interior space.
%   3.  If specified, the distribution (see below) is positive at the
%       vertex.
%
%   Options:
%
%   'number'    How many vertexes to make spaces at.  The default is none.
%               If the value exceeds the number of eligible vertexes, then
%               all eligible vertexes will be chosen. 'number' can also be
%               the string 'all', in which case all eligible vertexes are
%               split.
%
%   'distribution'  How to choose the vertexes.  This is a vector
%               specifying a value per vertex of the bio layer.
%               Alternatively, it can be a morphogen, or a vector
%               specifying one value per vertex of the finite element
%               layer. In this case the value is interpolated to obtain a
%               value for each vertex of the bio layer.  The use of this
%               value in selecting vertexes is determined by the 'mode'
%               option.
%
%   'mode'      This is either 'random' (the default) or 'ordered'.  If
%               'random', the value of 'distribution' will be interpreted
%               as the relative probability of selecting each vertex.
%               (Negative values are interpreted as zero.)  If 'ordered',
%               vertexes will be chosen in descending order of the values
%               in 'distribution'.  In both modes, vertexes for which
%               'distribution' is not positive will never be selected. If
%               'distribution' is not specified, vertexes are chosen
%               uniformly at random.
%
%   'abssize'   A measure of the size of the spaces to be created. When a
%               a space is created at a vertex, a new vertex is created on
%               every edge incident on the given vertex.  The new vertexes
%               are joined in a cycle and the original vertex disappears.
%               The distance between each new vertex and the original
%               vertex is the value of the 'size' option.  This is an
%               absolute measure.
%
%   'relsize'   Another measure of the size of the spaces to be created.
%               This expresses the distance between new vertexes and the
%               old vertex as a fraction of the average length of all edges
%               in the bio layer.  The default is to have no value for
%               abssize, and relsize=0.05.  If both abssize and relsize are
%               specified, abssize is used.
%
%   Example:
%       m = leaf_initiateICSpaces( m, ...
%               'number', 10, ...
%               'distribution', 'S_SEPARATION', ...
%               'relsize', 0.05 );
%
%   Equivalent GUI operation: None.
%
%   See also: leaf_initiateICSpaces
%
%   Topics: Bio layer.

    if isempty( m.secondlayer.cells )
        return;
    end

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'number', [], 'distribution', [], 'mode', 'random', 'abssize', [], 'relsize', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'number', 'distribution', 'mode', 'abssize', 'relsize' );
    if ~ok, return; end
    
    if strcmp( s.number, 'all' )
        s.number = length( m.secondlayer.vxFEMcell );
    end
    
    if s.number <= 0
        return;
    end

    if isempty( s.abssize )
        if isempty( s.relsize )
            s.relsize = 0.05;
        end
        vxedges = m.secondlayer.edges(:,[1 2]);
        vxedgepos = reshape( m.secondlayer.cell3dcoords( vxedges', : ), 2, [], 3 );
        vxedgevec = squeeze( vxedgepos(2,:,:) - vxedgepos(1,:,:) );
        edgedist = sqrt( sum( vxedgevec.^2, 2 ) );
        s.abssize = s.relsize * sum(edgedist) / length(edgedist);
    else
        s.relsize = 0;
    end
    
    if s.abssize <= 0
        return;
    end

    if ischar( s.distribution )
        mgenIndex = FindMorphogenIndex( m, s.distribution );
        if mgenIndex==0
            fprintf( 1, '**** %s: distribution morphogen ''%s'' does not exist.\n', mfilename(), s.distribution );
            return;
        end
        s.distribution = mgenPerCellVertex( m, s.distribution, cvxs );
    elseif ~isempty(s.distribution) && (length(s.distribution) ~= length(m.secondlayer.vxFEMcell))
        if length(s.distribution) == size(m.nodes,1)
            s.distribution = mgenPerCellVertex( m, s.distribution, cvxs );
        else
            fprintf( 1, '**** %s: distribution has %d elements, %d or %d expected.\n', ...
                mfilename(), length(s.distribution), length(m.secondlayer.vxFEMcell), size(m.nodes,1) );
            return;
        end
    end
    s.distribution = max( s.distribution, 0 );
    
    exterioredges = any( m.secondlayer.edges(:,[3 4]) <= 0, 2 );
    okvertmap = bioVertexArity( m.secondlayer ) >= 3;
    okvertmap( m.secondlayer.edges( exterioredges, [1 2]) ) = false;
    if ~isempty( s.distribution )
        okvertmap = okvertmap & (s.distribution > 0);
        s.distribution = s.distribution( okvertmap );
    end
    okverts = find( okvertmap );
    if isempty( s.distribution )
        s.distribution = ones(1,length(okverts));
    end
    
    if isempty(s.number) || (s.number >= length(okverts))
        % Select all vertexes
        vxs = okverts;
    elseif strcmp( s.mode, 'ordered' )
        % Top down.
        [~,perm] = sort( s.distribution, 'descending' );
        vxs = perm(1:s.number);
    else
        % Random sample.
        vxs = randSampleNoReplace( length(okverts), s.number, s.distribution );
        vxs = okverts(vxs);
    end
    
    m = makeSpaceAtBioVertexes( m, vxs, s.abssize, m.globalProps.bioMinEdgeLength, m.globalProps.bioSpacePullInRatio );
end
