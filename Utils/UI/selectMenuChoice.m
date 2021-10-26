function selectMenuChoice( hObject )
%selectMenuChoice( hObject )
%Make the menu item hObject be the only checked item in its parent menu.
    hp = get( hObject, 'Parent' );
    hpc = get( hp, 'Children' );
    for i=1:length(hpc)
        if hObject==hpc(i)
            set( hpc(i), 'Checked', 'on' );
        else
            set( hpc(i), 'Checked', 'off' );
        end
    end
end
