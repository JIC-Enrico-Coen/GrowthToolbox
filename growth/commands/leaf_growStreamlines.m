function m = leaf_growStreamlines( m, varargin )
%m = leaf_growStreamlines( m, ... )
%   NEVER USED.
%
%   Grow streamlines.
%
%   Options:
%
%   streamlines: a list of indexes of streamlines to extend.  By default,
%       all of them are.
%
%   See also: leaf_createStreamlines, leaf_deleteStreamlines.
%
%   Topics: Streamlines.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'streamlines', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', 'streamlines' );
    if ~ok, return; end

    if isempty(s.streamlines)
        s.streamlines = 1:length(m.streamlines);
    end
    
    for i=1:length(s.streamlines)
        m = extendStreamline( m, s.streamlines(i) );
    end
end
