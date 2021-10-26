function enableMutations( h, allowMutations )
    if nargin < 2
        if isempty( h.mesh )
            allowMutations = 'on';
        elseif h.mesh.globalDynamicProps.currentIter==0
            allowMutations = 'on';
        else
            allowMutations = 'off';
        end
    end
    allowMutations = 'on';
    set( h.mutantslider, 'Enable', allowMutations );
    set( h.mutanttext, 'Enable', allowMutations );
    set( h.allWildcheckbox, 'Enable', allowMutations );
end
