function insertDefaultsInDlg( dlg, s )
    fns = fieldnames(s);
    for fni = 1:length(fns)
        fn = fns{fni};
        set( dlg.(fn), 'Value', s.(fn) );
    end
end
% Need to check the dlg element exists.
% Need to set Value or String, depending on the type of the element.
% Need to convert the value in s to the appropriate type.
% For menus, need to accept a numerical index.
