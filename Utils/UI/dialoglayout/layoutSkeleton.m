function result = layoutSkeleton( items, parentgui, top )
    SEPARATION = 14;
    EDGE = 10;
    if nargin < 3
        top = true;
    end

    result = struct();
    result.parent = parentgui;
    result.separation = SEPARATION;
    result.children = {};
    result.sticky = [1 1 1 1];
    result.horizontal = size(items,1) == 1;
    if top
        result.edge = [EDGE EDGE EDGE EDGE];
    else
        result.edge = [0 0 0 0];
    end

    if isempty(items)
        result = [];
        return;
    end

    if iscell(items)
        if isgroupinghandle( items{1} )
            result.handle = items{1};
            if strcmp( get( result.handle, 'Type' ), 'uipanel' )
                if isempty( tryget( result.handle, 'Title' ) )
                    topedge = EDGE;
                else
                    fontheight = tryget( result.handle, 'FontSize' );
                    topedge = EDGE + fontheight;
                end
            else
                topedge = EDGE;
            end
            result.edge = [EDGE EDGE EDGE topedge];
            result.sticky = [1 1 1 1];
            result.position = [0 0 20 20];
            parentgui = items{1};
            top = true;
            items = { items{2:end} };
        else
            result.sticky = [0 0 0 0];
            top = false;
        end
        okchildren = 0;
        children = {};
        for i=1:length(items)
            c = layoutSkeleton( items{i}, parentgui, top );
            if ~isempty(c)
                okchildren = okchildren+1;
                children{okchildren} = c;
            end
        end
        result.children = children;
    elseif ishandle( items )
        result.handle = items;
        result.position = get( items, 'Position' );
        result.position([1 2]) = 0;
        result.outerposition = result.position;
        result.children = {};
        hstyle = tryget(items,'Style');
        switch hstyle
            case { 'pushbutton', 'togglebutton', 'checkbox', 'radiobutton' }
                result.sticky = [0 0 0 0];
            case { 'slider' }
                if result.position(3) > result.position(4)
                    result.sticky = [1 0 1 0];
                else
                    result.sticky = [0 1 0 1];
                end
            case { 'edit', 'listbox' }
                result.sticky = [1 1 1 1];
            case { 'uipanel' }
                if isempty( get( result.handle, 'Title' ) )
                    topedge = EDGE;
                else
                    fontheight = get( result.handle, 'FontSize' );
                    topedge = EDGE + fontheight;
                end
                result.sticky = [1 1 1 1];
                result.edge = [EDGE EDGE EDGE topedge];
            case { 'popupmenu' }
                result.sticky = [1 0 0 1];
            otherwise
                result.sticky = [1 1 1 1];
        end
    else
        complain( '%s: unexpected object.\n', mfilename );
        items
        result = [];
    end
end

