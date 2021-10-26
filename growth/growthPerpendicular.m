function gperp = growthPerpendicular( m )
    gi = m.mgenNameToIndex.growth;
    ai = m.mgenNameToIndex.anisotropy;
    gperp = m.morphogens(:,gi) - m.morphogens(:,ai);
end
