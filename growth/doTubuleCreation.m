function m = doTubuleCreation( m, dt )
%m = doTubuleCreation( m, dt )
%   Randomly create microtubules according to the distribution of creation
%   rate and the elapsed time.
%
%   The calculation also finds the creation time of each microtubule, but
%   this information is not currently used. It could be stored in each mt
%   and used to calculate the length of its first step.

    ease_of_creation = limitMTcreation( m );
    creationPerVertex = leaf_getTubuleParamsPerVertex( m, 'creation_rate' ) * ease_of_creation;
    
    if all(creationPerVertex == 0)
        return;
    end
    
    creationPerCorner = creationPerVertex( m.tricellvxs ) .* m.cellareas;
    totalcreationrate = sum(creationPerCorner(:))/3;
%     expectedcreation = totalcreationrate * dt;

%     creationtimes = randArrivals( totalcreationrate, dt );
    [numtocreate,creationtimes] = poissevents( totalcreationrate, dt );
    if numtocreate==0
        return;
    end
    
%     numtocreate = length(creationtimes); % poissrnd( expectedcreation );

    % Place the new microtubules randomly.
    [elementindexes,bcs] = randPointsOnSurface( m.nodes, m.tricellvxs, creationPerCorner, [], [], [], [], [], numtocreate );
    dirbc = zeros( numtocreate, 3 );
    for i=1:numtocreate
        vxs = m.nodes( m.tricellvxs(elementindexes(i),:), : );
        dirbc(i,:) = randDirectionBC( vxs, 1 );
    end
%     dirbc = randomDirectionBC( numtocreate );
    m = leaf_createStreamlines( m, ...
            'elementindex', elementindexes, ...
            'barycoords', bcs, ...
            'directionbc', dirbc, ...
            'creationtimes', creationtimes );
end