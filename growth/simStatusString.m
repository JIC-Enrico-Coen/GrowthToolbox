function s = simStatusString( m )
%s = simStatusString( m )
%   Make the report of leaf size, number of iterations, etc. and return it
%   as a string.

    if isempty(m)
        s = '';
        return;
    end
    
    STRAINRET_MGEN = FindMorphogenRole( m, 'STRAINRET' );
    
    totalareaincrease = m.globalDynamicProps.currentArea/m.globalProps.initialArea;
    totallinearincrease = sqrt(totalareaincrease);
    if (m.globalDynamicProps.previousArea > 0) && (m.globalDynamicProps.currentIter > 0)
        stepareaincrease = m.globalDynamicProps.currentArea/m.globalDynamicProps.previousArea;
    	steplinearincrease = sqrt(stepareaincrease);
        areareport = sprintf( 'Growth: area %.2f (%+.1f%%), linear %.2f (%+.1f%%).', ...
            totalareaincrease, (stepareaincrease-1)*100, ...
            totallinearincrease, (steplinearincrease-1)*100 );
    else
        areareport = sprintf( 'Growth: area %.2f, linear %.2f.', ...
            totalareaincrease, ...
            totallinearincrease );
    end

    FEreport = sprintf( '%d FEs, %d vertexes', getNumberOfFEs(m), getNumberOfVertexes(m) );
    if m.globalProps.inittotalcells > 0
        FEreport = [ FEreport, ...
            sprintf( ', %d cells', ...
                round(m.globalProps.inittotalcells*totalareaincrease) ) ];
    end
    if hasNonemptySecondLayer( m )
        FEreport = [ FEreport, ...
            sprintf( ', Bio-A %d', length(m.secondlayer.cells) ) ];
    end
    FEreport = [ FEreport, '.' ];
    if isempty( m.tubules.tracks )
        tubulereport = '';
    else
        numtracks = length(m.tubules.tracks);
        totallength = sum( [ m.tubules.tracks.segmentlengths ] );
        tubulereport = sprintf( '%d tubules, total length %.2f.', numtracks, totallength );
    end
    
    if isfield( m, 'ticForIter' )
        statsString = sprintf( '%.2f sec, %.2f ms/FE', ...
            m.ticForIter, 1000*m.ticForIter/getNumberOfFEs(m) );
        if m.globalProps.cgiters > 0
            statsString = [ statsString, ...
                sprintf( ', %d iters', m.globalProps.cgiters ) ];
        end
        iterationTimeReport = [ ' (', statsString, ')' ];
    else
        iterationTimeReport = '';
    end
    iterationreport = sprintf( 'Step %d%s, %.3f %ss.', ...
        m.globalDynamicProps.currentIter, ...
        iterationTimeReport, ...
        m.globalDynamicProps.currenttime, ...
        m.globalProps.timeunitname );

    absresidstrain = [ m.celldata.residualStrain ];
    maxresidstrain = max( abs( absresidstrain(:) ) );
    if isempty(absresidstrain)
        avresidstrain = 0;
    else
        avresidstrain = sum( absresidstrain(:) )/(6*length(absresidstrain));
    end
    if STRAINRET_MGEN ~= 0
        strainreport = sprintf( 'Strain max %.2f%% average %.2f%%. Av. strain retention %.0f%%.', ...
            maxresidstrain*100, avresidstrain*100, ...
            sum( m.morphogens(:,STRAINRET_MGEN) )/size(m.morphogens,1) );
    else
        strainreport = [];
    end

    if m.allMutantEnabled && any(m.mutantLevel ~= 1)
        isMutant = 'MUTANT:';
        for i=1:length(m.mutantLevel)
            if m.mutantLevel(i) ~= 1
                isMutant = [ ...
                    isMutant, ' ', ...
                    m.mgenIndexToName{i}, ' ', ...
                    sprintf( '%.2f', ...
                        m.mutantLevel(i) ) ];
            end
        end
    else
        isMutant = 'WILDTYPE';
    end
    
    if isfield( m.globalProps, 'comment' ) && ~isempty( m.globalProps.comment )
        comment = [ ' ', m.globalProps.comment ];
    else
        comment = '';
    end
        
    s = [ isMutant, '  ', ...
          FEreport, ' ', ...
          tubulereport, ' ', ...
          iterationreport, newline(), ...
          areareport, ' ', ...
          strainreport, ...
          comment
        ];
end
