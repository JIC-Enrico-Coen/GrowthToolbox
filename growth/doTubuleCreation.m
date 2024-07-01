function m = doTubuleCreation( m, dt )
%m = doTubuleCreation( m, dt )
%   Randomly create microtubules according to the distribution of creation
%   rate and the elapsed time.
%
%   The calculation also finds the creation time of each micsrotubule, but
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
        vxs = m.nodes( m.tricellvxs(elementindexes(i),:), : );
        if useDirectionField
            normal = trinormal( vxs );
            normal = normal/norm(normal);
            fieldDir = [0 0 1];
            fieldDir = projectToPlaneOfTwoVectors( fieldDir, vxs(2,:)-vxs(1,:), vxs(3,:)-vxs(1,:) );
            fieldDir = fieldDir/norm(fieldDir);
            if all(isfinite(fieldDir))
                fieldPerp = cross( fieldDir, normal );
                theta = randn(1) * spread;
                if rand(1) < 0.5
                    theta = theta + pi;
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