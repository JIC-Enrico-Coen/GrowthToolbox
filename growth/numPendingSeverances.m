function n = numPendingSeverances( m )
%     n = 0;
%     for i=1:length(m.tubules.tracks)
%         n = n + length( [m.tubules.tracks(i).status.severance] );
%     end
    
    statuses = [ m.tubules.tracks.status ];
    pendingEventInfo = [ statuses.severance ];
%     pendingEventTimes = [ pendingEventInfo.time ];
    n = length( pendingEventInfo );




    n = 0;
    for ti=1:length(m.tubules.tracks)
         n = n + length( m.tubules.tracks(ti).status.severance );
    end
end
