function selectProjectMenu( mh, selected )
    CANSETMENUSTYLE = false;
    mh1 = mh;
    while ~isempty( mh1 ) ...
            && ishandle( mh1 ) ...
            && strcmp( get( mh1, 'Type' ), 'uimenu' )
        pmh = get( mh1, 'Parent' );
        if ~strcmp( get( pmh, 'Type' ), 'uimenu' )
            % This implies that mh1 is the Projects menu.
            if selected
                ud = get( mh1, 'Userdata' );
                ud.defaultprojectitem = mh;
                set( mh1, 'Userdata', ud );
            end
            return;
        end
        if CANSETMENUSTYLE
            if selected %#ok<UNRCH>
                style = 'UH';
            else
                style = 'uh';
            end
            setMenuItemStyle( mh1, style );
        else
            setMenuHighlight( mh1, selected );
        end
        mh1 = pmh;
    end
end
