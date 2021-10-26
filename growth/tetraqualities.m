function [badnesstype,auxdata,quality,volume] = tetraqualities( vxs, tetras )
%q = tetraquality( vxs, tetras )
%   VXS is a V*3 matrix holding a set of vertex positions.
%   TETRAS is a T*4 set of quadruples of indexes into VXS,
%   The result is a measure of the quality and the volume of every
%   tetrahedron.  The quality is 1 for a regular tetrahedron, and less than
%   that for any other.

%     numtetras = size(tetras,1);
%     vxs = vxs';
%     allpositions = reshape( vxs(:,tetras(:,2:4)'), 3, 3, numtetras ); % D x (T-1) x NT
%     allrefvxs = reshape( vxs(:,tetras(:,1)), 3, 1, numtetras ); % D x 1 x NT
%     alledges = allpositions - repmat( allrefvxs, 1, 3, 1 ); % D x (T-1) x NT

% Badness types:
% 1: a single short edge.
% 2: a single small face.
% 3: flat, two edges close to each other, and neither 1 nor 2.
% 4: thin, all vertexes near a straight line, and neither 1 nor 2.

    MINQUALITY = 0.1;
    SHORTEDGETHRESHOLD = 0.1;
    POINTLINETHRESHOLD = 0.1;
    numtetras = size(tetras,1);
    
    [volume,edgelengthsq,alledges] = tetravolume( vxs, tetras );
    maxedgelengthsq = max( edgelengthsq, [], 2 );
%     boxvol2 = maxedgelengthsq .^ 1.5;  % The cube of the longest edge length
%     quality = (1.414213562373*6)*abs(volume)./boxvol2;
%     quality = (2.0396489*(abs(volume).^(1/3)))./sqrt(maxedgelengthsq);
    % faceareas = sqrt(sum( crossproc2( edges([4 2 3 1],:), edges([5 3 1 2],:) ).^2, 2 ))/2';
    
    
    xx = permute( sqrt( sum( cross( alledges([1 2 3],:,:), alledges([6 5 4],:,:), 2 ).^2, 2 ) ), [3 1 2] );
    yy = max( xx, [], 2 );
    volume = abs(volume);
    d = 6*volume./yy;
%     quality2 = 0.69336127 * d ./ (volume.^(1/3));
    quality = 1.4142136 * (d./sqrt(maxedgelengthsq));





    lowqual = quality < MINQUALITY;
    if ~any(lowqual)
        badnesstype = zeros( numtetras, 1 );
        auxdata = zeros( numtetras, 4 );
        return;
    end
    
    tetras = tetras( lowqual, : );
    edgelengthsq = edgelengthsq(lowqual,:);
    alledges = alledges(:,:,lowqual);
    lqvolume = volume(lowqual);
    badnesstype = -ones( size(tetras,1), 1 );
    auxdata = zeros( size(tetras,1), 4 );
    
    [sortededgelengthsq,edgeperms] = sort( edgelengthsq, 2, 'descend' );
    edgeratios = sqrt( sortededgelengthsq(:,2:end) ./ sortededgelengthsq(:,1:(end-1)) );
    [minedgeratio,minedgeratioindex] = min( edgeratios, [], 2 );
    
    edgeends = [ 1 2
                 1 3
                 1 4
                 2 3
                 2 4
                 3 4 ];
    
    for ti=1:size(tetras,1)
        tetra = tetras(ti,:);
        tetravxs = vxs(tetra,:);
        edgelengthsq1 = edgelengthsq(ti,:);
        edges = alledges(:,:,ti);
        auxd = [0 0 0 0];
        if minedgeratio(ti) < SHORTEDGETHRESHOLD
            switch minedgeratioindex(ti)
                case 3
                    % Type 3.
                    badness = 3;
                    shortedges = edgeperms( ti, [4 5 6] );
                    auxd = [ unique( edgeends( shortedges, : ) )' 0];
                case 4
                    % Type 2.
                    badness = 2;
                    shortedges = edgeperms( ti, [5 6] );
                    pairs = edgeends( shortedges, : );
                    auxd = [ pairs(1,:) pairs(2,:) ];
                case 5
                    % Type 1, possibly type 5a.
                    badness = 15;
                    auxd = [ edgeends( edgeperms( ti, 6 ), : ) 0 0 ];
                otherwise
                    % Should never happen.
                    badness = -2;
            end
        else
            badness = -1;
        end
        switch badness
            case 2
                % No more to do.
            case 3
                % No more to do.
            otherwise
                % Test for type 5.
                [~,maxedgesqi] = max(edgelengthsq1);
                longedgeends = edgeends(maxedgesqi,:);
                othervxs = 1:4;
                othervxs(longedgeends) = [];
                [d1,~,bc1] = pointLineDistance( tetravxs(longedgeends,:), tetravxs(othervxs(1),:) );
                [d2,~,bc2] = pointLineDistance( tetravxs(longedgeends,:), tetravxs(othervxs(2),:) );
                if (d1 < POINTLINETHRESHOLD) && (d2 < POINTLINETHRESHOLD)
                    % Type 5, 5a, or 5b.
                    if badness==15
                        % Type 5a or 5b
                        bctype1 = classifyBC2( bc1 );
                        bctype2 = classifyBC2( bc2 );
                        if (bctype1==3) && (bctype2==3)
                            badness = 9;
                        else
                            if bctype1==3
                                othervxs = othervxs([2 1]);
                            end
                            if (bctype1==2) || (bctype2==2)
                                longedgeends = longedgeends([2 1]);
                            end
                            badness = 8;
                        end
                        auxd = [ longedgeends, othervxs ];
                    else
                        % Type 5
                        badness = 5;
                        if bc1(1) > bc2(1)
                            auxd = [ longedgeends, othervxs ];
                        else
                            auxd = [ longedgeends, othervxs([2 1]) ];
                        end
                    end
                else
                    switch badness
                        case 15
                            % Might be type 1, 5a, or 5b.
                            badness = 1;
                        case -1
                            % Should be type 4, 6, or 7.

                            % Find shortest altitude
                            faceareas = sqrt(sum( crossproc2( edges([4 2 3 1],:), edges([5 3 1 2],:) ).^2, 2 ))/2';
                            altitudes = (3 * abs(lqvolume(ti))) ./ faceareas;
                            [~,minalti] = min(altitudes);
                            othervxs = 1:4;
                            othervxs(minalti) = [];
                            p = tetravxs(minalti,:);
                            tetravxs(minalti,:) = [];
                            [~,bc] = projectPointToPlane( tetravxs, p );
                            % Classify each element of bc as +, -, or 0.
                            bctype = classifyBC( bc );
                            switch sort(bctype)
                                case '+++'  % Type 6 for this face.
                                    badness = 6;
                                    auxd = [ minalti 0 0 0 ];
                                case '+--'  % Type 6 for the face opposite the positive vertex.
                                    badness = 60;
                                    auxd = [ othervxs(bctype=='+') 0 0 0 ];
                                case '+-0'  % Type 7. The vertex is the positive vertex, and the edge joins the negative vertex and the fourth vertex.
                                    badness = 70;
                                    auxd = [ othervxs(bctype=='+'), othervxs(bctype=='-'), minalti, 0 ];
                                case '++0'  % Type 7. The vertex is the fourth and the edge joins the positive vertexes.
                                    badness = 7;
                                    auxd = [ othervxs(bctype=='+'), minalti, 0 ];
                                case '++-'  % Type 4.  The edges are from the fourth vertex to the negative vertex, and between the two positive vertexes.
                                    badness = 4;
                                    auxd = [ othervxs(bctype=='+'), othervxs(bctype=='-'), minalti ];
                                case '+00'  % Type 1.  The edge joins the fourth vertex and the 1 vertex.
                                    % This case should have already been detected by an
                                    % earlier test.
                                    badness = 1;
                                    auxd = [ othervxs(bctype=='+'), minalti, 0, 0 ];
                                otherwise
                                    % Should not happen.
                                    badness = -2;
                                    auxd = [ 0, 0, 0, 0 ];
                            end
                    end
                end
        end
        badnesstype(ti) = badness;
        auxdata(ti,:) = auxd;
    end
    
%     hasshortedges = minedgeratio < SHORTEDGETHRESHOLD;
%     badnesstype(hasshortedges) = 1;  % Might also be a (5).
%     badnesstype(hasshortedges & (minedgeratioindex > 1)) = 2;
%     
%     faceareas = permute( sqrt(sum( crossproc2( alledges([1 2 3 4],:,:), alledges([2 3 1 5],:,:) ).^2, 2 ))/2, [3 1 2] )
%     altitudes = (repmat( abs(lqvolume), 1, 4, 1 ) ./ faceareas) * 3
%     altqual = altitudes./sqrt(faceareas)
% %     a = tetraaltitudes( vxs, tetras )

    foo = zeros( numtetras, 1 );
    foo(lowqual) = badnesstype;
    badnesstype = foo;

    foo = zeros( numtetras, 4 );
    foo(lowqual,:) = auxdata;
    auxdata = foo;
    
    % Expected badnesstype is [ 0 1 2 3 4 5 8 9 6 7 ]
end

function bctype = classifyBC2( bc )
    BCTHRESHOLD = 0.1;
    if bc(1) < BCTHRESHOLD
        bctype = 1;
    elseif bc(2) < BCTHRESHOLD
        bctype = 2;
    else
        bctype = 3;
    end
    end

function bctype = classifyBC( bc )
    BCTHRESHOLD = 0.1;
    bctype = repmat( '0', 1, length(bc) );
    bctype(bc > BCTHRESHOLD) = '+';
    bctype(bc < -BCTHRESHOLD) = '-';
end

% function a = tetraaltitudes( vxs, tetras )
%     nt = size(tetras,1);
%     a = zeros(nt,4);
%     for i=1:nt
%         v = vxs(tetras(i,:),:);
%         a(i,1) = pointPlaneDistance( v([2 3 4],:), v(1,:) );
%         a(i,2) = pointPlaneDistance( v([1 3 4],:), v(2,:) );
%         a(i,3) = pointPlaneDistance( v([1 2 4],:), v(3,:) );
%         a(i,4) = pointPlaneDistance( v([1 2 3],:), v(4,:) );
%     end
%     a = abs(a);
% end
