function r = getRotations( m, component )
%r = getRotations( m )
%   Compute for each finite element the rotation that best approximates the
%   displacements of its vertexes.

    if nargin < 2
        component = 'total';
    end
    if usesNewFEs(m)
        numFEtypes = length(m.FEsets);
        if numFEtypes==1
            numcells = size(m.FEsets(1).fevxs,1);
            r = zeros( numcells, 3 );
            if ~isempty( m.displacements )
                fevxs = m.FEsets(1).fevxs;
                for i=1:numcells
                    r(i,:) = bestRotation( m.FEnodes(fevxs(i,:),:), m.displacements(fevxs(i,:),:) )/m.globalProps.timestep;
                end
            end
        else
            % We don't handle this yet.
            error('%s: Heterogeneous FE meshes are not yet supported: %d types found.', numFEtypes );
        end
    else
        numcells = size(m.tricellvxs,1);
        r = zeros( numcells, 3 );
        if ~isempty( m.displacements )
            for i=1:numcells
                trivxs = m.tricellvxs(i,:);
                t2 = trivxs*2;
                prismvxs = [ t2-1, t2 ];
                r(i,:) = bestRotation( m.prismnodes(prismvxs,:), m.displacements(prismvxs,:) )/m.globalProps.timestep;
            end
            switch component
                case 'total'
                    % Nothing.
                case 'inplane'
                    inplanesize = dot( r, m.unitcellnormals, 2 );
                    r = m.unitcellnormals .* repmat( inplanesize, 1, 3 );
                case 'outofplane'
                    inplanesize = dot( r, m.unitcellnormals, 2 );
                    inplane_r = m.unitcellnormals .* repmat( inplanesize, 1, 3 );
                    r = r - inplane_r;
            end
        end
    end
end
