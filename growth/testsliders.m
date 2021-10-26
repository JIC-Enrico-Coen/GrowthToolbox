function testsliders( handles )
    s = fieldnames( handles );
    for i=1:length(s)
        fn = s{i};
        if ishandle( handles.(fn) )
            h = handles.(fn);
            t = get( h, 'Type' );
            if strcmp(t,'uicontrol')
                sty = get( h, 'Style' );
                if strcmp( sty, 'slider' )
                    mn = get( h, 'Min' );
                    mx = get( h, 'Max' );
                    v = get( h, 'Value' );
                    if (v < mn) || (v > mx)
                        errstring = ' ********';
                    else
                        errstring = '';
                    end
                    fprintf( 1, '%s: min %.3f max %.3f val %.3f%s\n', ...
                        fn, mn, mx, v, errstring );
                end
            end
        end
    end
end
