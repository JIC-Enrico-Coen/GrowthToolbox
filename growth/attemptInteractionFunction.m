function [m,ok] = attemptInteractionFunction( m )
    m.globalProps.interactionValid = true;
    ok = true;
    if m.globalProps.allowInteraction && isa(m.globalProps.mgen_interaction,'function_handle')
        m.saved = 0;
        if m.rewriteIFneeded
            [m,ok] = rewriteInteractionSkeleton( m, '', '', mfilename() );
        end
        if ~ok
            % Nothing.  Carry on anyway.
        end
        olddir = goToProjectDir( m );
        fprintf( 1, 'Calling interaction function.\n' );
        if isinteractive(m)
            h = ancestor(m.pictures(1),'figure');
            catchInteractionExceptions = isappdata( h, 'catchIFExceptions' ) ...
                                         && getappdata( h, 'catchIFExceptions' );
        else
            catchInteractionExceptions = false;
        end
        if catchInteractionExceptions
            try
                m = dointeraction( m );
            catch
                fprintf( 1, '%s: Interaction function raised an exception:\n', mfilename() );
                simpleExceptionMessage();
                fprintf( 1, 'Interaction disabled.  Simulation terminated.\n' );
                m.globalProps.interactionValid = false;
                m.stop = true;
                ok = false;
            end
        else
            m = dointeraction( m );
        end
        if isinteractive(m)
            indicateInteractionValidity( guidata(m.pictures(1)), ok );
            updateGUIFromMesh( m );
        end
        if ~isempty(olddir), cd( olddir ); end
    elseif isa(m.globalProps.mgen_interaction,'function_handle')
        fprintf( 1, 'Interaction function disabled.\n' );
    else
        fprintf( 1, 'No interaction function to call.\n' );
    end
end

function m = dointeraction( m )
    m = m.globalProps.mgen_interaction( m );
    m = calcPolGrad( m );
    m = makeCellFrames( m );
    m.globalProps.allowsave = 0;
    m = updateValidityTime( m, m.globalDynamicProps.currenttime );
end
