function c = ischeckedMenuItem( hs )
%c = ischeckedMenuItem( hs )
%   Return a boolean to indicate whether the menu item or items are
%   checkmarked. The result is a boolean array the same shape as hs.

    c = false(size(hs));
    for i=1:numel(hs)
        c(i) = strcmp( get( hs(i), 'Checked' ), 'on' );
    end
end
