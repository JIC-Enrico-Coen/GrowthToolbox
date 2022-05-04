function sl = deleteUnusedVerts( sl )
% Takes a structure with fields sl.pts and sl.cellvxs, representing a set
% of polygons, and removes from sl.pts all poits not referenced by any of the
% polygons, and reindexes sl.cellvxs to refer to the reduced set of points.

    [retainedvxindexes,ia,ic] = unique( sl.cellvxs(:) );
    if ~isempty(retainedvxindexes) && (retainedvxindexes(1)==0)
        retainedvxindexes(1) = [];
    end
    if isempty(retainedvxindexes)
        sl.pts = zeros(0,3);
        sl.cellvxs = zeros(0,0);
        return;
    end
    
    renumbervxs = zeros( size(sl.pts,1), 1 );
    renumbervxs(retainedvxindexes) = 1:length(retainedvxindexes);
    renumbervxs = [ 0; renumbervxs ];
    
    sl.pts = sl.pts( retainedvxindexes, : );
    sl.cellvxs = renumbervxs( sl.cellvxs+1 );
end
