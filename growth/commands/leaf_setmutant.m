function m = leaf_setmutant( m, varargin )
%m = leaf_setmutant( m, ... )
%   Set the mutant level of a morphogen.
%
%   Options:
%   morphogen:   The name or index of a morphogen.  If omitted, the
%                mutation properties are set for every morphogen.
%   value:       The value the morphogen has in the mutant state, as a
%                proportion of the wild-type state.
%
%   Examples:
%       m = leaf_setmutant( m, 'morphogen', 'div', 'value', 0 );
%           % Set the mutated level of the 'div' morphogen to zero.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    ok = checkcommandargs( mfilename(), s, 'only', 'morphogen', 'value' );
    if ~ok, return; end
    
    if isfield( s, 'morphogen' )
        whichMgen = FindMorphogenIndex( m, s.morphogen, mfilename() );
        if isempty(whichMgen)
            return;
        end
    else
        whichMgen = 0;
    end
    if isfield( s, 'value' )
        if whichMgen==0
            m.mutantLevel(:) = s.value;
        else
            m.mutantLevel(whichMgen) = s.value;
        end
        saveStaticPart( m );
    end
end
