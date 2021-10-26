function code = getMenuSelectedItemCode( menu )
    label = getMenuSelectedLabel( menu );
    ud = get( menu, 'Userdata' );
    if isfield( ud, 'labeldict' )
        [~,n] = value2Index( ud.labeldict, label );
        code = n{1};
    else
        code = label;
    end
end
