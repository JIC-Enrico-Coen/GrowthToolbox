function [s,alloptions] = getGFtboxModelOptions()
%[s,alloptions] = getGFtboxModelOptions()
%   Like getModelOptions, but operates on the mesh currently loaded into
%   GFtbox. If there is no such mesh, returns s and all options as empty.

    m = getGFtboxMesh();
    if isempty(m)
        s = [];
        alloptions = [];
    else
        [s,alloptions] = getModelOptions( m );
    end

end