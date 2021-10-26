function m = dilateSubstances( m, u )
%m = dilateSubstances( m, u )
%   Apply dilateSubstance to each growth factor for which mgen_dilution is
%   true, using the displacements u.  Clamped values are not changed.

    if any(m.mgen_dilution)
        d = dilations( m, u );
        for i=find(m.mgen_dilution)
            unfixedtemps = m.morphogenclamp(:,i) < 1;
            m.morphogens(unfixedtemps,i) = m.morphogens(unfixedtemps,i) .* d(unfixedtemps);
        end
    end
end
