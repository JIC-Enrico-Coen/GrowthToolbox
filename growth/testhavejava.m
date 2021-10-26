function ok = testhavejava()
    ok = 1;
    try
        HistoryTree();
        fprintf( 1, [ 'GFtbox: Java is working.\n' ] );
    catch
        fprintf( 1, [ 'Warning from GFtbox: There is a problem accessing the Java classes.\n', ...
                      '         Recording the history will not be supported.\n' ] );
        ok = 0;
    end
end
