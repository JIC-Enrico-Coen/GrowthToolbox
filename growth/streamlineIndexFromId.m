function sis = streamlineIndexFromId( m, sids )
%sis = streamlineIndexFromId( m, sids )
%   Find the indexes of the streamlines having the given ids.
%   For ids that do not exist, the indexes will be zero.

    allsids = [ m.tubules.tracks.id ];
    sis = findmultiple( sids, allsids );
end
