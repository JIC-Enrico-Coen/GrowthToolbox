function m = deleteMgenValues( m, retainedindexes )
    setGlobals();
    global gPerMgenDefaults gPerNodeMgenDefaults
    
    fns = fieldnames( gPerMgenDefaults );
    for i=1:length(fns)
        fn = fns{i};
        m.(fn) = m.(fn)(:,retainedindexes);
    end
    
    fns = fieldnames( gPerNodeMgenDefaults );
    for i=1:length(fns)
        fn = fns{i};
        m.(fn) = m.(fn)(:,retainedindexes);
    end
end
