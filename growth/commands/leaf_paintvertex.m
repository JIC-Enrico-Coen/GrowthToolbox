function m = leaf_paintvertex( m, varargin )
%m = leaf_paintvertex( m, morphogen, ... )
%   Apply the given amount of the given morphogen to all of the given
%   vertexes.  The vertexes are identified numerically; the numbers are
%   not user-accessible.  This command is therefore not easily used
%   manually; it is generated when the user clicks on a vertex in the GUI.
%
%   Arguments:
%   1: The morphogen name or index.
%
%   Options:
%       'vertex'    The vertexes to apply morphogen to.
%   	'amount'    The amount of morphogen to apply.  This can be either a
%                   single value to be applied to every specified vertex,
%                   or a list of values of the same length as the list of
%                   vertexes, to be applied to them respectively.
%       'mode'      Either 'set' or 'add'.  'set sets the vertex to the
%                   given value, 'add' adds the given value to the current
%                   value.
%
%   Equivalent GUI operation: clicking on the mesh when the "Morphogens"
%   panel is selected.  This always operates in 'add' mode.  The morphogen
%   to apply is specified in the "Displayed m'gen" menu in the "Morphogens"
%   panel. Shift-clicking or middle-clicking will subtract the morphogen
%   instead of adding it.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [ok1, morphogen, args] = getTypedArg( mfilename(), {'numeric','char'}, varargin );
    if ~ok1, return; end
    g = FindMorphogenIndex( m, morphogen, mfilename() );
    if isempty(g), return; end

    [s,ok] = safemakestruct( mfilename(), args );
    if ~ok, return; end
    s = defaultFromStruct( s, struct( 'mode', 'add' ) );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'vertex', 'amount', 'mode' );
    if ~ok, return; end

    if (numel(s.amount) ~= 1) && (numel(s.amount) ~= numel(s.vertex))
        fprintf( 1, '%s: Number of values (%d) must be 1 or equal to number of vertexes (%d).\n', ...
            numel(s.amount), numel(s.vertex) );
        return;
    end
    
    validVxs = (s.vertex >= 1) && (s.vertex <= size(m.nodes,1));
    vxs = s.vertex( validVxs );
    if length(vxs) < length(s.vertex)
        fprintf( 1, '%s: %d invalid vertex indexes ignored: [', mfilename(), ...
            length(s.vertex) - length(vxs) );
        fprintf( 1, ' %d', setdiff( vxs, s.vertex ) );
        fprintf( 1, ' ]\n' );
    end
      
    if isempty(vxs), return; end
    if isempty(s.amount), return; end
    s.amount = s.amount( validVxs );
    s.amount = reshape( s.amount, [], 1 );

    if strcmp( s.mode, 'add' )
        m.morphogens(vxs,g) = m.morphogens(vxs,g) + reshape( s.amount, [], 1 );
    else
        m.morphogens(vxs,g) = reshape( s.amount, [], 1 );
    end
    m.saved = 0;
end
