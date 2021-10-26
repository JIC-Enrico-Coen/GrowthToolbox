function str = generatePlotOptions( m )
    for fnc=fieldnames( m.plotdefaults )'
        fn = fnc{1};
        v = m.plotdefaults.(fn);
        if ~isempty( v  )
            fprintf( 1, '''%s'', %s,\n', fn, formatvalue( v ) );
        end
    end
end

