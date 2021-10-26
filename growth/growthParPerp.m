function [gpar,gperp] = growthParPerp( m )
    gi = m.mgenNameToIndex.growth;
    ai = m.mgenNameToIndex.anisotropy;
    gpar = m.morphogens(:,gi) + m.morphogens(:,ai);
    gperp = m.morphogens(:,gi) - m.morphogens(:,ai);
end
