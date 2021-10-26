function setToolboxName( h )
    if isempty( h.mesh )
        msg = '(no mesh)';
    elseif isempty(h.mesh.globalProps.modelname)
        msg = '(untitled)';
    else
        msg = h.mesh.globalProps.modelname;
    end
    set( h.output, 'Name', [ 'Growth toolbox: ', msg ] );
end
