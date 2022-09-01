function dd = unifyDelData( n, dd, primaryfield )
% dd has four fields: dellist, delmap, keeplist, and keepmap.
% At most one should be nonempty.  The other two fields will be computed
% from that one.

    if ~isfield( dd, 'dellist' )
        dd.dellist = [];
    end
    if ~isfield( dd, 'delmap' )
        dd.delmap = [];
    end
    if ~isfield( dd, 'keeplist' )
        dd.keeplist = [];
    end
    if ~isfield( dd, 'keepmap' )
        dd.keepmap = [];
    end
    
    if nargin < 3
        if ~isempty( dd.keepmap )
            primaryfield = 'keepmap';
        elseif ~isempty( dd.keeplist )
            primaryfield = 'keeplist';
        elseif ~isempty( dd.delmap )
            primaryfield = 'delmap';
        else % if ~isempty( dd.dellist )
            primaryfield = 'dellist';
        end
    end
    
    switch primaryfield
        case 'keepmap'
            dd.keeplist = find( dd.keepmap );
            dd.delmap = ~dd.keepmap;
            dd.dellist = find( dd.delmap );
        case 'keeplist'
            dd.keepmap = false(n,1);
            dd.keepmap(dd.keeplist) = true;
            dd.delmap = ~dd.keepmap;
            dd.dellist = find( dd.delmap );
        case 'delmap'
            dd.keepmap = ~dd.delmap;
            dd.keeplist = find( dd.keepmap );
            dd.dellist = find( dd.delmap );
        case 'dellist'
            dd.keepmap = true(n,1);
            dd.keepmap(dd.dellist) = false;
            dd.delmap = ~dd.keepmap;
            dd.keeplist = find( dd.keepmap );
    end
end

