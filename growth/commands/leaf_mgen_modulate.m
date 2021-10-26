function m = leaf_mgen_modulate( m, varargin )
%m = leaf_mgen_modulate( m, ... )
%   Set the switch and mutant levels of a morphogen.
%
%   Options:
%   morphogen:   The name or index of a morphogen or set of morphogens.
%   switch, mutant:  Value by which the morphogen is multiplied to give its
%                effective level.
%
%   If either switch or mutant is omitted its current value is
%   left unchanged. 
%
%   The effective value of a morphogen is the product of the actual
%   morphogen amount, the switch value, and the mutant value.  So
%   mutant and switch have the same effect; the difference is
%   primarily in how they are intended to be used.  Mutant value is
%   settable in the Morphopgens panel of the GUI and is intended to have a
%   constant value for each morphogen throughout a run.  There is also a
%   checkbox in the GUI to turn all mutations on and off.  Switch value has
%   no GUI interface, and is intended to be changed in the interaction
%   function.  The switch values are always effective.
%
%   The initial values for switch and mutant in a newly created leaf are 1.
%
%   Examples:
%       m = leaf_mgen_modulate( m, 'morphogen', 'div', ...
%                                  'switch', 0.2, ...
%                                  'mutant', 0.5 );
%       Sets the switch level of 'div' morphogen to 0.2 and the mutant
%       level to 0.5.  The effective level will then be 0.1 times the
%       actual morphogen.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    ok = checkcommandargs( mfilename(), s, 'incl', ...
            'morphogen' ) ...
         && checkcommandargs( mfilename(), s, 'only', ...
                'morphogen', 'switch', 'mutant' );
    if ~ok, return; end
    
    whichMgen = FindMorphogenIndex( m, s.morphogen, mfilename() );
    if isempty(whichMgen)
        return;
    end

    staticChanged = false;
    
    if isfield( s, 'switch' )
        m.mgenswitch(whichMgen) = s.switch;
        staticChanged = true;
    end
    if isfield( s, 'mutant' )
        m.mutantLevel(whichMgen) = s.mutant;
        staticChanged = true;
    end
    
    if staticChanged
        saveStaticPart( m );
    end
end
