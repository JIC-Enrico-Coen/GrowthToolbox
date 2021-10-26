function makePackedMenu( parent, position, menudata, maxmenulength, mintopmenulength )
%makePackedMenu( parent, position, menudata, maxmenulength, mintopmenulength )
%
%   Create a tree of submenus of the given parent menu.
%
%   MENUDATA is an array of structs, one for each of the menus to be
%   created.  These structs contain the parameters to be supplied to uimenu
%   for each menu.  They must define the 'Label' property and may define
%   any others; typically they will define at least the 'Callback'
%   property.  All of them must define the same set of parameters.  If a
%   parameter is needed for some menu items but not others, provide an
%   empty value or an appropriate default value for those where it is not
%   needed.
%
%   The maximum length of any of the created menus will be MAXMENULENGTH.
%
%   PARENT is the top-level menu into which the items will be inserted,
%   starting at POSITION.  PARENT may already have other menu items; in
%   this case the number of top level items inserted will be no more than
%   will bring the total length of the parent up to MAXMENULENGTH, unless
%   this would result in fewer than MINTOPMENULENGTH top-level items, in
%   which case MINTOPMENULENGTH top-level items will be inserted.

    if nargin < 4
        maxmenulength = 20;
    end

    if nargin < 5
        mintopmenulength = 5;
    end

    if ~ishandle( parent )
        return;
    end
    
    maxTopLength = max( maxmenulength - length( get( parent, 'Children' ) ), ...
                        mintopmenulength );
    
    t = maketree( length(menudata), 1, maxmenulength, maxTopLength );
    
    buildmenu( parent, position, menudata, t );
end

function buildmenu( parent, position, menudata, t )
%     while iscell(t) && (length(t)==1)
%         t = t{1};
%     end
    if isnumeric(t)
        for i=1:length(t)
            params = struct2args( menudata(t(i)) );
            uimenu( parent, 'Position', position+i-1, params{:} );
        end
    else
        % t is a cell array of length greater than 1.
        for i=1:length(t)
            ti = t{i};
            if length(ti)==1
                params = struct2args( menudata(ti) );
                uimenu( parent, 'Position', position+i-1, params{:} );
            else
                MAXLEN = 20;
                firstsub = menudata(leftleaf( ti ));
                firstsub = firstsub.Label;
                if length(firstsub) > MAXLEN
                    firstsub = [ firstsub(1:MAXLEN), '...' ];
                end
                lastsub = menudata(rightleaf( ti ));
                lastsub = lastsub.Label;
                if length(lastsub) > MAXLEN
                    lastsub = [ lastsub(1:MAXLEN), '...' ];
                end
                submenu = uimenu( parent, 'Position', position+i-1, ...
                    'Label', [firstsub, ' - ', lastsub] );
                buildmenu( submenu, 1, menudata, ti );
            end
        end
    end
end

function n = leftleaf( t )
    while length(t) > 1
        if iscell(t)
            t = t{1};
        else
            t = t(1);
        end
    end
    n = t;
end

function n = rightleaf( t )
    while length(t) > 1
        if iscell(t)
            t = t{end};
        else
            t = t(end);
        end
    end
    n = t;
end
