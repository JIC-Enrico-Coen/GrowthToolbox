function m = applyMgenDefaults( m, mgenindexes )
%m = applyMgenDefaults( m, mgenindexes, numnodes )
%   Insert default per-morphogen values for various fields, for the given
%   set of new morphogen indexes.  The indexes are assumed to be at the end
%   of all current indexes.

    setGlobals();
    global gPerNodeMgenDefaults gPerMgenDefaults
    nmfns = fieldnames( gPerNodeMgenDefaults );
    mfns = fieldnames( gPerMgenDefaults );
    
    hreps = length(mgenindexes);
    for i=1:length(nmfns)
        fn = nmfns{i};
        m.(fn)(:,mgenindexes) = repmat( gPerNodeMgenDefaults.(fn), getNumberOfVertexes( m ), hreps );
    end
    for i=1:length(mfns)
        fn = mfns{i};
        m.(fn)(:,mgenindexes) = repmat( gPerMgenDefaults.(fn), 1, hreps );
    end
    m.mgenposcolors(:,mgenindexes) = defaultMgenColors( mgenindexes );
    m.mgennegcolors = oppositeColor( m.mgenposcolors' )';
    m.transportfield(mgenindexes) = {[]};
    m.mgen_transportable(mgenindexes) = false;
    m.mgen_plotpriority(mgenindexes) = 0;
    m.mgen_plotthreshold(mgenindexes) = 0;
end
