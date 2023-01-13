function m = addStaticData( m, s )
%m = addStaticData( sd )
%   sd contains the static mesh data.  Overwrite the static data in m by sd
%   and reconcile them.  This mostly consists of replacing fields in m by
%   fields in sd, but the morphogen dictionary is shared by both and any
%   changes require reindexing the per-morphogen fields of m.

global gPerMgenDynamicDefaults gSecondlayerRunFieldDefaults gSecondlayerStaticFields gPerCellFactorDynamicDefaults
    
    m.ownModelOptions = getModelOptions( m );

    s = upgradeStaticData( s, m );
    
    if isfield( s, 'mgen_absorption' )
        if ~isfield( m, 'mgen_absorption' )
            m.mgen_absorption = s.mgen_absorption;
            
            % Not sure if this is necessary, upgradeMesh may be going to
            % take care of this.
            if size(m.mgen_absorption,1)==1
                m.mgen_absorption = repmat( m.mgen_absorption, getNumberOfVertexes(m), 1 );
            end
        end
        s = rmfield( s, 'mgen_absorption' );
    end
    
    
    timeshift = s.globalProps.starttime - m.globalProps.starttime;
    if timeshift ~= 0
        m.globalDynamicProps.currenttime = timeshift + m.globalDynamicProps.currenttime;
    end
    
    % Prepare to deal with reindexing of morphogens and cell factors.
    dIndexToName = m.mgenIndexToName;
    dNameToIndex = m.mgenNameToIndex;
    sIndexToName = s.mgenIndexToName;
    sNameToIndex = s.mgenNameToIndex;
    
    if isfield( s, 'secondlayer' )
        % Reconcile old and new cell factors.
        if isfield( s, 'secondlayer' )
            reindexCF = reindexDictionary( m.secondlayer.valuedict.name2IndexMap, ...
                                           m.secondlayer.valuedict.index2NameMap, ...
                                           s.secondlayer.valuedict.name2IndexMap, ...
                                           s.secondlayer.valuedict.index2NameMap );
            perCFfields = fieldnames( gPerCellFactorDynamicDefaults );
            for i=1:length(perCFfields)
                fn = perCFfields{i};
                m.secondlayer.(fn) = reindexArrayByDictionary( reindexCF, m.secondlayer.(fn), gPerCellFactorDynamicDefaults.(fn) );
            end
        end
        
        % Update the lineage info if necessary.

        % Update the static and semi-static components of m.secondlayer.
        m.secondlayer = setFromStruct( m.secondlayer, s.secondlayer, union( fieldnames(gSecondlayerRunFieldDefaults), gSecondlayerStaticFields ) );
        % Establish the current mapping from cell id to cell index.
        m.secondlayer.cellidtoindex = zeros( length(m.secondlayer.cellparent), 1 );
        m.secondlayer.cellidtoindex(m.secondlayer.cellid) = (1:length(m.secondlayer.cellid))';
%         m = invalidateLineage( m );
        
        % secondlayer is now dealt with, so remove it from s.
        s = rmfield( s, 'secondlayer' );
    end
    
    newtwosided = m.globalProps.twosidedpolarisation ~= s.globalProps.twosidedpolarisation;
    m.globalProps = setFromStruct( m.globalProps, s.globalProps );
    m.plotdefaults = setFromStruct( m.plotdefaults, s.plotdefaults );
    
    % globalProps.twosidedpolarisation has implications for other parts of
    % m, so handle this separately.
    if newtwosided
        m = setTwoSidedPolarisation( m, s.globalProps.twosidedpolarisation );
    end
    
    % globalProps and plotdefaults are now dealt with, so remove them from
    % s.
    s = rmfield( s, {'globalProps','plotdefaults'} );
    
    m = setFromStruct( m, s );
    m = updateElasticity( m );
    newtoold = zeros(1,length(sIndexToName));
    for newindex=1:length(sIndexToName)
        try
            oldindex = dNameToIndex.(sIndexToName{newindex});
        catch
            oldindex = 0;
        end
        newtoold(newindex) = oldindex;
    end
    if (length(newtoold) ~= length(dIndexToName)) || ~all( newtoold==(1:length(dIndexToName)) )
    
        oldtonew = zeros(1,length(dIndexToName));
        for oldindex=1:length(dIndexToName)
            try
                newindex = sNameToIndex.(dIndexToName{oldindex});
            catch
                newindex = 0;
            end
            oldtonew(oldindex) = newindex;
        end

        reindexMgens = reindexDictionary( dNameToIndex, dIndexToName, sNameToIndex, sIndexToName );
        perMgenFields = fieldnames( gPerMgenDynamicDefaults );
        for i=1:length(perMgenFields)
            fn = perMgenFields{i};
            m.(fn) = reindexArrayByDictionary( reindexMgens, m.(fn), gPerMgenDynamicDefaults.(fn) );
        end

        m.secondlayer.indexededgeproperties(1) = struct( 'LineWidth', m.plotdefaults.bioAlinesize, ...
                                                         'Color', m.plotdefaults.bioAlinecolor );
    end
end

