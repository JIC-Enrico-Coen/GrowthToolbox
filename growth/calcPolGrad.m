function m = calcPolGrad( m, fes )
%m = calcPolGrad( m, fes )
%   Calculate the polarising gradient in the specified elements of the mesh,
%   by default all of them.

    if size( m.morphogens, 2 ) < 3
        return;
    end
    
    if m.globalProps.userpolarisation
        return;
    end
    
    [pol_mgen,pol_mgen2] = polariserIndex( m );
    polariser = getEffectiveMgenLevels( m, pol_mgen );
    if pol_mgen2==0
        polariser2 = [];
    else
        polariser2 = getEffectiveMgenLevels( m, pol_mgen2 );
        if ~isfield( m, 'gradpolgrowth2' )
            % Temporary hack, because some meshes were not being created
            % with this field.
            m.gradpolgrowth2 = zeros( size( m.gradpolgrowth ) );
        end
    end
    
    if all(polariser==0) && all(polariser2==0)
        % Should set unfrozen gradients to zero?
        return;
    end
    
    bipolar = m.globalProps.twosidedpolarisation;
    numpol = size( m.gradpolgrowth, 3 );
        
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
        fes = (1:numcells)';
    else
        fes = fes(:);
    end
    if size(m.polsetfrozen,1)==1
        fluidgrads = repmat( ~m.polsetfrozen, length(fes), 1 );
    else
        fluidgrads = ~m.polsetfrozen(fes,:);
    end
    
    if any( fluidgrads(:) )
        rawgrad = mgenCellGradient( m, pol_mgen, fes );
        rawgradsq = sum( rawgrad.^2, 2 );
        if m.globalProps.relativepolgrad
            polFE = perVertextoperFE( m, polariser, 'mid', fes );
            thresholdgrads = (polFE .* m.globalProps.mingradient).^2;
        else
            thresholdgrads = m.globalProps.mingradient.^2;
        end
        if bipolar
            if size(thresholdgrads,1)==length(rawgradsq)
                thresholdgrads = repmat( thresholdgrads, 1, numpol );
            end
            rawgradsq = repmat( rawgradsq, 1, numpol );
        end
        fluidgrads = fluidgrads & (rawgradsq >= thresholdgrads);
    end
    
    if full3d
        % Need to implement freezing for this also.
        m.gradpolgrowth2 = mgenCellGradient( m, polariser2, fes );
    end
    
    if any(fluidgrads(:))
        for pi=1:numpol
            bigcis_oneside = fes(fluidgrads(:,pi));
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
        smallcis = fes(~fluidgrads(:,layer));
        if m.globalProps.usefrozengradient && ~isempty(smallcis)
            for ci=smallcis(:)'
                vxs = fevxs(ci,:);
                if m.globalProps.usepolfreezebc
                    m.gradpolgrowth( ci, :, layer ) = bc2vec( m.polfreezebc(ci,:, layer), fenodes( vxs, : ) );
                else
                    m.gradpolgrowth( ci, :, layer ) = -trianglegradient( fenodes( vxs, : ), m.polfreeze(ci,:, layer) );
                end
            end
        else
            m.gradpolgrowth( smallcis, :, layer ) = 0;
        end
        if any( m.polfrozen(fes,layer) ~= ~fluidgrads(:,layer) )
            xxxx = 1;
        end
        m.polfrozen(fes,layer) = ~fluidgrads(:,layer);
    end
end
