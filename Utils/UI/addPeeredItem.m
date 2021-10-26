function addPeeredItem( thisitem, peer, varargin )
%addPeeredItem( thisitem, peer, ... )
%   Given a GUI item THISITEM and another item PEER, it adds THISITEM to
%   the set of peered items of which PEER is a member. if any.  If PEER is
%   not already a peer of any other item, THISITEM and PEER will become
%   peers of each other.
%
%   It does this by adding THISITEM to the peer list of all of the items,
%   including THISITEM.  It also sets the DeleteFcn of THISITEM to
%   peeredItem_DeleteFcn.
%
%   If THISITEM is already a peer of PEER, nothing happens.  If it is
%   already a peer of another item, that peering is broken before
%   establishing the new one.
%
%   PEER does not need to already be a member of a peered set, but it is
%   assumed to have a peer-aware Callback and DeleteFcn.
%
%   Further arguments are a list of fields whose values should be copied to
%   THISITEM from PEER.  For example, for a menu the fields to copy would
%   be 'String' and 'Value'.

    if ~ishandle( thisitem ) || ~ishandle( peer )
        return;
    end
    udpeer = get( peer, 'UserData' );
    if isfield( udpeer, 'peers' )
        peers = udpeer.peers;
        set( peer, 'DeleteFcn', @peeredItem_DeleteFcn );
    else
        peers = peer;
    end
    if ~isempty( find(thisitem==peers,1) )
        % THISITEM is already a peer of PEER.
        return;
    end
    udmine = get( thisitem, 'UserData' );
    if isfield( udmine, 'peers' ) && ~isempty(udmine.peers)
        % THISITEM is already peered with something else.  Stop peering.
        stopPeeringItem( thisitem );
    end
    
    peers = unique( [ peers( ishandle(peers) ) thisitem] );
    for i=1:length(peers)
        addUserData( peers(i), 'peers', peers );
    end
    set( thisitem, 'DeleteFcn', get( peer, 'DeleteFcn' ), 'Callback', get( peer, 'Callback' ) );
    for i = 1:length(varargin)
        set( thisitem, varargin{i}, get( peer, varargin{i} ) );
    end
end
