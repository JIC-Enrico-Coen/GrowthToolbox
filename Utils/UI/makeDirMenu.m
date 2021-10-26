function h = makeDirMenu( parent, dirstruct, readonly, callback )
%h = makeDirMenu( parent, dirstruct, readonly, callback )
%   Take a structure returned by findProjectDirs and make a hierarchy of
%   menus, as a child of the parent menu.
%   The userdata field of each menu item will contain these fields:
%       fullname: the full pathname to the directory
%       basename: the base name of the directory
%       readonly: a boolean to indicate whether projects within this
%                 directory should be treated as read-only.

    if isempty(dirstruct)
        h = [];
        return;
    end
    if nargin < 3
        callback = [];
    end
    
    fullpath = dirstruct.name;
    [parentpath, basename] = dirparts( fullpath );
    ifname = makeIFname(basename);
    if readonly
        label = [ basename, ' (read-only)' ];
    else
        label = basename;
    end
    h = uimenu( parent, ...
                'Label', label, ...
                'Tag', ifname, ...
                'UserData', struct( 'modeldir', fullpath, ...
                                    'readonly', readonly ) );
    if dirstruct.isprojectdir
        set( h, 'Callback', callback );
    end
    for i=1:length(dirstruct.children)
        makeDirMenu( h, dirstruct.children(i), readonly, callback );
    end
    packmenu( h, 20 );
end
