function ok = saveStaticPartToFile( m, filename )
%ok = saveStaticPartToFile( m, filename )
%   Save the static part m to the given filename with '_static.mat' appended.
%   The given filename may be relative or absolute.

    ok = false;
    if isempty(m)
        return;
    end
    staticname = [ filename, '_static.mat' ];
    setGlobals();
    global gFULLSTATICFIELDS gSecondlayerRunFields gSecondlayerStaticFields
    mstatic = splitstruct( m, gFULLSTATICFIELDS );
    mstatic.globalProps = safermfield( mstatic.globalProps, 'bioApresplitproc', 'bioApostsplitproc', 'userpostiterateproc', 'mov' );
    mstatic.plotdefaults = safermfield( mstatic.plotdefaults, 'userpreplotproc', 'useplotproc' );
    mstatic.secondlayer = splitstruct( m.secondlayer, [ gSecondlayerRunFields, gSecondlayerStaticFields ] );
    timedFprintf( 1, 'Saving static part to %s.\n', staticname );
    try
        save( staticname, '-struct', 'mstatic' );
        ok = true;
    catch e
        timedFprintf( 1, '%s\n', getReport(e) );
    end
end
