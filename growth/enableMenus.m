function enableMenus( handles )
%enableMenus( handles )
%   Set the enabled/disabled state of every menu and menu item, depending
%   on the state of the simulation.

%   Perhaps we should have this do the same for all the GUI elements, and
%   rename it to setEnableGUI.

    havemesh = ~isempty( handles.mesh );
    enableHandle( ...
        [ handles.savematItem, ...
          ... % handles.savescriptItem, ...
          handles.saveobjItem, ...
          handles.savefigItem ], ...
        havemesh );
    enableHandle( handles.stagesMenu, havemesh );
    enableHandle( handles.exportMeshItem, havemesh );
    enableHandle( handles.addFrameItem, ...
        havemesh && movieInProgress(handles.mesh) );
end
