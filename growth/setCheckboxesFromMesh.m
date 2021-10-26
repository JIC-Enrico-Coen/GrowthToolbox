function setCheckboxesFromMesh( h, names )
    setGlobals();
    global gGlobalProps
    if isempty( h.mesh )
        if ischar(names)
            set( h.(names), 'Value', gGlobalProps.(names) );
        else
            for i=1:length(names)
                set( h.(names{i}), 'Value', gGlobalProps.(names{i}) );
            end
        end
    else
        if ischar(names)
            set( h.(names), 'Value', h.mesh.globalProps.(names) );
        else
            for i=1:length(names)
                set( h.(names{i}), 'Value', h.mesh.globalProps.(names{i}) );
            end
        end
    end
end
