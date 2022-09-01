function [m,s,extended,remaininglength,lengthgrown] = extrapolateStreamline( m, s, maxlength, noncolliders, recursive )
%[m,s,extended,remaininglength,lengthgrown] = extrapolateStreamline( m, s, maxlength, noncolliders, recursive )
%   Extrapolate the streamline s in the direction it is currently going in
%   until it hits an edge of an FE containing its current point.
%
%   If its current point is already on an edge of the current FE, and its
%   direction takes it over that edge, then nextci is the index of the FE
%   that it moves into. Otherwise, nextci is the same as the current FE. In
%   both cases, nextbc1 is the barycentric coordinates of the current
%   endpoint in the element nextci.
%
%   If the current point is at a vertex, then the streamline will be
%   continued across that vertex into another element. It is possible that
%   the chosen element will not share any edges with the current element.
%
%   nextbc is the barycentric coordinates of the extension of s across
%   nextci.
%
%   v is the global coordinates of the new point.
%
%   dirglobal is the direction of the added segment, in global
%   coordinates.
%
%   dirbc is the direction of the added segment, in barycentric
%   coordinates of nextci.
%
%   If the streamline needs to cross an edge, but it is a boundary edge,
%   then all the results are returned as empty.
%
%   v is the global coordinates of the new point.

    if nargin < 5
        recursive = false;
    end

    if ~validStreamline( m, s )
        BREAKPOINT( 'Invalid streamline.\n' );
    end
    
    extended = false;
    remaininglength = maxlength;
    
    ci = s.vxcellindex(end);
    bc = trimbc( s.barycoords(end,:) );
    dirbc = s.directionbc;
    if any(isnan(dirbc))
        error( '%s: invalid direction [%f %f %f]', mfilename(), dirbc );
    end
    if abs(sum(dirbc)) > 0.1
        warning( 'invalid direction [%f %f %f]', dirbc(1), dirbc(2), dirbc(3) );
        xxxx = 1;
    end
    
    % Determine the direction in which the microtubule is growing.
    if isempty(dirbc)
        % Get direction from polariser.
        dirglobal = normalisedGradient( m, ci, s.downstream );
        if all(dirglobal==0)
            % No direction.  Streamline cannot be continued.
            return;
        end
        % Convert dirglobal to bary coords
        dirbc = vec2bc( dirglobal, m.nodes( m.tricellvxs(ci,:), : ) );
        s.directionbc = dirbc;
        s.directionglobal = dirglobal;
        if ~checkZeroBcsInStreamline( s )
            xxxx = 1;
        end
    else
        if isempty(s.directionglobal)
            s.directionglobal = streamlineGlobalDirection( m, s );
        end
        dirglobal = s.directionglobal;
    end
    
    % If the microtubule is curved, modify the direction accordingly.
    MAXANGLEPERSTEP = 0.1;
    
    if m.tubules.tubuleparams.curvature ~= 0
        curvature = m.tubules.tubuleparams.curvature;
    else
        % This code is not good. GFtbox code should never refer to the
        % model options nor to m.userdata. But I was in a hurry and there
        % was not the time to do this right.
        edge_alignment = getModelOption( m, 'edge_alignment' );
        if isempty(edge_alignment) || (edge_alignment==0) || ~isfield( m.userdata, 'edgedirection' )
            curvature = 0;
        else
            edgedir = unique( m.userdata.edgedirection( m.tricellvxs(ci,:) ) );
            if (length(edgedir) > 1) || (edgedir(1)==0)
                curvature = 0;
            else
                edgevec = [0 0 0];
                edgevec( edgedir ) = 1;
                [incidenceAngle,lateralCurveAxis,rotmat] = vecangle( edgevec, s.directionglobal ); % Did have args other way round, but seemed to give wrong sense.
                localCurvature = 1/m.meshparams.edgeradius( edgedir );
                curvature = edge_alignment * localCurvature * sin(incidenceAngle)^3 * cos(incidenceAngle);
                xxxx = 1;
            end
        end
    end
    curvelengthbound = MAXANGLEPERSTEP/abs(curvature);
    maxlength = min( maxlength, curvelengthbound );
    if (curvature ~= 0) && ~isempty( s.segmentlengths )
        % Correct dirglobal by curvature. The turning angle is limited to avoid numerical errors.
        % The length of the previous segment, from which the turning angle
        % is calculated, should have been short enough that MAXANGLEPERSTEP
        % is not exceeded, but we use the bound here just to make sure.
        angle = curvature * s.segmentlengths(end);
        if abs(angle) > MAXANGLEPERSTEP
            xxxx = 1;
            angle = sign(angle) * min( abs(angle), MAXANGLEPERSTEP );
        end
        trivxs = m.tricellvxs( s.vxcellindex(end), : );
        pointnormal = s.barycoords(end,:) * m.vertexnormals( trivxs, : );
        r = axisAngle2RotMat( pointnormal, angle );
        dirglobal1 = dirglobal*r;
        % Force dirglobal to lie within the element
        facenormal = trinormal( m.nodes( trivxs, : ) );
        dirglobal2 = dirglobal1 - pointnormal * dot(dirglobal1,pointnormal)/norm(pointnormal);
