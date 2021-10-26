function handles = selectDefaultProjectsMenu( handles, defaultDir )
% Search for a given directory on the Projects menu and colour the menu items
% accordingly.

    if nargin < 2
        defaultDir = '';
    else
        handles.userProjectsDir = defaultDir;
    end
    if ~isempty(defaultDir)
        updateProjectMenuHighlights( handles, defaultDir );
    end

