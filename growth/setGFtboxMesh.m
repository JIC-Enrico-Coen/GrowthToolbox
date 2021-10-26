function setGFtboxMesh( m )
%setGFtboxMesh( m )
%   Load the mesh m into GFtbox.

    [fig,~,projectsdir,modelname,handles] = GFtboxFindWindow();
    if ~isempty(fig)
        m.globalProps.projectdir = projectsdir;
        m.globalProps.modelname = modelname;
        handles.mesh = m;
        guidata( fig, handles );
    end
end
