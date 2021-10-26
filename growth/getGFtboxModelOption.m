function [v,vs] = getGFtboxModelOption( optionname )
%[v,vs] = getGFtboxModelOption( optionname )
%   Like getModelOption, but operates on the mesh currently loaded into
%   GFtbox. If there is no such mesh, returns v and vs as empty.

    m = getGFtboxMesh();
    if isempty(m)
        v = [];
        vs = [];
    else
        if isfield( m, 'modeloptions' )
            options = m.modeloptions;
        else
            options = m.userdata.ranges;
        end
        [v,vs] = getOption( options, optionname );
    end
end