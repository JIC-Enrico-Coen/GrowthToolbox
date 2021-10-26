function setMenuSelectedItemCode( menu, code )
    ud = get( menu, 'Userdata' );
    if isfield( ud, 'labeldict' )
        [~,v] = name2Index( ud.labeldict, code );
        label = v{1};
    else
        label = code;
    end
    setMenuSelectedLabel( menu, label );
end
