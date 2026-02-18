function [m,splitdata] = leaf_subdivide( m, varargin )
%m = leaf_subdivide( m, ... )
%   Subdivide every edge of m where a specified morphogen is above and/or below
%   thresholds, and the length of the current edge is at least a certain
%   value.
%
%   This is not supported for full 3D meshes, for which it does nothing.
%
%   Note that this command will subdivide every eligible edge every time it
%   is called.  It does not remember which edges it has subdivided before
%   and refrain from subdividing them again.
%
%   Options:
%       'morphogen': The name or index of the morphogen. Alternatively,
%                    a value per vertex can be given.
%       'min':       The value that the morphogen must be at least equal to.
%       'max':       The value that the morphogen must not exceed.
%       'mode':      'all' [default], 'any', or 'mid'.
%       'minabslength': A real number. No edge shorter than this will be
%                    subdivided.
%       'minrellength': A real number. This is a fraction of the current
%                    threshold for automatic splitting of edges.  No edge
%                    shorter than this will be subdivided.  The current
%                    threshold value is returned by
%                    currentEdgeThreshold(m).
%       'edges':     A list of edge indexes or a boolean map of the edges.
%                    Only edges in this set will be split.
%       'levels':    Obsolete. This option will be ignored, and is only
%                    recognised for backward compatibility.
%       'force':     If true (the default), all of the requested
%                    subdivisions will happen.  If false, edges will not be
%                    split where this would result in excessively small
%                    cells or cell angles.
%       'direction': If present, a vector specifying that only edges within
%                    a certain angle of that direction are to be
%                    subdivided. By default there is no such constraint.
%       'angle':     The maximum angle to the given direction of edges to
%                    be split.
%
%   An edge will be subdivided if and only if it satisfies all of the
%   conditions that are specified.  Any combination of the arguments can be
%   given.  If no conditions are specified, no subdivision is done.
%
%   'mode' is only relevant if 'min' or 'max' has been specified.
%   If mode is 'all', then each edge is split for which both ends satisfy
%   the min/max conditions.
%   If mode is 'any', each edge is split for which either end
%   satisfies the conditions.
%   If mode if 'mid', each edge is split for which the average of the
%   morphogen values at its ends satisfies the conditions.
%
%   This command ignores the setting, that can be set through the GUI or
%   leaf_setproperty(), that enables or disables automatic splitting of
%   long edges.
%
%   Topics: Mesh editing.

    splitdata = [];
    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
            'levels', [], ...
            'mode', 'all', ...
            'force', true );
    ok = checkcommandargs( mfilename(), s, 'only', ...
            'edges', ...
            'levels', ...
            'morphogen', ...
            'min', ...
            'max', ...
            'mode', ...
            'minabslength', ...
            'minrellength', ...
            'force', ...
            'direction', ...
            'angle' );
    if ~ok, return; end
    
    full3d = usesNewFEs( m );
    if full3d
        % This functionality is not supported for full 3d meshes.
%         return;
    end
    
    mgenValues = [];
    
    if isfield( s, 'morphogen' )
        if numel( s.morphogen ) == getNumberOfVertexes(m)
            mgenValues = s.morphogen;
        else
            mgenIndex = FindMorphogenIndex( m, s.morphogen, mfilename() );
            if isempty(mgenIndex)
                % FindMorphogenIndex has already complained.
                return;
            end
            if numel(mgenIndex) > 1
                fprintf( 1, 'Only a single morphogen can be specified, found %d.\n', numel(mgenIndex) );
                return;
            end
            mgenValues = m.morphogens( :, mgenIndex );
        end
    end
    
    directionConstraint = isfield( s, 'direction' ) && isfield( s, 'angle' );
    
    dosplit = false;
    
    if isfield( s, 'edges' )
        dosplit = true;
        if islogical( s.edges )
            edgesToSplit = find( s.edges );
            splitmap = s.edges;
        else
            edgesToSplit = s.edges;
            splitmap = false( getNumberOfEdges(m), 1 );
            splitmap( edgesToSplit ) = true;
        end
    else
        edgesToSplit = 1:getNumberOfEdges(m);
        splitmap = true( getNumberOfEdges(m), 1 );
    end
    
    if full3d
        edgeends = m.FEconnectivity.edgeends;
        nodes = m.FEnodes;
    else
        edgeends = m.edgeends;
        nodes = m.nodes;
    end
        

    if ~isempty( mgenValues )
        dosplit = true;
        mgenEdgeLevels = reshape( mgenValues( edgeends ), size(edgeends) );
        switch s.mode
            case 'all'
                if isfield( s, 'min' )
                    splitmap = splitmap & all( mgenEdgeLevels >= s.min, 2 );
                end
                if isfield( s, 'max' )
                    splitmap = splitmap & all( mgenEdgeLevels  <= s.max, 2 );
                end
                edgesToSplit = find(splitmap );
            case 'any'
                if isfield( s, 'min' )
                    splitmap = splitmap & any( mgenEdgeLevels >= s.min, 2 );
                end
                if isfield( s, 'max' )
                    splitmap = splitmap & any( mgenEdgeLevels  <= s.max, 2 );
                end
                edgesToSplit = find( splitmap );
            case 'mid'
                mgenEdgeLevels = sum(mgenEdgeLevels,2)/2;
                if isfield( s, 'min' )
                    splitmap = splitmap & (mgenEdgeLevels >= s.min);
                end
                if isfield( s, 'max' )
                    splitmap = splitmap & (mgenEdgeLevels  <= s.max);
                end
                edgesToSplit = find( splitmap );

            otherwise
                fprintf( 1, '%s: Option ''mode'' has invalid value ''%s''.\n', ...
                    mfilename(), s.mode );
                fprintf( 1, '    Allowed values are ''min'', ''max'', or ''mid''.\n' );
                return;
        end
    end

    if isfield(s, 'minabslength') || isfield(s, 'minrellength') || directionConstraint
        dosplit = true;
        edgevecs = nodes( edgeends( edgesToSplit, 2 ), : ) ...
                   - nodes( edgeends( edgesToSplit, 1 ), : );
        edgelensqs = sum( edgevecs.*edgevecs, 2 );
        if isfield( s, 'minabslength' )
            subedgemap = edgelensqs >= s.minabslength*s.minabslength;
            edgesToSplit = edgesToSplit( subedgemap );
            edgelensqs = edgelensqs( subedgemap );
        end
        if isfield( s, 'minrellength' )
            splitthreshold = s.minrellength * currentEdgeThreshold( m );
            subedgemap = edgelensqs >= splitthreshold^2;
            edgesToSplit = edgesToSplit( subedgemap );
        end
        if directionConstraint
            angles = vecangle( edgevecs, s.direction );
            subedgemap = (pi/2 - abs(angles-pi/2)) < s.angle;
            edgesToSplit = edgesToSplit( subedgemap );
        end
    end
    
    if dosplit
        [m,splitdata] = splitalledges( m, edgesToSplit, s.force );
    end
end

