function [done,h] = attemptCommand( h, needsStop, replot, cmd, varargin )
%attemptCommand( h, i, cmd, varargin )
%   If there is no current mesh, do nothing.
%
%   If there is a mesh and the simulation is not running, execute the specified
%   command CMD(VARARGIN{:}).  If REPLOT is true, redraw the mesh.
%
%   If the simulation is running, and NEEDSSTOP is false, add the command to
%   the command queue.  If NEEDSSTOP is true, ask for confirmation, and
%   if given, also set the stop flag.

    done = true;
  % if isempty( h.mesh ), return; end

    if get( h.runFlag, 'Value' )==0
        set(h.GFTwindow,'Pointer','arrow');
%         set(h.picture,'Pointer','arrow');
      % fprintf( 1, 'Command %s immediate execution.\n', cmd );
        startTic = startTimingGFT( h );
        h.mesh = scriptcommand( h.mesh, cmd, varargin{:} );
        stopTimingGFT(['leaf_' cmd],startTic);
        guidata( h.output, h );
        if replot
            updateGUIFromMesh( h );
            notifyPlotChange( h );
            h = guidata( h.output );
        end
        announceSimStatus( h );
        clearFlag( h, 'stopFlag' );
    else
        done = false;
      % fprintf( 1, 'Command %s request while simulation running.\n', cmd );
        if needsStop
            answer = questdlg('Stop current simulation?', ...
                               '', ...
                               'Yes','No','No' );
            if strcmp(answer,'Yes')
                addCommandToGUIElement( h.commandFlag, cmd, true, varargin );
                set( h.stopFlag, 'Value', 1 );
            end
        else
            addCommandToGUIElement( h.commandFlag, cmd, true, varargin );
            if replot
                notifyPlotChange( h );
            end
        end
    end
end
