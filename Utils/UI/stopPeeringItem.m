function stopPeeringItem( items )
%stopPeeringItem( items )
%   Discontinue the peering of these GUI items.

    for it=1:length(items)
        item = items(it);
        if ishandle( item )
            ud = get( item, 'UserData' );
            if isfield( ud, 'peers' )
                for i=1:length(ud.peers)
                    p = ud.peers(i);
                    if ishandle(p) && (p ~= item)
                        udp = get( p, 'UserData' );
                        if isfield( udp, 'peers' )
                            udp.peers = udp.peers( udp.peers ~= item );
                            set( p, 'UserData', udp );
                        end
                    end
                end
                ud = rmfield( ud, 'peers' );
                set( item, 'UserData', ud, 'DeleteFcn', [] );
            end
        end
    end
end
