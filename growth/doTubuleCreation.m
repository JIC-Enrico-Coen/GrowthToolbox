function m = doTubuleCreation( m, dt )
%m = doTubuleCreation( m, dt )
%   Randomly create microtubules according to the distribution of creation
%   rate and the elapsed time.
%
%   The calculation also finds the creation time of each microtubule, but
%   this information is not currently used. It could be stored in each mt
%   and used to calculate the length of its first step.

    [creationPerVertex,cpvInterpMode] = leaf_getTubuleParamsPerVertex( m, 'creation_rate' );
    
    if all(creationPerVertex == 0)
        return;
    end
    
    creationPerFECorner = (perVertextoperFECorner( m, creationPerVertex, cpvInterpMode{1} ) .* m.cellareas )/3;
%     creationPerCorner = creationPerVertex( m.tricellvxs ) .* m.cellareas;
%     creationPerCorner = (creationPerVertex( m.tricellvxs ) .* m.cellareas )/3;
    totalcreationrate = sum(creationPerFECorner(:));
%     expectedcreation = totalcreationrate * dt;

    [requestednum,creationtimes] = poissevents( totalcreationrate, dt );
    grantednum = requestMTcreation( m, requestednum );
    if grantednum==0
        return;
    end
    creationtimes = creationtimes( randsubset( requestednum, grantednum ) );
    
    % Place the new microtubules randomly.
    [elementindexes,bcs] = randPointsOnSurface( m.nodes, m.tricellvxs, creationPerFECorner, [], [], [], [], [], grantednum );
    dirbc = zeros( grantednum, 3 );
    useDirectionField = getModelOption( m, 'edgecreaterate_perareasecond' ) > 0;
    spread = getModelOption( m, 'edgecreation_anglespread' );
    for i=1:grantednum
        vxsi = m.tricellvxs(elementindexes(i),:);
        vxs = m.nodes( vxsi, : );
        isInUpperPartOfCell = all( vxs(:,3) >= 0 );
        vxplanes = m.auxdata.planes(vxsi,:);
        isInTopOfCell = all( vxplanes(:,3) >= m.auxdata.numplanes(3) - m.auxdata.numedgeplanes(3) );
        isInBottomOfCell = all( vxplanes(:,3) <= m.auxdata.numedgeplanes(3) + 1 );
        isInTopBottomOfCell = isInTopOfCell || isInBottomOfCell;
        isInMiddlePartOfCell = all( vxplanes(:,3) <= m.auxdata.numplanes(3) - m.auxdata.numedgeplanes(3) ) ...
                                & all( vxplanes(:,3) >= m.auxdata.numedgeplanes(3) + 1 );
        if (~isInTopOfCell) && (~isInBottomOfCell)
            xxxx = 1;
        end
        if useDirectionField
            % This code is specific to the tubules model. It's bad to have
            % such code in GFtbox, but there was no alternative.
            normal = trinormal( vxs );
            normal = normal/norm(normal);
            if isInMiddlePartOfCell
                fieldDir = [1 0 0]; % Hard-wired horizontal direction.
            else
                fieldDir = [0 0 1]; % Hard-wired vertical direction.
            end
            fieldDir = projectToPlaneOfTwoVectors( fieldDir, vxs(2,:)-vxs(1,:), vxs(3,:)-vxs(1,:) );
            fieldDir = fieldDir/norm(fieldDir);
            if all(isfinite(fieldDir))
                fieldPerp = cross( fieldDir, normal );
                if isinf( spread ) || isnan( spread )
                    % Uniform distribution of initial directions over 360 degrees.
                    theta = (rand(1) - 0.5) * 2 * pi;
                elseif getModelOption( m, 'edgecreation_uniformToIO' )
                    towardsIO = rand(1) < 0.5;
                    if towardsIO
                        theta = (rand(1) - 0.5) * pi; % Uniform between +/- pi/2.
                    else
                        theta = randn(1) * spread; % Normal with mean 0 (i.e. perpendicular to edge) and std dev 'edgecreation_anglespread'.
                    end
                    if isInTopOfCell ~= towardsIO
                        theta = theta + pi;
                    end
                else
                    theta = randn(1) * spread;
                    if rand(1) < 0.5
                        % Toss a coin to decide between the two opposite directions.
                        theta = theta + pi;
                    end
                end
                theta = mod(theta,2*pi);
                c = cos(theta);
                s = sin(theta);
                v = c*fieldDir + s*fieldPerp;
                dirbc(i,:) = baryDirCoords( vxs, normal, v );
                if any(isnan(dirbc(i,:)))
                    xxxx = 1;
                end
            else
                dirbc(i,:) = randDirectionBC( vxs, 1 );
            end
        else
            dirbc(i,:) = randDirectionBC( vxs, 1 );
        end
    end
    m = leaf_createStreamlines( m, ...
            'elementindex', elementindexes, ...
            'barycoords', bcs, ...
            'directionbc', dirbc, ...
            'creationtimes', creationtimes );
end