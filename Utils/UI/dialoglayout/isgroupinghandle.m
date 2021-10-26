function isgh = isgroupinghandle( h )
    isgh = (numel(h)==1) && ishandle(h) && strcmp( get(h,'Type'), 'uipanel' );
end

