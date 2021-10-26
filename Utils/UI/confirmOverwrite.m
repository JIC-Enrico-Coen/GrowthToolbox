function goAhead = confirmOverwrite( f )
    if exist( f, 'file' )
        MYDIALOG = true;
        if MYDIALOG
            answer = queryDialog( 2, '', ['File ', f, ' already exists, overwrite?'] );
            goAhead = answer==1;
        else
            answer = questdlg(['File ', f, ' already exists, overwrite?'], ...
                               '', ...
                               'Yes','No','No' );
            goAhead = strcmp(answer,'Yes');
        end
    else
        goAhead = true;
    end
end