%         deflection = dirglobal2 - dirglobal
        dirglobal = dirglobal2;
        dirbc = vec2bc( dirglobal, m.nodes( trivxs, : ) );
        s.directionbc = dirbc/norm(dirbc);
        s.directionglobal = streamlineGlobalDirection( m, s );
        xxxx = 1;
    end
    
    pointsOut3 = ((bc <= 0) & (dirbc < 0)) | ((bc >= 1) & (dirbc > 0));
    pointsOut = any( pointsOut3 );
    whichvertex = find( bc >= 1, 1 );
    if isempty(whichvertex)
        whichedge = find( bc==0, 1 );
    else
        whichedge = [];
    end
    
    if pointsOut
        % We will do no growth in this call of extrapolateStreamline.
        % Either the tubule catastrophises immediately, or we transfer its
        % endpoint to the element it is about to move into, then call
        % extrapolateStreamline recursively to continue the growth.
        lengthgrown = 0;
        
        % Determine whether the mt should catastrophise, according to the
        % tubuleparams.edge_plus_catastrophe property. If this is a single
        % number, that is the probability. Otherwise it specifies a number
        % (possibly NaN) per vertex. If the mt has run into a vertex, the
        % value for that vertex is the probability of catastrophe. If it
        % has run into an edge, the probability is the probabilities at the
        % ends, weighted by the corresponding bcs. If the resulting
        % probability is NaN, this is equivalent to zero.
        
        edge_plus_catastrophe = m.tubules.tubuleparams.edge_plus_catastrophe;
        if ischar( edge_plus_catastrophe )
            % The property is specified by a morphogen. Get the morphogen's
            % values.
            [~,edge_plus_catastrophe] = getMgenLevels( m, edge_plus_catastrophe );
        end
        if numel( edge_plus_catastrophe )==1
            % A single value is the probability to use everywhere.
            prob_edge_catastrophe = edge_plus_catastrophe;
        else
            % Otherwise there is assumed to be one value per vertex.
            if ~isempty(whichvertex)
                prob_edge_catastrophe = edge_plus_catastrophe( m.tricellvxs( ci, whichvertex ) );
            elseif ~isempty(whichedge)
                civxs = othersOf3( whichedge );
                edgevxs = m.tricellvxs( ci, civxs );
                prob_per_edgevx = edge_plus_catastrophe( edgevxs );
                if any( isnan(prob_per_edgevx) )
                    prob_edge_catastrophe = 0;
                else
                    bc_per_edgevx = bc(civxs);
                    prob_edge_catastrophe = sum( prob_per_edgevx(:) .* bc_per_edgevx(:) );
                end
            end
        end
        if isnan(prob_edge_catastrophe)
            prob_edge_catastrophe = 0;
        end
        does_edge_cat = rand(1) < prob_edge_catastrophe;
        
        if does_edge_cat
            % Catastrophise now.
            [m,s,stopped] = stopStreamline( m, s, 3 );
            remaininglength = 0;
        else
            % Cross over to the next element, then call this procedure again.

            if recursive
                % This is an error.
                fprintf( 1, '%s: recursive call not allowed.\n', mfilename() );
                xxxx = 1;
                return;
            end

            atvertex = any(bc >= 1);

            if ~atvertex
                % Find which edge.
                k1i = find( bc <= 0, 1 );
                ei = m.celledges(ci,k1i);
        %         fprintf( 1, '%s: hit edge %d in element %d\n', mfilename(), ei, ci );
                cis = m.edgecells(ei,:);
                newci = cis(cis ~= ci);
                if newci==0
                    % We hit a border. No more to do.
        %             fprintf( 1, '%s: hit border edge\n', mfilename() );
                else
                    % Transfer the direction and the final point to the element on
                    % the other side of the edge, then call this procedure again.

        %             oldpoint = streamlineGlobalPos( m, s, length(s.vxcellindex) );
                    old_s_directionbc = s.directionbc;
                    old_s_cs = s.barycoords(end,:);
                    [s.barycoords(end,:),s.directionbc] = transferDirection( m, ci, bc, s.directionbc, newci );
                    if ~checkZeroBcsInStreamline( s )
                        xxxx = 1;
                    end
                    % Check that old and new bcs represent the same point.
        %             newpoint = streamlineGlobalPos( m, s, length(s.vxcellindex) );

                    s.vxcellindex(end) = newci;
                    s.segcellindex(end) = newci;
                    s.directionglobal = streamlineGlobalDirection( m, s );
                    if any(isnan(s.directionglobal))
                        s.directionglobal = [0 0 0];
                    end

                    [m1,s1,extended,remaininglength,lengthgrown] = extrapolateStreamline( m, s, maxlength, noncolliders, true );
                    m = m1;
                    s = s1;
                end
            else
                % Project the direction and all the edges that meet at this vertex
                % onto the plane perpendicular to the vertex normal. Find which two
                % edges the direction lies between and continue in that element.

                k1i = find( bc >= 1, 1 );
                vi = m.tricellvxs( ci, k1i );
        %         fprintf( 1, '%s: hit vertex %d in element %d\n', mfilename(), vi, ci );

                nce = m.nodecelledges{ vi };
                vxnormal = m.vertexnormals( vi, : );
                vxnormal = vxnormal/norm(vxnormal);
                vxedgeends = m.edgeends( nce(1,:), : );
                othervxs = vxedgeends(:,1)==vi;
                vxedgeends(othervxs,1) = m.edgeends( nce(1,othervxs), 2 );
                vxedgeends(:,2) = [];
                edgevecs = m.nodes( vxedgeends, : ) - repmat( m.nodes( vi, : ), length(vxedgeends), 1 );
                [xx,yy,zz] = makeframe( vxnormal, dirglobal );
                rotmat = [zz;xx;yy];
                    % yy is parallel to vxnormal (in fact equal to it up to rounding error).
                    % zz is parallel to the projection of dirglobal perpendicular
                    % to vxnormal.
                    % xx is their common perpendicular.
                planeedgevecs = edgevecs/rotmat;
                planedir = dirglobal/rotmat;
                edgeheadings = atan2( planeedgevecs(:,2), planeedgevecs(:,1) );
                dirheading = atan2( planedir(2), planedir(1) ); % Should be zero up to rounding error.

                [~,minheadingi] = min( edgeheadings );
                eh1 = edgeheadings( [minheadingi:end, 1:minheadingi] );
                eh1(end) = eh1(end) + 2*pi;
                ehi1 = minheadingi - 2 + find( dirheading < eh1, 1 );
                ehi1 = mod( ehi1-1, length(edgeheadings) ) + 1;
                ehi2 = mod( ehi1, length(edgeheadings) ) + 1;
    %             if ehi1 > length(edgeheadings)
    %                 ehi1 = 1;
    %             end
    %             ehi2 = ehi1+1;
    %             if ehi2==0
    %                 ehi2 = length(edgeheadings);
    %             elseif ehi2 > length(edgeheadings)
    %                 ehi2 = 1;
    %             end
    % 
    %             if ehi1 > size(nce,2)
    %                 xxxx = 1;
    %             end
                nextci = nce(2,ehi1);

                if nextci==0
                    % Goes outside the mesh. Streamline stops here.
        %             fprintf( 1, '%s: hit border vertex\n', mfilename() );
                else
                    % Find vi in nextci
                    cvi = find( m.tricellvxs(nextci,:)==vi, 1 );
        %             oldpoint = streamlineGlobalPos( m, s, length(s.vxcellindex) );
                    s.barycoords(end,:) = [0 0 0];
                    s.barycoords(end,cvi) = 1;
                    % Check that old and new bcs represent the same point.
        %             newpoint = streamlineGlobalPos( m, s, length(s.vxcellindex) );
                    s.vxcellindex(end) = nextci;
                    edgevec1 = edgevecs(ehi1,:);
                    edgevec2 = edgevecs(ehi2,:);
                    ev12 = cross( edgevec1, edgevec2 );
                    dirrotangle = atan2( dot( zz, ev12 ), dot( vxnormal, ev12 ) );
                    mat = axisAngle2RotMat( xx, dirrotangle );
                    newdirectionglobal = zz * mat;
        %             checkRotatedDirection = det( [newdirectionglobal; edgevec1; edgevec2] )
                    s.directionglobal = newdirectionglobal;
                    s.directionbc = vec2bc( s.directionglobal, m.nodes( m.tricellvxs(nextci,:), : ) );
        %             fprintf( 1, '%s: passed through vertex %d to element %d\n', mfilename(), vi, nextci );
                    if ~checkZeroBcsInStreamline( s )
                        xxxx = 1;
                    end
                    [m,s,extended,remaininglength,lengthgrown] = extrapolateStreamline( m, s, maxlength, noncolliders, true );
                end
            end
        end
    else
        % The growth direction points within the element. Extrapolate it
        % until an "event" happens. "Events" are:
        % * The amount of growth to be done is completed.
        % * If there is curvature, the angular deviation over the length
        %   grown reaches MAXANGLEPERSTEP
        % * It continues unobstructed to the edge.
        % * It has a spontaneous catastrophe.
        % * It spontaneously stops.
        % That is the furthest point to which it can be grown. We then
        % check to see if it collides with a microtubule or bundle of
        % microtubules before then.
        

        k = -bc(dirbc<0)./dirbc(dirbc<0);
        k(isnan(k) | (k<0)) = Inf;
        k1 = min(k);
        % k1 must be > 0.
        % New point has bcs bc+k1*dirbc.
        if recursive
            xxxx = 1;
        end
        s.segcellindex(end+1) = ci;
        s.vxcellindex(end+1) = ci;
        s.barycoords(end+1,:) = trimbc( bc + k1*dirbc );
        if ~checkZeroBcsInStreamline( s )
            xxxx = 1;
        end
        vx1 = streamlineGlobalPos( m, s, length(s.vxcellindex)-1 );
        vx2 = streamlineGlobalPos( m, s, length(s.vxcellindex) );
        lengthgrown = norm(vx2-vx1);
        if lengthgrown > maxlength
            dirbc = dirbc*maxlength/lengthgrown;
            s.barycoords(end,:) = trimbc( bc + k1*dirbc );
            if ~checkZeroBcsInStreamline( s )
                xxxx = 1;
            end
            lengthgrown = maxlength;
        end
                
        % Calculate whether there was a spontaneous stopping or
        % catastrophising before lengthgrown.
        if lengthgrown > 0
            params = getTubuleParamsModifiedByMorphogens( m, s );
            timeused = lengthgrown/params.plus_growthrate;
            nextstop = sampleexp( params.prob_plus_stop );
            nextcat = sampleexp( params.prob_plus_catastrophe );
            if (nextcat <= 0) || isnan(nextcat) || any(isinf(params.prob_plus_catastrophe)) || any(isnan(params.prob_plus_catastrophe))
                xxxx = 1;
            end
            [timetoevent,stoppingreason] = min( [timeused, nextstop, nextcat] );
            % stoppingreason is 1 if no stop or cat, 2 if stop, 3 if cat.
            if timetoevent < timeused
                % Adjust the final point of s.
                frac = timetoevent/timeused;
                if frac <= 0
                    % Undo the adding of the last vertex.
                    s.segcellindex(end) = [];
                    s.vxcellindex(end) = [];
                    s.barycoords(end,:) = [];
                else
                    s.barycoords(end,:) = trimbc( bc + frac*k1*dirbc );
                end
                if ~checkZeroBcsInStreamline( s )
                    xxxx = 1;
                end
                lengthgrown = frac*lengthgrown;
            end
        else
            stoppingreason = 0;
        end
        remaininglength = maxlength - lengthgrown;
        
        previousEvent = false;
        
