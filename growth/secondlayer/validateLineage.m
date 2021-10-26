function ok = validateLineage( m )
%ok = validateLineage( m )
%   Perform validity checks on the cellular lineage data.

    ok = true;
    if isempty( m.secondlayer.cellid )
        return;
    end
    
    decreasing = find(m.secondlayer.cellidtotime(1:(end-1),1) > m.secondlayer.cellidtotime(2:end,1));
    if ~isempty(decreasing)
        fprintf( 1, '**** Cell ids created out of order:\n' );
        fprintf( 1, '    %6s %6s\n', 'id', 'id' );
        fprintf( 1, '    %6d %6d\n', [decreasing; decreasing+1]' );
        fprintf( 1, '\n' );
        fprintf( 1, '\n' );
        ok = false;
    end
    % Every existing cell should appear to be extant and vice versa.
    
    existingIDs = false(length(m.secondlayer.cellparent),1);
    existingIDs( m.secondlayer.cellid ) = true;
    if ~isempty( m.secondlayer.cellidtotime )
        extantIDs = (m.secondlayer.cellidtotime(:,1) <= m.globalDynamicProps.currenttime) ...
                    & (m.secondlayer.cellidtotime(:,2) >= m.globalDynamicProps.currenttime);
        if any(existingIDs(:) & ~extantIDs(:))
            anomalousIDs = find(existingIDs & ~extantIDs);
            numtoreport = min( length(anomalousIDs), 4 );
            whichtoreport = anomalousIDs(1:numtoreport);
            fprintf( 1, '**** %d existing cells have lifetimes not including the current time %f:\n', length(anomalousIDs), m.globalDynamicProps.currenttime );
            fprintf( 1, '    %6s %6s %8s %8s\n', 'id', 'index', 'start', 'end' );
            fprintf( 1, '    %6d %6d %8g %8g\n', [whichtoreport m.secondlayer.cellidtoindex(whichtoreport) m.secondlayer.cellidtotime(whichtoreport,:)]' );
            ok = false;
        end
        if any(extantIDs & ~existingIDs)
            anomalousIDs = find(extantIDs & ~existingIDs);
            numtoreport = min( length(anomalousIDs), 4 );
            whichtoreport = anomalousIDs(1:numtoreport);
            fprintf( 1, '**** %d non-existent cells have lifetimes including the current time %f:\n', length(anomalousIDs), m.globalDynamicProps.currenttime );
            fprintf( 1, '    %6s %6s %8s %8s\n', 'id', 'index', 'start', 'end' );
            fprintf( 1, '    %6d %6d %8g %8g\n', [whichtoreport m.secondlayer.cellidtoindex(whichtoreport) m.secondlayer.cellidtotime(whichtoreport,:)]' );
            ok = false;
        end
    end
end
