function m = leaf_resetmorphogendata( m )
%m = leaf_resetmorphogens( m )
%   This sets all of the following to zero for all morphogens:
%       morphogen values
%       morphogen production rates
%       morphogen diffusion rates
%       morphogen decay rates
%       morphogen clamping
%
%   Interpolation mode is set to 'mid' for all morphogens except those
%   with names of the form 'ID_...', whose mode is set to 'min'.
%
%   Calling this in your interaction function on the first iteration will
%   ensure that mesh is initially a blank slate, on which the first call of
%   the i.f. writes the exact configuration required.  Note that some of
%   the data that are zeroed by this cannot be displayed in the GUI, making
%   it easy to miss the fact that the initial mesh might contain values for
%   them that you do not want.
%
%   Options: none.
%
%   Topics: Morphogens.

    m.morphogens(:) = 0;
    m.mgen_production(:) = 0;
    m.mgen_absorption(:) = 0;
    m.morphogenclamp(:) = 0;
    numMgens = size(m.morphogens,2);
    for i=1:numMgens
        m.conductivity(i) = struct( 'Dpar', [], 'Dper', [] );
        if isempty( regexp( m.mgenIndexToName{i}, '^ID_', 'once' ) )
            m.mgen_interpType{i} = 'mid';
        else
            m.mgen_interpType{i} = 'min';
        end
    end
    saveStaticPart( m );
end
