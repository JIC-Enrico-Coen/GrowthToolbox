function selectExclusiveMenuItem( h, hs )
    if ~ischeckedMenuItem( h )
        label = get( h, 'Label' );
        for h1=hs
            set( h1, 'Checked', boolchar( strcmp( label, get( h1, 'Label' ) ), 'on', 'off' ) );
        end
    end
end
