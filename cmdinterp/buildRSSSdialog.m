function h = buildRSSSdialog( fn )
%h = buildRSSSdialog( fn )
%   Create a dialog from the dialogspec contained in the file called fn.
%   The result is a handle to the figure it creates, or -1 if it could not
%   be created.

    ts = opentokenstream( fn );
    [ts,ended] = atend( ts );
    if ended
        return;
    end
    [ts,s,err] = parseRSSS( ts );
    if err
        return;
    end
    h = figure(1);
    p = get( h, 'Position' );
    sz = [500, 768];
    p = [ p([1,2]) - sz + p([3 4]), sz ];
    set( h, 'Position', p );
    clf;
    buildRSSSstructdialog( s, h );
end

