function [fig,m,projectsdir,modelname,handles] = GFtboxFindWindow()
%[fig,m,projectsdir,modelname,handles] = GFtboxFindWindow()
%   Find the GFtbox window, the current mesh, the full path name of its
%   project directory, and the gui handles.
%
%   If any of these fail to exist, the corresponding output arguments will
%   be empty.

    m = [];
    projectsdir = [];
    modelname = [];
    handles = [];
    fig = findall(0,'Type','figure','Tag','GFTwindow');
    if ~isempty(fig)
        handles = guidata(fig);
        if isfield( handles, 'mesh' )
            m = handles.mesh;
            if ~isempty(m)
                projectsdir = m.globalProps.projectdir;
                modelname = m.globalProps.modelname;
            end
        end
    end
end