%         fprintf( 1, '%s: direction points inward, remaining length %g\n', mfilename(), remaininglength );
        MINLENGTHGROWN = 1e-5;
        if lengthgrown <= 0
            collidedwith = [];
            collideseg = [];
            collidedsegbc = [];
            collidersegbc = [];
            collisiontype = [];
            collisionangle = [];
            iscross = [];
            switch stoppingreason
                case 2
                    s.status.head = 0;
                    m.tubules.statistics.spontaneousstop = m.tubules.statistics.spontaneousstop + 1;
                case 3
                    s.status.head = -1;
                    m.tubules.statistics.spontaneouscatastrophe = m.tubules.statistics.spontaneouscatastrophe + 1;
            end
            remaininglength = 0;
        else
            if lengthgrown <= MINLENGTHGROWN
                xxxx = 1;
            end
            s.globalcoords( length(s.vxcellindex), : ) = streamlineGlobalPos( m, s, length(s.vxcellindex) );
            s.segmentlengths( length(s.vxcellindex)-1 ) = lengthgrown;
            extended = true;
            lengthgrown1 = s.segmentlengths(end);
            if abs(lengthgrown1 - lengthgrown1) > 1e-9
                xxxx = 1;
            end
            % Next we detect collisions. These are the possible results of a
            % collision:
            % 1. Catastrophe. The colliding microtubule stops at the collision
            %    and then shrinks from its head.
            % 2. Zippering. If the angle between the two mts is sufficiently
            %    small, the colliding mt may change direction to run alongside
            %    the collided-with.
            % 3. Crossover. Growth carries on across the other microtubule.
            % In the case of crossover, there is a probability of the
            % crossed-over mt being severed there after a delay, and
            % independently, a probability of that happening to the crossing
            % mt.
            % The probabilities of these outcomes are determined by the
            % streamline parameters
            % prob_collide_catastrophe_shallow, prob_collide_catastrophe_steep
            % prob_collide_zipper_shallow, prob_collide_zipper_steep, and
            % prob_collide_cut, together with morphogens designated to provide
            % per-vertex modification.

            [collidedwith,collideseg,collidedsegbc,collidersegbc,collisiontype,collisionangle,iscross] = ...
                determineStreamlineCollision( m, ci, [ vx1; s.globalcoords( length(s.vxcellindex), : ) ], m.tubules.tubuleparams.radius, noncolliders );
            % Exclude almost parallel collisions.
            nonparallel = abs(collisionangle) > 0.01;
            if any(nonparallel)
                xxxx = 1;
            end
            collidedwith = collidedwith( nonparallel );
            collideseg = collideseg( nonparallel );
            collidedsegbc = collidedsegbc( nonparallel, : );
            collidersegbc = collidersegbc( nonparallel, : );
            collisiontype = collisiontype( nonparallel );
            collisionangle = collisionangle( nonparallel );
            iscross = iscross( nonparallel );
        end
        
        if ~isempty( collidedwith )
            % We need to refer both ends of the current segment to the same
            % element.
            [cix, bc1x, bc2x] = referToSameTriangle( m, s.segcellindex(end-1), s.barycoords( end-1, : ), s.segcellindex(end), s.barycoords( end, : ) );
            if isempty(cix)
                fprintf( 2, '%s: referToSameTriangle failed for collider segment %d.\n', mfilename(), length(s.segcellindex)-1 );
                fprintf( 2, '  Arguments were ci1 %d, bc1 [%.3f %.3f %.3f] ci2 %d, bc2 [%.3f %.3f %.3f]\n', ...
                    s.segcellindex(end-1), s.barycoords( end-1, : ), ...
                    s.segcellindex(end), s.barycoords( end, : ) );
                fprintf( 2, '  cvx1 [%d %d %d], cvx2 [%d %d %d]\n', ...
                    m.tricellvxs( s.segcellindex(end-1), : ), m.tricellvxs( s.segcellindex(end), : ) );
            end
        end
        if ~isempty( collidedwith ) && ~isempty(cix)
            % If cix is empty then something went wrong with
            % referToSameTriangle. In that case we ignore all the collisions.
        
            % Determine the result of each collision.

            % I need to know the element and bcs of each of the collision
            % points, in order to find the tubule parameters at those points.
            % The bary coords of the segment that we are testing are
            % s.barycoords( :, [end-1 end] ).
            % The element the segment lies in is ci. Are both the bary coords
            % referenced to this element? Not necessarily.
            colliderCell = int32(cix) + zeros( size(collidersegbc,1), 1, 'int32' );
            colliderCellBcs = collidersegbc * [bc1x; bc2x];
            % Now I have to do the same calculation for each of collideseg and collidedsegbc
            collidedCell = zeros( length(collideseg), 1 );
            collidedCellBcs = zeros( length(collideseg), 3 );
            okcollisions = true( length(collideseg), 1 );
            for ii=1:length(collideseg)
                s1 = m.tubules.tracks(collidedwith(ii));
                s1segi = collideseg(ii);
                [s1cix, s1bc1x, s1bc2x] = referToSameTriangle( m, s1.segcellindex(s1segi), s1.barycoords( s1segi, : ), ...
                                                                  s1.segcellindex(s1segi+1), s1.barycoords( s1segi+1, : ) );
                okcollisions(ii) = ~isempty(s1cix);
                if okcollisions(ii)
                    collidedCell(ii,:) = s1cix;
                    collidedCellBcs(ii,:) = collidedsegbc(ii,:) * [s1bc1x; s1bc2x];
                else
                    fprintf( 2, '%s: referToSameTriangle failed for collided segment %s\n', mfilename(), s1segi );
                    fprintf( 2, '  Arguments were ci1 %d, bc1 [%.3f %.3f %.3f] ci2 %d, bc2 [%.3f %.3f %.3f]\n', ...
                        s1.segcellindex(s1segi), s1.barycoords( s1segi, : ), ...
                        s1.segcellindex(s1segi+1), s1.barycoords( s1segi+1, : ) );
                    fprintf( 2, '  cvx1 [%d %d %d], cvx2 [%d %d %d]\n', ...
                        m.tricellvxs( s1.segcellindex(s1segi), : ), m.tricellvxs( s1.segcellindex(s1segi+1), : ) );
                    collidedCell(ii,:) = NaN;
                    collidedCellBcs(ii,:) = NaN;
                end
            end
            
            if any( okcollisions )
                colliderCell = colliderCell( okcollisions, : );
                colliderCellBcs = colliderCellBcs( okcollisions, : );
                collidedCell = collidedCell( okcollisions, : );
                collidedCellBcs = collidedCellBcs( okcollisions, : );
                colliderTubuleparams = getTubuleParamsModifiedByMorphogens( m, colliderCell, colliderCellBcs );
                collidedTubuleparams = getTubuleParamsModifiedByMorphogens( m, collidedCell, collidedCellBcs );

                shallow = (abs(collisionangle) < m.tubules.tubuleparams.min_collide_angle);
                steep = ~shallow;
                contacts = ~iscross;
                shallowcontacts = contacts & shallow;
                steepcontacts = contacts & steep;
                p_interact = colliderTubuleparams.prob_collide_interact;
                p_steepcat = p_interact .* colliderTubuleparams.prob_collide_catastrophe_steep(:) .* steepcontacts;
                p_shallowcat = p_interact .* colliderTubuleparams.prob_collide_catastrophe_shallow(:) .* shallowcontacts;
                p_steepzip = p_interact .* colliderTubuleparams.prob_collide_zipper_steep(:) .* steepcontacts;
                p_shallowzip = p_interact .* colliderTubuleparams.prob_collide_zipper_shallow(:) .* shallowcontacts;
                rand1 = rand( length(contacts), 1 );
                zippers = ((rand1 < p_steepzip) & steepcontacts) | ((rand1 < p_shallowzip) & shallowcontacts);
                rand1 = rand( length(contacts), 1 );
                cats = ((rand1 < p_steepcat) & steepcontacts) | ((rand1 < p_shallowcat) & shallowcontacts);
                cats = cats & ~zippers;
                crosses = iscross & ~cats & ~zippers;

                rand1 = rand( length(contacts), 1 );
                cutothers = crosses & (rand1 < colliderTubuleparams.prob_collide_cut_collided(:));
                rand1 = rand( length(contacts), 1 );
                cutself = crosses & (rand1 < colliderTubuleparams.prob_collide_cut_collider(:));

                % If there are several collisions with the same mt, zippering and
                % catastrophe can only happen for the first of these.
                [~,ia,~] = unique( collidedwith );
                % ia is the indexes of the first occurrences of each mt in
                % collidedwith. These are the only points at which zippers or cats
                % may happen.
                firstcontacts = false(size(collidedwith));
                firstcontacts(ia) = true;
                zippers = zippers & firstcontacts;
                cats = cats & firstcontacts;

                % Any collision that does not zipper, catastrophe, or cross is
                % ignored
                ignoreCollisions = ~( iscross | cats | zippers );
                zippers(ignoreCollisions) = [];
                cats(ignoreCollisions) = [];
                cutothers(ignoreCollisions) = [];
                cutself(ignoreCollisions) = [];
                crosses(ignoreCollisions) = [];
                collidedwith(ignoreCollisions) = [];
                collideseg(ignoreCollisions) = [];
                collidedsegbc( ignoreCollisions, : ) = [];
                collidersegbc( ignoreCollisions, : ) = [];
                collisiontype(ignoreCollisions) = [];
                collisionangle(ignoreCollisions) = [];
                iscross(ignoreCollisions) = [];

                if ~isempty(collisionangle)
                    xxxx = 1;
                end

                % The first zip or cat, if any, excludes all later events.
                [~,zcfirst] = find( zippers | cats, 1 );
                if ~isempty(zcfirst)
                    % Remove all events from zcfirst+1 to the end.
                    zippers( (zcfirst+1):end ) = [];
                    cats( (zcfirst+1):end ) = [];
                    cutothers( (zcfirst+1):end ) = [];
                    cutself( (zcfirst+1):end ) = [];
                    crosses( (zcfirst+1):end ) = [];
                    collidedwith( (zcfirst+1):end ) = [];
                    collideseg( (zcfirst+1):end ) = [];
                    collidedsegbc( (zcfirst+1):end, : ) = [];
                    collidersegbc( (zcfirst+1):end, : ) = [];
                    collisiontype( (zcfirst+1):end ) = [];
                    collisionangle( (zcfirst+1):end ) = [];
                    iscross( (zcfirst+1):end ) = [];
                end

                doeszip = ~isempty(zippers) && zippers(end);
                doescat = ~isempty(cats) && cats(end);
                previousEvent = doeszip || doescat;

                m.tubules.statistics.crossovers = m.tubules.statistics.crossovers + sum( crosses );

                if doeszip
                    % Truncate the growth to the zippering point.


                    % Rotate the direction about the surface normal by the collision
                    % angle, in order to make it parallel or
                    % antiparallel to the collided-with tubule.
                    elementNormal = m.unitcellnormals(s.segcellindex(end),:);
                    s.directionglobal = rotateVecAboutVec( s.directionglobal, elementNormal, collisionangle(end) );
                    s.directionbc = vec2bc( s.directionglobal, m.nodes( m.tricellvxs(ci,:), : ) );
                    if ~checkZeroBcsInStreamline( s )
                        xxxx = 1;
                    end
                    m.tubules.statistics.zipperings = m.tubules.statistics.zipperings + 1;
                elseif doescat
                    % Truncate the growth to the catastrophe point.
                    % To do this we need to refer the final segment to the current
                    % cell. It probably is already. Then adjust the final bc
                    % according to segbc
                    m.tubules.statistics.collidecatastrophe = m.tubules.statistics.collidecatastrophe + 1;
                    segbc = collidersegbc(end,:);
                    extended = segbc(2) > 0;
                    if extended
                        % Truncate the final segment.
                        newbc = segbc*s.barycoords([end-1,end],:);
                        s.barycoords(end,:) = newbc;
                        if ~checkZeroBcsInStreamline( s )
                            xxxx = 1;
                        end
                        s.globalcoords(end,:) = streamlineGlobalPos( m, s, length(s.vxcellindex) );
                        s.segmentlengths(end) = norm( s.globalcoords(end,:) - s.globalcoords(end-1,:) );
                        lengthgrown = s.segmentlengths(end);
                        if s.segmentlengths(end) > maxlength
                            xxxx = 1;
                        end
                    else
                        % Delete the final segment.
                        s.barycoords(end,:) = [];
                        s.globalcoords(end,:) = [];
                        s.vxcellindex(end) = [];
                        s.segcellindex(end) = [];
                        s.segmentlengths(end) = [];
                        lengthgrown = 0;
                        % Direction can remain unchanged.
                    end
                    s.status.head = -1;
                    remaininglength = 0;
                end

                m.tubules.statistics.collidedcut = m.tubules.statistics.collidedcut + sum( cutothers );
                m.tubules.statistics.collidercut = m.tubules.statistics.collidercut + sum( cutself );
                severances.mt = collidedwith(cutothers);
                severances.segindex = collideseg(cutothers);
                severances.segbc = collidedsegbc(cutothers,:);
                % We have not yet implemented self-severing.
                selfindex = 0;
                selfsegindex = length( s.segcellindex );
                severances.mt = [ collidedwith(cutothers); selfindex+zeros(sum(cutself),1) ];
                severances.segindex = [ collideseg(cutothers); selfsegindex+zeros(sum(cutself),1) ];
                severances.segbc = [ collidedsegbc(cutothers,:); collidersegbc(cutself,:) ];

                if false && ~isempty( severances.mt )
                    severances_mt = severances.mt
                    severances_segindex = severances.segindex
                    severances_segbc = severances.segbc
                end

                if ~isempty(collisionangle)
                    xxxx = 1;
                end

                % Sort the severances into descending order of segment index.
                DO_SEVERING = true;
                if DO_SEVERING && ~isempty( severances.mt )
                    severancedata = sortrows( [ severances.segindex severances.mt severances.segbc ], 'descend' );
                    severances.segindex = severancedata(:,1);
                    severances.mt = severancedata(:,2);
                    severances.segbc = severancedata(:,[3 4]);
                    for i=1:length( severances.mt )
                        mti = severances.mt(i);
                        if mti==0
                            s1 = s;
                        else
                            s1 = m.tubules.tracks(mti);
                        end
                        [s1,ok] = insertSeveranceInMT( m, s1, severances.segindex(i), severances.segbc(i,:) );
                        if ok
                            if all( s1.directionglobal==0 )
                                xxxx = 1;
                            end
                            if ~isempty(s1)
                                if mti == 0
                                    s = s1;
                                else
                                    m.tubules.tracks(mti) = s1;
                                end
                            else
                                xxxx = 1;
                            end
                        end
                    end
                end
            end
        end
        
        if ~previousEvent
            [m,s,stopped] = stopStreamline( m, s, stoppingreason );
            if stopped
                remaininglength = 0;
            end
