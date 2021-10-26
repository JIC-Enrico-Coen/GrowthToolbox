function [h,n] = getCheckedSubmenu( menuhandle )
%[h,n] = getCheckedSubmenu( menuhandle )
%   Return the handle and position of the first child of menuhandle that
%   has a checkmark.  If there are none, return zero and the empty list.

    children=get(menuhandle,'children');
    positions = get(children,'Position');
    [positions,perm] = sort([positions{:}]);
    for i=1:length(positions)
        n = perm(i);
        if ischeckedMenuItem( children(n) )
            h = children(n);
            return;
        end
    end
    n = 0;
    h = [];
end
