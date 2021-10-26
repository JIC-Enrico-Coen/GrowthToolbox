function m = leaf_fix_mgen( m, varargin )
%m = leaf_fix_mgen( m, morphogen, ... )
%   Make the current value of a specified morphogen at a specified vertex
%   or set of vertexes be fixed or changeable.
%
%   Arguments:
%   1: The name or index of a morphogen.
%
%   Options:
%       'vertex'  Indexes of the vertexes.  The default is the empty list
%                 (i.e. do nothing).
%       'fix'     1 or true if the value is to be made fixed, 0 or false if
%                 it is to be made changeable.  The default is true.
%
%   Equivalent GUI operation: control-clicking or right-clicking on the
%   canvas when the Morphogens panel is selected.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [ok1, morphogen, args] = getTypedArg( mfilename(), {'numeric','char'}, varargin );
    if ~ok1, return; end
    g = FindMorphogenIndex( m, morphogen, mfilename() );
    if isempty(g), return; end

    [s,ok] = safemakestruct( mfilename(), args );
    if ~ok, return; end
    s = defaultfields( s, 'vertex', [], 'fix', true );
    ok = checkcommandargs( mfilename(), s, 'exact', 'vertex', 'fix' );
    if ~ok, return; end
    if isempty(s)
        return;
    end
    if islogical( s.vertex )
        vxs = s.vertex;
    else
        vxs = s.vertex( (s.vertex > 0) & (s.vertex <= size(m.nodes,1)) );
    end
    if s.fix
        m.morphogenclamp( vxs, g ) = 1;
    else
        m.morphogenclamp( vxs, g ) = 0;
    end
end