%             switch stoppingreason
%                 case 2
%                     % Spontaneous stop.
%                     remaininglength = 0;
%                     s.status.head = 0;
%                     m.tubules.statistics.spontaneousstop = m.tubules.statistics.spontaneousstop + 1;
%                 case 3
%                     % Spontaneous catastrophe.
%                     remaininglength = 0;
%                     s.status.head = -1;
%                     m.tubules.statistics.spontaneouscatastrophe = m.tubules.statistics.spontaneouscatastrophe + 1;
%             end
        end
    end
    
    validStreamline( m, s );
end

function [m,s,stopped] = stopStreamline( m, s, stoppingreason )
    switch stoppingreason
        case 2
            % Spontaneous stop.
            s.status.head = 0;
            m.tubules.statistics.spontaneousstop = m.tubules.statistics.spontaneousstop + 1;
            stopped = true;
        case 3
            % Spontaneous catastrophe.
            s.status.head = -1;
            m.tubules.statistics.spontaneouscatastrophe = m.tubules.statistics.spontaneouscatastrophe + 1;
            stopped = true;
        otherwise
            % Not stopped.
            stopped = false;
    end
end

function [splitmt,ok] = insertSeveranceInMT( m, splitmt, collideseg, segbc )
% %     fprintf( 1, '%s: Inserting severing point into mt %d at segment %d, bc [%f, %f].\n', ...
%         mfilename(), collidedwith, collideseg, segbc );
    [splitmt,vx,ok] = insertVertexInMT( m, splitmt, collideseg, segbc );
    if ~ok
        fprintf( 1, '%s: problem inserting severing point at segment %d, bc [%f, %f].\nSevering ignored.\n', ...
            mfilename(), collideseg, segbc );
        xxxx = 1;
        return;
    end
    
    if ~isempty( splitmt.status.severance )
        existingSeveranceVxs = [splitmt.status.severance.vertex];
        if any( vx == existingSeveranceVxs )
            xxxx = 1;
            return;
        end
    end
    
    severance = struct( ...
        'time', m.globalDynamicProps.currenttime + m.tubules.tubuleparams.delay_cut, ...
        'vertex', vx, ...
        'FE', splitmt.vxcellindex(vx), ...
        'bc', splitmt.barycoords(vx), ...
        'globalpos', splitmt.globalcoords(vx), ...
        'headcat', rand(1) < m.tubules.tubuleparams.prob_collide_cut_headcat, ...
        'tailcat', rand(1) < m.tubules.tubuleparams.prob_collide_cut_tailcat ...
        );
    if isempty( splitmt.status.severance )
        splitmt.status.severance = severance;
    else
        splitmt.status.severance(end+1) = severance;
    end
end




function g = normalisedGradient( m, ci, downstream )
    g = m.gradpolgrowth( ci, : );
    if ~downstream
        g = -g;
    end
    if any(g ~= 0)
        g = g * (norm( m.nodes(m.tricellvxs(ci,1),:) - m.nodes(m.tricellvxs(ci,2),:) )/norm(g));
    end
end

