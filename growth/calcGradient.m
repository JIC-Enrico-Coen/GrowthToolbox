function grad = calcGradient( m, scalar, cis )
%m = calcGradient( m, scalar, cis )
%   Calculate the gradient of a scalar field defined on the vertexes of the
%   mesh, in each of the specified cells of the mesh, by default all of
%   them.
%
%   NOT USED, INCOMPLETE

    if isempty(cis)
        grad = zeros(0,3);
        return;
    end
    
    if all(polariser==0)
        grad = zeros( length(cis), 3 );
        return;
    end
    
        
    full3d = usesNewFEs( m );
    if full3d
        fenodes = m.FEnodes;
        fevxs = m.FEsets(1).fevxs;
    else
        fenodes = m.nodes;
        fevxs = m.tricellvxs;
    end
    numcells = size( fevxs, 1 );


    if nargin < 2
        cis = (1:numcells)';
    else
        cis = cis(:);
    end
    
    if any(fluidgrads(:))
        for pi=1:numpol
            bigcis_oneside = cis(fluidgrads(:,pi));
            m.gradpolgrowth( bigcis_oneside, :, pi ) = rawgrad( fluidgrads(:,pi), : );
%         m.gradpolgrowth( bigcis, : ) = repmat( rawgrad( fluidgrads, : ), 1, 1, numpol );
            if full3d
                m.polfreeze( bigcis_oneside, :, pi ) = polariser( fevxs(bigcis_oneside,:) );
            else
                m.polfreeze( bigcis_oneside, :, pi ) = reshape( ...
                                                polariser( fevxs(bigcis_oneside,:) ), ...
                                                length(bigcis_oneside), ...
                                                size(fevxs,2) );
                for i=1:length(bigcis_oneside)
                    ci = bigcis_oneside(i);
                    m.polfreezebc(ci,:,pi) = vec2bc( m.gradpolgrowth( ci, :, pi ), ...
                                                     fenodes( fevxs(ci,:), : ), ...
                                                     m.unitcellnormals(ci,:) );
                end
                m.polfreezebc = procrustesHeight( m.polfreezebc, numcells );
            end
        end
        m.polfreeze = procrustesHeight( m.polfreeze, numcells );
    end
    
    
    for layer=1:numpol
        smallcis = cis(~fluidgrads(:,layer));
        if m.globalProps.usefrozengradient && ~isempty(smallcis)
            for ci=smallcis(:)'
                vxs = fevxs(ci,:);
                if m.globalProps.usepolfreezebc
                    m.gradpolgrowth( ci, :, layer ) = bc2vec( m.polfreezebc(ci,:,layer), fenodes( vxs, : ) );
                else
                    m.gradpolgrowth( ci, :, layer ) = -trianglegradient( fenodes( vxs, : ), m.polfreeze(ci,:, layer) );
                end
            end
        else
            m.gradpolgrowth( smallcis, :, layer ) = 0;
        end
        if any( m.polfrozen(cis,layer) ~= ~fluidgrads(:,layer) )
            xxxx = 1;
        end
        m.polfrozen(cis,layer) = ~fluidgrads(:,layer);
    end
end
