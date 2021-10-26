function m = leaf_refineFEM( m, varargin )
%m = leaf_refineFEM( m, ... )
%   Split some edges of the mesh m according to one of several possible
%   criteria.
%
%   Options:
%
%   parameter: A number, variously used.  This must be greater than zero.
%       If zero is supplied, no edges are split.
%
%   mode:  A string, one of the following.
%          'longest' (the default): 'parameter' is the fraction of edges to
%              be split, from the longest downwards.
%          'random': 'parameter' is the fraction of randomly selected edges
%              to be split.
%          'longelements':  Split every edge that belongs to an element, every
%              one of whose edges is longer than 'parameter' times the length
%              of the longest edge.
%          'relative'  Split every edge longer than 'parameter' times the
%              length of the longest edge.
%          'absolute'  Split every edge longer than 'parameter'.
%   iterative:  A boolean (default false).  This applies when mode is 'longelements',
%              'absolute', or 'relative'.  The refinement will be repeated
%              until there are no eligible edges.  The threshold length for
%              splitting is computed once at the start, not updated
%              after each iteration.  As soon as no eligible edges remain,
%              or until 'maxiterations' iterations have been performed, the
%              splitting stops.  For the other modes, this option and
%              'maxiterations' are ignored.
%   maxiterations:  When 'iterative' is true, this puts a bound on the
%              number of iterations permitted.  The default is 4.  When
%              'iterative' is false, 'maxiterations' is ignored.
%
%   Example:
%
%   Split the longest 30% of edges:
%       m = leaf_refineFEM( m, 'parameter', 0.3, 'mode', 'longest' );
%
%   Split edges until none of them are longer than 0.2 times the length of
%   the currently longest edge:
%       m = leaf_refineFEM( m, 'parameter', 0.2, 'mode', 'relative', ...
%               'iterative', true, 'maxiterations', 4 );
%   Split all edges:
%       m = leaf_refineFEM( m, 'parameter', 1 );
%
%
%   Equivalent GUI operation: clicking the "Refine mesh" button in the
%   "Mesh editor" panel.  This invokes 'longest' mode, and the scroll bar
%   and text box set the proportion of edges to be split.
%
%   Topics: Mesh editing.


    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'parameter', 1, 'mode', 'longest', 'iterative', false, 'maxiterations', 4 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'parameter', 'mode', 'iterative', 'maxiterations' );
    if ~ok, return; end
    
    m = refinemesh( m, s.parameter, s.mode, s.iterative, s.maxiterations );
end
