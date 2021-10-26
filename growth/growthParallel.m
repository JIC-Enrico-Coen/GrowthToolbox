function gpar = growthParallel( m )
    setGlobals();
    
    gi = m.mgenNameToIndex.growth;
    ai = m.mgenNameToIndex.anisotropy;
    gpar = m.morphogens(:,gi) + m.morphogens(:,ai);
end
