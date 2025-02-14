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

    if s.id==678
        xxxx = 1;
    end
    if ~validStreamline( m, s )
        BREAKPOINT( 'Invalid streamline.\n' );
    end
    
    extended = false;
    remaininglength = maxlength;
    
    if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
        xxxx = 1;
    end
    
    ci = s.vxcellindex(end);
%     bc = trimbc( s.barycoords(end,:) );
    bc = normaliseBaryCoords( s.barycoords(end,:) );
    dirbc = s.directionbc;
    if any(isnan(dirbc))
        warning( 'NaN found in s.directionbc [%f %f %f]', dirbc(1), dirbc(2), dirbc(3) );
        timedFprintf( 2, '%s', formattedDisplayText( s ) );
        dbstack
        xxxx = 1;
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
        if true || isempty(s.directionglobal)
            s.directionglobal = streamlineGlobalDirection( m, s );
        end
        dirglobal = s.directionglobal;
    end
    
    olddirglobal = dirglobal;
    
    % If the microtubule is curved, modify the direction accordingly.
    MAXANGLEPERSTEP = 0.1;
    
    curvatureFromEdge = 0;
    if m.tubules.tubuleparams.curvature ~= 0
        curvatureFromEdge = m.tubules.tubuleparams.curvature;
    else
        % This code is not good. GFtbox code should never refer to the
        % model options nor to m.userdata. But I was in a hurry and there
        % was not the time to do this right.
        edge_alignment = getModelOption( m, 'edge_alignment' );
        edge_alignment_power = getModelOption( m, 'edge_alignment_power' );
        field_alignment = getModelOption( m, 'field_alignment' );
        field_alignment2 = getModelOption( m, 'field_alignment2' );
        field_alignment_power = getModelOption( m, 'field_alignment_power' );
        if isempty(edge_alignment_power)
            edge_alignment_power = 3; % Value chosen from physical principles when attempting
                                      % to minimise the bending energy of the growing head.
        end
        if isempty(edge_alignment) || (edge_alignment==0) || ~isfield( m.userdata, 'edgedirection' )
            curvatureFromEdge = 0;
        else
            edgedir = unique( m.userdata.edgedirection( m.tricellvxs(ci,:) ) );
            if (length(edgedir) > 1) || (edgedir(1)==0)
                % This will be true on the flat part of the faces and at
                % the corners. In both cases the curvature in the direction
                % of growth of the tubule is independent of that direction,
                % and so the resulting sideways curvature of the tubule
                % must be zero.
            else
                surfaceNormal = m.cellFrames( :, 3, s.vxcellindex(end) )';
                edgevec = [0 0 0];
                edgevec( edgedir ) = 1;
                [incidenceAngle,lateralCurveAxis,rotmat] = vecangle( edgevec, s.directionglobal, surfaceNormal );
                % incidenceAngle is in the range -pi..pi.
                
                localCurvature = 1/m.meshparams.edgeradius( edgedir );
                sinIE = sin(incidenceAngle);
                cosIE = cos(incidenceAngle);
                incidenceEffect = sign(incidenceAngle) * (abs(sinIE)^edge_alignment_power) * cosIE;
                cc = 1/sqrt(edge_alignment_power+1); % cos of the angle at which incidenceEffect reaches its maximum.
                ss = sqrt(1-cc^2); % sin of the angle.
                if ss > 0
                    max_incidenceEffect = (ss^edge_alignment_power) * cc; % Maximum possible value of incidenceEffect.
                    % Normalise incidenceEffect to have maximum value 1.
                    incidenceEffect = incidenceEffect / max_incidenceEffect;
                end
                curvatureFromEdge = -edge_alignment * localCurvature * incidenceEffect;
                bifurcationAngle = getModelOption( m, 'alignment_bifurcation_angle' );
                if ~isempty( bifurcationAngle ) && ~isnan( bifurcationAngle )
%                     sign1 = sign(cos( 2*incidenceAngle ));
                    sign2 = 2 * (abs( abs(incidenceAngle) - pi/2 ) > bifurcationAngle) - 1;
%                     if (sign1 ~= sign2)
%                         xxxx = 1;
%                     end
                    curvatureFromEdge = curvatureFromEdge * -sign2;
                end
                
                xxxx = 1;
            end
        end
    end
    
    curvatureFromField = 0;
    haveFirstField = ~isempty( field_alignment ) && (field_alignment ~= 0);
    haveSecondField = ~isempty( field_alignment2 ) && (field_alignment2 ~= 0);
    haveFieldAlignment = (haveFirstField || haveSecondField) ...
                         && ~isempty( field_alignment_power ) ...
                         && ~isnan( field_alignment_power ) ...
                         && isfield( m.auxdata, 'flow' ) ...
                         && ~isempty( m.auxdata.flow );
    if haveFieldAlignment
        % Code for defining the direction to turn towards by
        % a morphogen gradient.
        surfaceNormal = m.cellFrames( :, 3, s.vxcellindex(end) )';
        flowdir = m.auxdata.flow( s.vxcellindex(end), : );
        flowperp = cross( flowdir, surfaceNormal );
        flowdir2 = m.auxdata.flow2( s.vxcellindex(end), : );
        flowperp2 = cross( flowdir2, surfaceNormal );

        if all( flowperp==0 )
            % Use the other field alignment parameter.
            flowdir = m.auxdata.flow2( s.vxcellindex(end), : );
            flowperp = cross( flowdir, surfaceNormal );
            field_alignment = field_alignment2;
            xxxx = 1;
        end

        if ~all( flowperp==0 )
            [incidenceAngle,lateralCurveAxis,rotmat] = vecangle( flowdir, s.directionglobal, surfaceNormal );
            sinIE = sin(incidenceAngle);
            cosIE = cos(incidenceAngle);
            incidenceEffect = sign(incidenceAngle) * (abs(sinIE)^field_alignment_power) * cosIE;
            cc = 1/sqrt(field_alignment_power+1); % cos of the angle at which incidenceEffect reaches its maximum.
            ss = sqrt(1-cc^2); % sin of the angle.
            if ss > 0
                max_incidenceEffect = (ss^field_alignment_power) * cc; % Maximum possible value of incidenceEffect.
                % Normalise incidenceEffect to have maximum value 1.
                incidenceEffect = incidenceEffect / max_incidenceEffect;
            end
            curvatureFromField = field_alignment * incidenceEffect;
            xxxx = 1;
        end
    end
    
    curvature = curvatureFromEdge + curvatureFromField;
    curvelengthbound = MAXANGLEPERSTEP/abs(curvature);
    maxlength = min( maxlength, curvelengthbound, 'omitnan' );
    if (curvature ~= 0) && ~isempty( s.segmentlengths )
        % Correct dirglobal by curvature. The turning angle is limited to avoid numerical errors.
        % The length of the previous segment, from which the turning angle
        % is calculated, should have been short enough that MAXANGLEPERSTEP
        % is not exceeded, but we use the bound here just to make sure.
        angle = curvature * s.segmentlengths(end);
        if abs(angle) > MAXANGLEPERSTEP
            xxxx = 1;
            angle = sign(angle) * min( abs(angle), MAXANGLEPERSTEP, 'omitnan' );
        end
        trivxs = m.tricellvxs( s.vxcellindex(end), : );
        pointnormal = s.barycoords(end,:) * m.vertexnormals( trivxs, : );
        r = axisAngle2RotMat( pointnormal, angle );
        dirglobal1 = dirglobal*r;
        % Force dirglobal to lie within the element
%         facenormal = trinormal( m.nodes( trivxs, : ) );
        dirglobal2 = dirglobal1 - pointnormal * dot(dirglobal1,pointnormal)/norm(pointnormal);
%         deflection = dirglobal2 - dirglobal
        dirglobal = dirglobal2;
        dirbc = vec2bc( dirglobal, m.nodes( trivxs, : ) );
        s.directionbc = dirbc/norm(dirbc);
        s.directionglobal = streamlineGlobalDirection( m, s );
        xxxx = 1;
    end
    
    if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
        xxxx = 1;
    end
    
    DIRBC_TOL = 1e-7;
%     s.directionbc( abs(s.directionbc) < DIRBC_TOL ) = 0;
    dirbc = normaliseDirBaryCoords( s.directionbc, DIRBC_TOL );
    s.directionbc = dirbc;
    
    
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
        % The possibilities are:
        % * The tubule catastrophises immediately.
        % * The tubule is paused.
        % * The tubule continues its growth.
        %
        % To pause a tubule, we set its pauseuntil to the pauseduration
        % plus the time at which it hit the edge. If this is less than the
        % remaining time of this step ...
        %
        % In the last case we transfer its  endpoint to the element it is
        % about to move into, then call extrapolateStreamline recursively
        % to continue the growth.
        lengthgrown = 0;
        
        % Determine whether the mt should catastrophise, according to the
        % tubuleparams.edge_plus_catastrophe property. If this is a single
        % number, that is the probability. Otherwise it specifies a number
        % (possibly NaN) per vertex or a morphogen name. If the mt has run
        % into a vertex, the value for that vertex is the probability of
        % catastrophe. If it has run into an edge, the probability is the
        % minimum probability of either end. If the resulting probability
        % is NaN, this is equivalent to zero.
        
        does_edge_cat = false;
        
        s_barrier_incidence_i = FindMorphogenIndex( m, 's_edge_barrier' );
        s_barrier_incidence_perFEvertex = m.morphogens( m.tricellvxs( ci, : ), s_barrier_incidence_i )';
        collisionbarrieredges = [];
        barriervalue = 0;
        if any( s_barrier_incidence_perFEvertex > 0 )
            barrier_spread = getModelOption( m, 'barrier_spread' );
            if isempty( barrier_spread ) || isnan( barrier_spread )
                spreadAngle = 0;
            else
                spreadAngle = abs( randn(1) * barrier_spread );
            end
            
            barrieredges = (s_barrier_incidence_perFEvertex([2 3 1]) > 0) & (s_barrier_incidence_perFEvertex([3 1 2]) > 0);
            if ~isempty(whichedge)
                if barrieredges(whichedge)
                    collisionbarrieredges = whichedge;
                    whichvxs = othersOf3( whichedge );
                    barriervalue = sum( s_barrier_incidence_perFEvertex( othersOf3( whichedge ) ) .* s.barycoords(end,whichvxs) );
                end
            elseif ~isempty(whichvertex)
                if s_barrier_incidence_perFEvertex( whichvertex ) > 0
                    barrieredges( whichvertex ) = false;
                    collisionbarrieredges = find( barrieredges );
                    barriervalue = s_barrier_incidence_perFEvertex( whichvertex );
                end
            end
            
%             barriervalue = barriervalue - spreadAngle;
            barriervalue = min( barriervalue, pi/2 - spreadAngle );
        end
        if ~isempty( collisionbarrieredges )
            if numel(collisionbarrieredges) > 1
                xxxx = 1;
            end
            trivxs = m.tricellvxs( s.vxcellindex(end), : );
            cellvxs = m.nodes( trivxs, : );
            cellvecs = cellvxs( 1 + mod(collisionbarrieredges-2,3), : ) - cellvxs( 1 + mod(collisionbarrieredges,3), : );
            cosincidenceangles = abs( dot( cellvecs, repmat( dirglobal, length(collisionbarrieredges), 1 ) ) ./ (sqrt(sum(cellvecs.^2,2)) * norm(dirglobal)) );
            incidenceangles = abs( acos( cosincidenceangles ) );
            tooshallow = incidenceangles < barriervalue;
            if ~tooshallow
                xxxx = 1;
            end
            does_edge_cat = any( tooshallow );
        end
        
        
        if ~does_edge_cat
            edge_plus_catastrophe = getModelOptionModifiedByMorphogens( m, 'edge_plus_catastrophe' );
            if all( edge_plus_catastrophe==edge_plus_catastrophe(1) )
                edge_plus_catastrophe = edge_plus_catastrophe(1);
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
                        prob_edge_catastrophe = min( prob_per_edgevx(:), [], 2, 'includenan' );
    %                     bc_per_edgevx = bc(civxs);
    %                     prob_edge_catastrophe = sum( prob_per_edgevx(:) .* bc_per_edgevx(:) );
                    end
                end
            end
            prob_edge_catastrophe( isnan(prob_edge_catastrophe) ) = 0;
            does_edge_cat = rand(1) < prob_edge_catastrophe;
        end
        
        if does_edge_cat
            % Catastrophise now.
            [m,s,stopped] = stopStreamline( m, s, 'e' );
            remaininglength = 0;
        else
            % Cross over to the next element, then call this procedure again.

            if recursive
                % This is an error.
                timedFprintf( 1, 'recursive call not allowed.\n' );
                xxxx = 1;
                return;
            end

            atvertex = any(bc >= 1);

            if ~atvertex
                % Find which edge.
                k1i = find( bc <= 0, 1 );
                ei = m.celledges(ci,k1i);
        %         timedFprintf( 1, 'hit edge %d in element %d\n', ei, ci );
                cis = m.edgecells(ei,:);
                newci = cis(cis ~= ci);
                if newci==0
                    % We hit a border. No more to do.
        %             timedFprintf( 1, 'hit border edge\n' );
                else
                    % Transfer the direction and the final point to the element on
                    % the other side of the edge, then call this procedure again.

        %             oldpoint = streamlineGlobalPos( m, s, length(s.vxcellindex) );
                    old_s_directionbc = s.directionbc;
                    old_s_cs = s.barycoords(end,:);
                    [s.barycoords(end,:),s.directionbc] = transferDirection( m, ci, bc, s.directionbc, newci );
                    if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
                        xxxx = 1;
                    end
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
                    if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
                        xxxx = 1;
                    end

                    if any( abs( sum(s1.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s1.directionbc)) > 1e-4)
                        xxxx = 1;
                    end
    
                    m = m1;
                    s = s1;
                end
            else
                % Project the direction and all the edges that meet at this vertex
                % onto the plane perpendicular to the vertex normal. Find which two
                % edges the direction lies between and continue in that element.

                k1i = find( bc >= 1, 1 );
                vi = m.tricellvxs( ci, k1i );
        %         timedFprintf( 1, 'hit vertex %d in element %d\n', vi, ci );

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
        %             timedFprintf( 1, 'hit border vertex\n' );
                else
                    % Find vi in nextci
                    cvi = find( m.tricellvxs(nextci,:)==vi, 1 );
        %             oldpoint = streamlineGlobalPos( m, s, length(s.vxcellindex) );
                    s.barycoords(end,:) = [0 0 0];
                    s.barycoords(end,cvi) = 1;
                    % Check that old and new bcs represent the same point.
        %             newpoint = streamlineGlobalPos( m, s, length(s.vxcellindex) );
                    s.vxcellindex(end) = nextci;
                    s.segcellindex(end) = nextci;
                    edgevec1 = edgevecs(ehi1,:);
                    edgevec2 = edgevecs(ehi2,:);
                    ev12 = cross( edgevec1, edgevec2 );
                    dirrotangle = atan2( dot( zz, ev12 ), dot( vxnormal, ev12 ) );
                    mat = axisAngle2RotMat( xx, dirrotangle );
                    newdirectionglobal = zz * mat;
        %             checkRotatedDirection = det( [newdirectionglobal; edgevec1; edgevec2] )
                    s.directionglobal = newdirectionglobal;
                    s.directionbc = vec2bc( s.directionglobal, m.nodes( m.tricellvxs(nextci,:), : ) );
        %             timedFprintf( 1, 'passed through vertex %d to element %d\n', vi, nextci );
                    if ~checkZeroBcsInStreamline( s )
                        xxxx = 1;
                    end
                    if any( abs( sum(s.barycoords,2) - 1 ) > 1e-4 ) || (abs(sum(s.directionbc)) > 1e-4)
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
        % * It continues unobstructed to the edge. It may at the edge have
        %   an edge-induced catastrophe.
        % * It has a spontaneous catastrophe.
        % * It spontaneously stops.
        % That is the furthest point to which it can be grown. We then
        % check to see if it collides with a microtubule or bundle of
        % microtubules before then. If it hits an
        
        if ~validStreamline( m, s )
            xxxx = 1;
        end

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
        s.iscrossovervx(end+1) = false;
        s.barycoords(end+1,:) = trimbc( bc + k1*dirbc );
        if ~checkZeroBcsInStreamline( s )
            xxxx = 1;
        end
        if (s.globalcoords(end,2) < -4.5) && (s.globalcoords(end,3) > 4.5)
            xxxx = 1;
        end
        vx1 = streamlineGlobalPos( m, s, length(s.vxcellindex)-1 );
        vx2 = streamlineGlobalPos( m, s, length(s.vxcellindex) );
        lengthgrown = norm(vx2-vx1);
%         hitedge = lengthgrown >= maxlength;
        if lengthgrown > maxlength
            dirbc = dirbc*maxlength/lengthgrown;
            s.barycoords(end,:) = trimbc( bc + k1*dirbc );
            if ~checkZeroBcsInStreamline( s )
                xxxx = 1;
            end
            lengthgrown = maxlength;
        end
        TOLERANCE = 1e-6;
        whichreledges = s.barycoords(end,:) <= TOLERANCE;
        whichabsedges = m.celledges( ci, whichreledges );
%         if isfield( m.auxdata, 'edgecatprob' ) && ~isempty( m.auxdata.edgecatprob )
%             if numel( m.auxdata.edgecatprob )==1
%                 edge_cat_prob = m.auxdata.edgecatprob;
%             else
%                 edge_cat_prob = max( m.auxdata.edgecatprob( whichabsedges ) );
%             end
%         else
%             edge_cat_prob = 0;
%         end
%         doedgecat = any( whichreledges ) && (rand(1) < edge_cat_prob);
%         if doedgecat
%             xxxx = 1;
%         end
        doedgecat = false; % Edge catastrophe is not handled here, but in
            % the recursive call that attempts to cross an edge, starting
            % at line 183.
        
        % Calculate whether there was a spontaneous stopping or
        % catastrophising before lengthgrown.
        if lengthgrown > 0
            params = getTubuleParamsModifiedByMorphogens( m, s );
            timeused = lengthgrown/params.plus_growthrate;
            tubuleCurvatureAtHead = directionalCurvature( m, s.vxcellindex(end), s.barycoords(end,:), s.directionglobal, 'min' );
            if m.tubules.tubuleparams.curvature_power==0
                curvature_effect = double( tubuleCurvatureAtHead ~= 0 );
            else
                curvature_effect = tubuleCurvatureAtHead^m.tubules.tubuleparams.curvature_power;
            end
            % params.plus_curvature_cat is the probability of catastrophe
            % per unit distance of growth at a curvature of 1.
            %
            % curvature_effect is the curvature of the tubule at its tip,
            % raised to the power m.tubules.tubuleparams.curvature_power.
            % By default this is 2, as the event is assumed proportional to
            % the energy of bending, which is proportional to the square of
            % curvature.
            %
            % params.plus_curvature_cat * curvature_effect is therefore the
            % probability per unit distance of growth of the current tubule
            % catastrophising.
            %
            % After multiplying this by the growth rate,
            % params.plus_growthrate, we have the probability per unit time
            % of catastrophizing.
            %
            % A similar calculation gives the probability per unit time of
            % growth stopping.
            if isinf( params.plus_curvature_cat )
                xxxx = 1;
            end
            curvature_cat_prob_per_time = params.plus_curvature_cat * curvature_effect * params.plus_growthrate;
            curve_stop_per_time = params.curve_stop_per_dist * curvature_effect * params.plus_growthrate;
            nextstop = sampleexp( params.prob_plus_stop + curve_stop_per_time );
            
            if tubuleCurvatureAtHead > 0
                if abs(s.globalcoords(end,3)) < 3
                    xxxx = 1;
                end
                xxxx = 1;
            end
            

            % There is also a probability of spontaneous catastrophe per
            % unit time. This is added to the probability of
            % curvature-induced catastrophe per unit time.
            if isinf( params.prob_plus_catastrophe )
                xxxx = 1;
            end
            if m.tubules.tubuleparams.SCALE_CURVATURE_CAT_BY_DENSITY
                effective_prob_plus_catastrophe_per_time = (params.prob_plus_catastrophe + curvature_cat_prob_per_time) * m.tubules.tubuleparams.plus_catastrophe_scaling;
            else
                effective_prob_plus_catastrophe_per_time = params.prob_plus_catastrophe * m.tubules.tubuleparams.plus_catastrophe_scaling + curvature_cat_prob_per_time;
            end
            
            % Extra for testing purposes: we also use
            % prob_plus_catastrophe2, but not scaled by
            % m.tubules.tubuleparams.plus_catastrophe_scaling.
            if ~isnan( params.prob_plus_catastrophe2 ) && (params.prob_plus_catastrophe2 ~= 0)
                effective_prob_plus_catastrophe_per_time = effective_prob_plus_catastrophe_per_time + params.prob_plus_catastrophe2;
            end

            % Now we sample from this exponential distribution to find the
            % time until the next catastrophe.
            nextcat = sampleexp( effective_prob_plus_catastrophe_per_time );
            if isnan(nextcat)
                nextcat = Inf;
            else
                xxxx = 1;
            end
            if doedgecat
                edgecat = timeused;
            else
                edgecat = Inf;
            end
            if (nextcat <= 0) || isnan(nextcat) || any(isinf(effective_prob_plus_catastrophe_per_time)) || any(isnan(effective_prob_plus_catastrophe_per_time))
                xxxx = 1;
            end
            if nextstop < Inf
                xxxx = 1;
            end
            
            
            
            
            
            
            [timetoevent,stoppingreason] = min( [edgecat, nextcat, nextstop, timeused], [], 'omitnan' );
            stoppingreasons = 'ecsx';
            stoppingreason = stoppingreasons(stoppingreason);
            % stoppingreason is 'x' if no stop or cat, 's' if stop, 'c' if cat, 'e' if edge cat.
            if stoppingreason=='s'
                xxxx = 1;
            end
            if timetoevent < timeused
                % Adjust the final point of s.
                frac = timetoevent/timeused;
                if frac <= 0
                    % Undo the adding of the last vertex.
                    s.segcellindex(end) = [];
                    s.vxcellindex(end) = [];
                    s.iscrossovervx(end) = [];
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
            stoppingreason = 'x';
        end
        remaininglength = maxlength - lengthgrown;
        
        previousEvent = false;
        
%         timedFprintf( 1, 'direction points inward, remaining length %g\n', remaininglength );
        MINLENGTHGROWN = 1e-5;
        if lengthgrown <= 0
            collidedwith = [];
            collidedseg = [];
            collidedsegbc = [];
            collidersegbc = [];
            collisiontype = [];
            collisionangle = [];
            iscrossing = [];
            numevents = 0;
            [m,s,stopped] = stopStreamline( m, s, stoppingreason );
            remaininglength = 0;
        else
            if lengthgrown <= MINLENGTHGROWN
                xxxx = 1;
            end
            tubule_age_at_event = timetoevent + m.globalDynamicProps.currenttime - s.starttime;
            oldenough = tubule_age_at_event >= s.status.interactiontime;
            xxxx = 1;

            s.globalcoords( length(s.vxcellindex), : ) = streamlineGlobalPos( m, s, length(s.vxcellindex) );
            s.segmentlengths( length(s.vxcellindex)-1 ) = lengthgrown;
            extended = true;
            lengthgrown1 = s.segmentlengths(end);
            if abs(lengthgrown1 - lengthgrown1) > 1e-9
                xxxx = 1;
            end
            
            if ~validStreamline( m, s )
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
            % prob_crossover_catastrophe_shallow, prob_crossover_catastrophe_steep
            % prob_crossover_zipper_shallow, prob_crossover_zipper_steep, and
            % prob_crossover_cut, prob_crossover_cut_collider, together with
            % morphogens designated to provide per-vertex modification.

            noncolliders1 = [];
            [collidedwith,collidedseg,collidedsegbc,collidersegbc,collisiontype,collisionangle,iscrossing,collisionparallel] = ...
                determineStreamlineCollision( m, ci, [ vx1; s.globalcoords( length(s.vxcellindex), : ) ], m.tubules.tubuleparams.radius, noncolliders1 );
            if ~isempty( collidedwith )
                xxxx = 1;
            end
            xcollidedwith = collidedwith;
            xcollidedseg = collidedseg;
            xcollidedsegbc = collidedsegbc;
            xcollidersegbc = collidersegbc;
            xcollisiontype = collisiontype;
            xcollisionangle = collisionangle;
            xiscrossing = iscrossing;
            xcollisionparallel = collisionparallel;
            
            initialevents = collidersegbc(:,2)==0;
            if any(initialevents)
                collidedwith( initialevents ) = [];
                collidedseg( initialevents ) = [];
                collidedsegbc( initialevents, : ) = [];
                collidersegbc( initialevents, : ) = [];
                collisiontype( initialevents ) = [];
                collisionangle( initialevents ) = [];
                iscrossing( initialevents ) = [];
                collisionparallel( initialevents ) = [];
            end
            
            if ~isempty( collidedwith )
                xxxx = 1;
            end
            
            beforeThisElement = find( s.segcellindex ~= s.segcellindex(end), 1, 'last' );
            if isempty(beforeThisElement)
                beforeThisElement = 0;
            end
            excludeSelf = (collidedwith==noncolliders) & (collidedseg > beforeThisElement);
            if any( excludeSelf )
                collidedwith( excludeSelf ) = [];
                collidedseg( excludeSelf ) = [];
                collidedsegbc( excludeSelf, : ) = [];
                collidersegbc( excludeSelf, : ) = [];
                collisiontype( excludeSelf ) = [];
                collisionangle( excludeSelf ) = [];
                iscrossing( excludeSelf ) = [];
                collisionparallel( excludeSelf ) = [];
                if ~isempty( collidedwith )
                    xxxx = 1;
                end
            
                remainingSelfCollisions = collidedwith==noncolliders;
                if any( remainingSelfCollisions )
                    collidedwith( remainingSelfCollisions ) = [];
                    collidedseg( remainingSelfCollisions ) = [];
                    collidedsegbc( remainingSelfCollisions, : ) = [];
                    collidersegbc( remainingSelfCollisions, : ) = [];
                    collisiontype( remainingSelfCollisions ) = [];
                    collisionangle( remainingSelfCollisions ) = [];
                    iscrossing( remainingSelfCollisions ) = [];
                    collisionparallel( remainingSelfCollisions ) = [];
                    timedFprintf( 'Self collision of tubule %d, %d times.\n', noncolliders, sum( remainingSelfCollisions ) );
                    xxxx = 1;
                    if ~isempty( collidedwith )
                        xxxx = 1;
                    end
                end
            end
            
            tubule_age_at_collisions = collidersegbc(:,2) * timetoevent + max(m.globalDynamicProps.currenttime,s.starttime) - s.starttime;
            oldenough = tubule_age_at_collisions >= s.status.interactiontime;
            if ~isempty( tubule_age_at_collisions )
                if length(tubule_age_at_collisions) >= 2
                    xxxx = 1;
                end
                other_tubule_starttimes = reshape( [ m.tubules.tracks(collidedwith).starttime ], [], 1 );
                other_tubule_status = [ m.tubules.tracks(collidedwith).status ];
                other_tubule_interactiontimes = reshape( [ other_tubule_status.interactiontime ], [], 1 );
                other_tubule_age_at_collisions = collidedsegbc(:,2) * timetoevent + m.globalDynamicProps.currenttime - other_tubule_starttimes;
                oldenough = oldenough & (other_tubule_age_at_collisions >= other_tubule_interactiontimes);
            end
            if any(~oldenough)
                xxxx = 1;
            end
            if (s.status.interactiontime > 0) && any(oldenough)
                xxxx = 1;
            end
            
            % Exclude collisions where either tubule is not old enough.
            if any(~oldenough)
                tooyoung = ~oldenough;
                collidedwith( tooyoung ) = [];
                collidedseg( tooyoung ) = [];
                collidedsegbc( tooyoung, : ) = [];
                collidersegbc( tooyoung, : ) = [];
                collisiontype( tooyoung ) = [];
                collisionangle( tooyoung ) = [];
                iscrossing( tooyoung ) = [];
                collisionparallel( tooyoung ) = [];
            end


            headtailcollision = (collidedseg==1) & (collidedsegbc(:,1) > 0.99) & collisionparallel & (abs(collisionangle) < pi/180);
            if any( headtailcollision )
%                 timedFprintf( 1, 'Head-tail collision:\n' );
%                 fprintf( '    Tubule %4d tailbcs %.4f %.4f\n', [ collidedwith(headtailcollision), collidedsegbc(headtailcollision,:) ]' );
                xxxx = 1;
                % m.tubules.statistics.collideheadtailinfo(end+1,:) = [ 
            end
            
            % Exclude almost parallel collisions, except for head-tail parallel (i.e. not antiparallel) collisions.
            nonparallel = (abs(collisionangle) > 0.01) | headtailcollision;
            if any(nonparallel)
                xxxx = 1;
            end
            collidedwith = collidedwith( nonparallel );
            collidedseg = collidedseg( nonparallel );
            collidedsegbc = collidedsegbc( nonparallel, : );
            collidersegbc = collidersegbc( nonparallel, : );
            collisiontype = collisiontype( nonparallel );
            collisionangle = collisionangle( nonparallel );
            headtailcollision = headtailcollision( nonparallel );
            iscrossing = iscrossing( nonparallel );
            numevents = sum( ~nonparallel );
        end
        
        if ~isempty( collidedwith )
            % We need to refer both ends of the current segment to the same
            % element.
            [cix, bc1x, bc2x] = referToSameTriangle( m, s.segcellindex(end-1), s.barycoords( end-1, : ), s.segcellindex(end), s.barycoords( end, : ) );
            if isempty(cix)
                timedFprintf( 2, 'referToSameTriangle failed for collider segment %d.\n', length(s.segcellindex)-1 );
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
            collidedCell = zeros( length(collidedseg), 1 );
            collidedCellBcs = zeros( length(collidedseg), 3 );
            okcollisions = true( length(collidedseg), 1 );
            for ii=1:length(collidedseg)
                s1 = m.tubules.tracks(collidedwith(ii));
                s1segi = collidedseg(ii);
                [s1cix, s1bc1x, s1bc2x] = referToSameTriangle( m, s1.segcellindex(s1segi), s1.barycoords( s1segi, : ), ...
                                                                  s1.segcellindex(s1segi+1), s1.barycoords( s1segi+1, : ) );
                okcollisions(ii) = ~isempty(s1cix);
                if okcollisions(ii)
                    collidedCell(ii,:) = s1cix;
                    collidedCellBcs(ii,:) = collidedsegbc(ii,:) * [s1bc1x; s1bc2x];
                else
                    timedFprintf( 2, 'referToSameTriangle failed for collided segment %s\n', s1segi );
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
                collisionangle = collisionangle( okcollisions, : );
                headtailcollision = headtailcollision( okcollisions, : );
                iscrossing = iscrossing( okcollisions ) & ~headtailcollision;
                iscontact = ~iscrossing & ~headtailcollision;
                numevents = length( colliderCell );
                % { colliderCell, colliderCellBcs } should identify the same point as
                % { collidedCell, collidedCellBcs }, at least for okcollisions.
                
                angle_boundaries = getTubuleParamModifiedByMorphogens( m, 'collision_angles', colliderCell, colliderCellBcs );
                angle_boundaries = [ zeros( numevents, 1 ), angle_boundaries, inf( numevents, 1 ) ];
                probs_zip = getTubuleParamModifiedByMorphogens( m, 'probs_zip', colliderCell, colliderCellBcs );
                probs_cat = getTubuleParamModifiedByMorphogens( m, 'probs_cat', colliderCell, colliderCellBcs );
                probs_htcat = getTubuleParamModifiedByMorphogens( m, 'prob_htcollide_cat', colliderCell, colliderCellBcs );
                outcomeprobs = zeros( numevents, 3 );
                possibleoutcomes = 'zcxhi';
                angleclass = zeros( numevents, 1 );
                outcomes = repmat( 'i', numevents, 1 ); % z: zip, c: cat, x: cross, h: head-tail cat, i: ignore.
                if (s.id==1) && (collidedwith(1)==185)
                    xxxx = 1;
                end
                for okci=1:numevents
                    if headtailcollision(okci)
                        rand1 = rand( 1, 1 );
                        havehtcat = rand1 < probs_htcat(okci);
                        if havehtcat
                            outcomes( okci ) = 'h';
%                             timedFprintf( 1, 'Head-tail collision confirmed:\n' );
%                             fprintf( '    Tubule %4d tailbcs %.4f %.4f\n', [ collidedwith(okci), collidedsegbc(okci,:) ]' );
                            xxxx = 1;
                        else
                            outcomes( okci ) = 'i';
                        end
                        angleclass(okci) = 1;
                    else
                        angleclass(okci) = binsearchlower( angle_boundaries(okci,:), abs(collisionangle(okci)) );
                        outcomeprobs( okci, : ) = [ 0, probs_zip(okci,angleclass(okci)), probs_cat(okci,angleclass(okci)) ];
                        rand1 = rand( 1, 1 );
                        outcomes( okci ) = possibleoutcomes( binsearchlower( outcomeprobs( okci, : ), rand1 ) );
                    end
                end
                zippers = iscontact & (outcomes == 'z');
                cats = (outcomes == 'h') | (iscontact & (outcomes == 'c'));
                crosses = iscrossing & (outcomes == 'x');

                % Any zipper or catastrophe rules out all later events.
                firstzipcat = find(zippers|cats,1);
                if ~isempty(firstzipcat)
                    colliderCell = colliderCell( 1:firstzipcat, : );
                    colliderCellBcs = colliderCellBcs( 1:firstzipcat, : );
                    xcollidedCell = collidedCell( 1:firstzipcat, : );
                    xcollidedCellBcs = collidedCellBcs( 1:firstzipcat, : );
                    collisionangle = collisionangle( 1:firstzipcat, : );
                    iscrossing = iscrossing( 1:firstzipcat );
                    iscontact = iscontact( 1:firstzipcat );
                    zippers = zippers( 1:firstzipcat );
                    cats = cats( 1:firstzipcat );
                    crosses = crosses( 1:firstzipcat );
                    angleclass = angleclass( 1:firstzipcat );
                    numevents = firstzipcat;
                end
                
                colliderTubuleparams = getTubuleParamsModifiedByMorphogens( m, colliderCell, colliderCellBcs );
%                 collidedTubuleparams = getTubuleParamsModifiedByMorphogens( m, collidedCell, collidedCellBcs );
                
                p_collision_branch = colliderTubuleparams.prob_crossover_branch(:); % ./ (1 - p_zipcat);
                p_collision_sever = colliderTubuleparams.prob_crossover_cut(:); % ./ (1 - p_zipcat);
                p_branch_plus_sever = p_collision_branch + p_collision_sever;
                if p_branch_plus_sever > 1
                    xxxx = 1;
                    p_collision_branch = p_collision_branch / p_branch_plus_sever;
                    p_collision_sever = p_collision_sever / p_branch_plus_sever;
                end
                
                rand2 = rand( length(iscontact), 1 );
                crossbranch1 = crosses & (rand2 < p_collision_branch);
                crossbranch = crossbranch1 & (abs(collisionangle) > colliderTubuleparams.min_angle_crossover_branch);
                if any( crossbranch1 ~= crossbranch )
                    % A branching event was forestalled by the
                    % min_angle_crossover_branch parameter.
                    xxxx = 1;
                end
                crosscutxx = crosses & (rand2 < p_collision_branch + p_collision_sever);
                crosscut = crosses & (rand2 >= p_collision_branch) & (rand2 < p_collision_branch + p_collision_sever);
                if any(crosscut ~= crosscutxx)
                    xxxx = 1;
                end

                rand3 = rand( length(iscontact), 1 );
                cutself = crosscut & (rand3 < colliderTubuleparams.prob_crossover_cut_collider(:));
                cutother = crosscut & ~cutself;

                % Any collision that does not zipper, catastrophe, or cross is
                % ignored. This happens when there is a touch that does not
                % zip or cat. These should be ignored.
                ignoreCollisions = ~( iscrossing | cats | zippers );
                if any( ignoreCollisions )
                    xxxx = 1;
                end
                if any( iscrossing )
                    xxxx = 1;
                end
                if length(zippers) ~= length(crosses)
                    xxxx = 1;
                end
                colliderCell(ignoreCollisions) = [];
                colliderCellBcs(ignoreCollisions,:) = [];
                collidedCell(ignoreCollisions) = [];
                collidedCellBcs(ignoreCollisions,:) = [];
                zippers(ignoreCollisions) = [];
                cats(ignoreCollisions) = [];
                crossbranch(ignoreCollisions) = [];
                cutother(ignoreCollisions) = [];
                cutself(ignoreCollisions) = [];
                crosses(ignoreCollisions) = [];
                collidedwith(ignoreCollisions) = [];
                collidedseg(ignoreCollisions) = [];
                collidedsegbc( ignoreCollisions, : ) = [];
                collidersegbc( ignoreCollisions, : ) = [];
                collisiontype(ignoreCollisions) = [];
                collisionangle(ignoreCollisions) = [];
                iscrossing(ignoreCollisions) = [];
                angleclass(ignoreCollisions) = [];
                numevents = sum( ~ignoreCollisions );

                if ~isempty(collisionangle)
                    xxxx = 1;
                end

                % The first zip or cat, if any, excludes all later events.
                [~,zcfirst] = find( zippers | cats, 1 );
                if ~isempty(zcfirst)
                    % Remove all events from zcfirst+1 to the end.
                    colliderCell( (zcfirst+1):end ) = [];
                    colliderCellBcs( (zcfirst+1):end, : ) = [];
                    zippers( (zcfirst+1):end ) = [];
                    cats( (zcfirst+1):end ) = [];
                    crossbranch( (zcfirst+1):end ) = [];
                    cutother( (zcfirst+1):end ) = [];
                    cutself( (zcfirst+1):end ) = [];
                    crosses( (zcfirst+1):end ) = [];
                    collidedwith( (zcfirst+1):end ) = [];
                    collidedseg( (zcfirst+1):end ) = [];
                    collidedsegbc( (zcfirst+1):end, : ) = [];
                    collidersegbc( (zcfirst+1):end, : ) = [];
                    collisiontype( (zcfirst+1):end ) = [];
                    collisionangle( (zcfirst+1):end ) = [];
                    iscrossing( (zcfirst+1):end ) = [];
                    angleclass( (zcfirst+1):end ) = [];
                    numevents = zcfirst;
                end
                
                doeszip = ~isempty(zippers) && zippers(end);
                doescat = ~isempty(cats) && cats(end);
                previousEvent = doeszip || doescat;

                % m.tubules.statistics.crossovers = m.tubules.statistics.crossovers + sum( crosses );
                if any(crosses)
                    numcrosses = sum( crosses );
                    m.tubules.statistics.crossoverinfo((end+1):(end+numcrosses),1:5) = ...
                        [ double(colliderCell(crosses)), colliderCellBcs(crosses,:), double(Steps(m)+1)+zeros(numcrosses,1) ];
                end
                
                % At this point, we know exactly what events are to happen
                % during the current step of the current microtubule.
                % There will be a string of zero or more crossovers, each
                % of which may cause a (delayed) branch or severing.
                % This may possibly be followed by a zipper or catastrophe.

                if doeszip
                    numsegvxs = length(s.vxcellindex);
                    if ~isempty(s.status.severance)
                        % Delete all severances at the end of this segment.
                        sevvxs = [s.status.severance.vertex];
                        delsev = sevvxs >= numsegvxs;
                        s.status.severance(delsev) = [];
                    end
                    if collidersegbc(zcfirst,2) <= TOLERANCE
                        collidersegbc(zcfirst,:) = [1,0];
                    end
                    if collidersegbc(zcfirst,2) == 0
                        % Delete the final vertex.
                        s.vxcellindex(end) = [];
                        s.segcellindex(end) = [];
                        s.barycoords(end,:) = [];
                        s.globalcoords(end,:) = [];
                        s.segmentlengths(end) = [];
                        s.iscrossovervx(end) = [];
                    else
                        % Move the final vertex of the tubule back to the
                        % zippering point.
                        newvxglobalcoords = collidersegbc(zcfirst,:) * s.globalcoords( [numsegvxs-1, numsegvxs], : );
                        s.barycoords( numsegvxs, : ) = collidersegbc(zcfirst,:) * s.barycoords( [numsegvxs-1, numsegvxs], : );
                        s.globalcoords( length(s.vxcellindex), : ) = newvxglobalcoords;
                        s.segmentlengths(end) = collidersegbc(zcfirst,2) * s.segmentlengths(end);
                        % Check consistency.
                        % Not done yet.
                    end
                    lengthgrown = norm( s.globalcoords(end,:) - vx1 );
                    
                    % Rotate the direction about the surface normal by the collision
                    % angle, in order to make it parallel or
                    % antiparallel to the collided-with tubule.
                    elementNormal = m.unitcellnormals(s.segcellindex(end),:);
                    s.directionglobal = rotateVecAboutVec( s.directionglobal, elementNormal, collisionangle(end) );
                    s.directionbc = vec2bc( s.directionglobal, m.nodes( m.tricellvxs(ci,:), : ) );
                    if ~checkZeroBcsInStreamline( s )
                        xxxx = 1;
                    end
%                     m.tubules.statistics.zipperings = m.tubules.statistics.zipperings + 1;
                    m.tubules.statistics.zipinfo(end+1,1:5) = [ double(colliderCell(end)), colliderCellBcs(end,:), double(Steps(m)+1) ];
                elseif doescat
                    % Truncate the growth to the catastrophe point.
                    % To do this we need to refer the final segment to the current
                    % cell. It probably is already. Then adjust the final bc
                    % according to segbc.
%                     m.tubules.statistics.collidecatastrophe = m.tubules.statistics.collidecatastrophe + 1;
                    m.tubules.statistics.collidecatastropheinfo(end+1,1:5) = [ double(colliderCell(end)), colliderCellBcs(end,:), double(Steps(m)+1) ];

                    segbc = trimbc( collidersegbc(end,:), 1e-6 );
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
            
                        if ~validStreamline( m, s )
                            xxxx = 1;
                        end

                    else
                        % Delete the final segment.
                        s.barycoords(end,:) = [];
                        s.globalcoords(end,:) = [];
                        s.vxcellindex(end) = [];
                        s.iscrossovervx(end) = [];
                        s.segcellindex(end) = [];
                        s.segmentlengths(end) = [];
                        lengthgrown = 0;
                        % Direction can remain unchanged.
                    end
                    s.status.head = -1;
                    remaininglength = 0;
                end

                if any(crossbranch)
%                     if isMorphogen( m, m.tubules.tubuleparams.prob_free_branch_scaling )
%                         freeBranchScalingPerVertex = max( 0, leaf_getTubuleParamsPerVertex( m, 'prob_free_branch_scaling' ) );
%                         if length(unique(freeBranchScalingPerVertex))==1
%                             freeBranchScalingPerVertex = freeBranchScalingPerVertex(1);
%                         end
%                     else
%                         freeBranchScalingPerVertex = 1;
%                     end
                    if isMorphogen( m, m.tubules.tubuleparams.prob_xover_branch_scaling )
                        xoverBranchScalingPerVertex = max( 0, leaf_getTubuleParamsPerVertex( m, 'prob_xover_branch_scaling' ) );
                        if length(unique(xoverBranchScalingPerVertex))==1
                            xoverBranchScalingPerVertex = xoverBranchScalingPerVertex(1);
                        end
                    else
                        xoverBranchScalingPerVertex = 1;
                    end
                    doXoverBranchScaling = (numel(xoverBranchScalingPerVertex) > 1) || (xoverBranchScalingPerVertex(1) ~= 1);
                    if doXoverBranchScaling
                        xoverbranchscaling = interpolateOverMesh( m, xoverBranchScalingPerVertex, colliderCell(crossbranch), colliderCellBcs(crossbranch,:), m.tubules.tubuleparams.branch_scaling_interp_mode );
                        foo = find(crossbranch);
                        foo( rand(length(foo),1) < xoverbranchscaling ) = [];
                        if any(foo)
                            xxxx = 1;
                        end
                        crossbranch( foo ) = false;
                    end
                end
                
                branchother = crossbranch & (rand( length(crossbranch), 1 ) < m.tubules.tubuleparams.prob_crossover_branch_collided);
                branchself = crossbranch & ~branchother;
                
                % We do not here have access to the index of the
                % microtubule s. We use 0 to represent its index. The
                % modified s will, after this function returns, be inserted
                % back into m by leaf_iterateStreamlines.
                selfindex = 0;
                selfsegindex = length( s.vxcellindex ) - 1;
                
                numpendingevents = sum(crosses);
                
                pendingtypeother = repmat( 'c', 1, numpendingevents );
                pendingtypeother( cutother(crosses) ) = 's';
                pendingtypeother( branchother(crosses) ) = 'b';
                
                pendingtypeself = repmat( 'c', 1, numpendingevents );
                pendingtypeself( cutself(crosses) ) = 's';
                pendingtypeself( branchself(crosses) ) = 'b';
                
                pendingeventtypes = [ pendingtypeother, pendingtypeself ];
                
                
%                 pendingeventtypes = repmat( 'c', 1, numpendingevents*2 );
%                 pendingeventtypes( cutother | cutself ) = 's';
%                 pendingeventtypes( crossbranch ) = 'b';
                pendingevents2.mt = [ collidedwith(crosses); selfindex+zeros(numpendingevents,1) ];
                pendingevents2.segindex = [ collidedseg(crosses); selfsegindex+zeros(numpendingevents,1) ];
                pendingevents2.segbc = [ collidedsegbc(crosses,:); collidersegbc(crosses,:) ];
                pendingevents2.type = pendingeventtypes;
                pendingevents2.angleclass = repmat( angleclass(crosses), 2, 1 );
                pendingevents2.angle = [ collisionangle(crosses); zeros(numpendingevents,1) ];
                
                
                
                pendingevents.mt = [ collidedwith(cutother); selfindex+zeros(sum(cutself),1) ];
                pendingevents.segindex = [ collidedseg(cutother); selfsegindex+zeros(sum(cutself),1) ];
                pendingevents.segbc = [ collidedsegbc(cutother,:); collidersegbc(cutself,:) ];
                pendingevents.type = repmat( 's', length( pendingevents.mt ), 1 );
                pendingevents.angleclass = [ angleclass(cutother); angleclass(cutself) ];
                pendingevents.angle = [ collisionangle(cutother); zeros(sum(cutself),1) ];
                
                if numpendingevents > 0
                    xxxx = 1;
                end
                
                if any(crossbranch)
                    pendingevents.mt =         [ pendingevents.mt;         collidedwith(branchother)+zeros(sum(branchother),1); zeros(sum(branchself),1) ];
                    pendingevents.segindex =   [ pendingevents.segindex;   collidedseg(branchother);                            selfsegindex+zeros(sum(branchself),1) ];
                    pendingevents.segbc =      [ pendingevents.segbc;      collidersegbc(branchother,:);                        collidersegbc(branchself,:) ];
                    pendingevents.type =       [ pendingevents.type;       repmat( 'b', sum(crossbranch), 1 ) ];
                    pendingevents.angleclass = [ pendingevents.angleclass; angleclass(crossbranch) ];
                    pendingevents.angle =      [ pendingevents.angle;      collisionangle(branchother);                         zeros(sum(branchself),1) ];
                    xxxx = 1;
                end
                
%                 numcrosses = sum( crosses );
%                 pendingevents1.mt =         [ pendingevents.mt; collidedwith(crosses)+zeros(numcrosses,1); zeros(sum(crosses),1) ];
%                 pendingevents1.segindex =   [ pendingevents.segindex; collidedseg(crosses); selfsegindex+zeros(numcrosses,1) ];
%                 pendingevents1.segbc =      [ pendingevents.segbc; collidedsegbc(crosses,:); collidersegbc(crosses,:) ];
%                 pendingevents1.type =       [ pendingevents.type; repmat( 'c', numcrosses*2, 1 ) ];
%                 pendingevents1.angleclass = [ pendingevents.angleclass; angleclass(crosses) ];
%                 pendingevents1.angle =      [ pendingevents.angle; collisionangle(crosses); zeros(sum(branchself),1) ];
%                 if numcrosses > 1
%                     xxxx = 1;
%                 end

                
                % Record stats for checking probabilities are fulfilled.
                numangleclasses = length( m.tubules.tubuleparams.collision_angles ) + 1;
                if size( m.tubules.statistics.outcomeangle, 1 ) < numangleclasses
                    m.tubules.statistics.outcomeangle( numangleclasses, 1 ) = 0;
                end
                for ai=1:length(angleclass)
                    ac = angleclass(ai);
                    if zippers(ai)
                        m.tubules.statistics.outcomeangle( ac, 1 ) = 1 + m.tubules.statistics.outcomeangle( ac, 1 );
                    elseif cats(ai)
                        m.tubules.statistics.outcomeangle( ac, 2 ) = 1 + m.tubules.statistics.outcomeangle( ac, 2 );
                    elseif crosses(ai)
                        m.tubules.statistics.outcomeangle( ac, 3 ) = 1 + m.tubules.statistics.outcomeangle( ac, 3 );
                        if crossbranch(ai)
                            m.tubules.statistics.outcomecross( 1 ) = 1 + m.tubules.statistics.outcomecross( 1 );
                        elseif cutself(ai)
                            m.tubules.statistics.outcomecross( 2 ) = 1 + m.tubules.statistics.outcomecross( 2 );
                        elseif cutother(ai)
                            m.tubules.statistics.outcomecross( 3 ) = 1 + m.tubules.statistics.outcomecross( 3 );
                        else
                            m.tubules.statistics.outcomecross( 4 ) = 1 + m.tubules.statistics.outcomecross( 4 );
                        end
                    end
                end
                
                pendingevents.globalcoords = zeros( length(pendingevents.mt), 3 );
                for pei=1:length(pendingevents.mt)
                    mti = pendingevents.mt(pei);
                    if mti==0
                        mt = s;
                    else
                        mt = m.tubules.tracks( mti );
                    end
                    segindex = pendingevents.segindex(pei);
                    segvxs = mt.globalcoords( [segindex, segindex+1], : );
                    segbcs = pendingevents.segbc( pei, : );
                    pendingevents.globalcoords(pei,:) = segbcs * segvxs;
                end

                NEW_PENDING_EVENTS = true;
                if NEW_PENDING_EVENTS
                    usependingevents = pendingevents2;
                else
                    usependingevents = pendingevents;
                end
                % Sort the pending events into descending order of segment index and segmentbc for each tubule.
                if ~isempty( usependingevents.mt )
%                     [pendingeventdata,perm] = sortrows( [ usependingevents.mt usependingevents.segindex usependingevents.segbc, double(usependingevents.type) ], 'descend' );
                    [pendingeventdata,perm] = sortrows( [ usependingevents.mt usependingevents.segindex usependingevents.segbc ], 'descend' );
                    usependingevents.mt = pendingeventdata(:,1);
                    usependingevents.segindex = pendingeventdata(:,2);
                    usependingevents.type = usependingevents.type( perm );
                    usependingevents.angleclass = usependingevents.angleclass( perm );
                    usependingevents.angle = usependingevents.angle( perm );
%                     usependingevents.segbc = pendingeventdata(:,[3 4]);
%                     usependingevents.type = char( pendingeventdata(:,5) );

                    for i=1:length( usependingevents.mt )
                        mti = usependingevents.mt(i);
                        if mti==0
                            s1 = s;
                        else
                            s1 = m.tubules.tracks(mti);
                        end
                        [s1,ok] = insertPendingEventInMT( m, s1, usependingevents.segindex(i), usependingevents.segbc(i,:), usependingevents.type(i), usependingevents.angle(i) );
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
        end
    end
    
    validStreamline( m, s );
    
    newdirglobal = streamlineGlobalDirection( m, s );
    dirchange = vecangle( olddirglobal, newdirglobal );
    if dirchange > pi - 0.1
        timedFprintf( 1, 'Reversal of streamline id %d: angle %g degrees.\n', s.id, dirchange );
        s
        xxxx = 1;
    end
end

function [m,s,stopped] = stopStreamline( m, s, stoppingreason )
    switch stoppingreason
        case 's'
            % Spontaneous stop.
            s.status.head = 0;
            % m.tubules.statistics.spontaneousstop = m.tubules.statistics.spontaneousstop + 1;
            m.tubules.statistics.spontstopinfo(end+1,1:5) = [ double(s.vxcellindex(end)), s.barycoords(end,:), double(Steps(m)+1) ];
            stopped = true;
        case { 'c', 'e' }
            % Spontaneous catastrophe.
            s.status.head = -1;
            if stoppingreason=='e'
%                 m.tubules.statistics.edgecatastrophe = m.tubules.statistics.edgecatastrophe + 1;
                m.tubules.statistics.edgecatastropheinfo(end+1,1:5) = [ double(s.vxcellindex(end)), s.barycoords(end,:), double(Steps(m)+1) ];
            else
                % m.tubules.statistics.spontaneouscatastrophe = m.tubules.statistics.spontaneouscatastrophe + 1;
                m.tubules.statistics.spontaneouscatastropheinfo(end+1,1:5) = [ double(s.vxcellindex(end)), s.barycoords(end,:), double(Steps(m)+1) ];
            end
            stopped = true;
        otherwise
            % Not stopped.
            stopped = false;
    end
end

function [splitmt,ok] = insertPendingEventInMT( m, splitmt, collideseg, segbc, eventType, angleoffset )
% %     timedFprintf( 1, 'Inserting pending event point into mt %d at segment %d, bc [%f, %f].\n', ...
%         collidedwith, collideseg, segbc );
    [splitmt,vx,ok] = insertVertexInMT( m, splitmt, collideseg, segbc );
    if ~ok
        timedFprintf( 1, 'problem inserting pending event point at segment %d, bc [%f, %f].\nEvent ignored.\n', ...
            collideseg, segbc );
        xxxx = 1;
        return;
    end
    
    if ~isempty( splitmt.status.severance )
        existingPendingEventVxs = [splitmt.status.severance.vertex];
        if any( vx == existingPendingEventVxs )
            % There is already a pending event at this vertex. Do not
            % add a new one.
            xxxx = 1;
            return;
        end
    end
    
    switch eventType
        case 's'
            delay = m.tubules.tubuleparams.delay_cut;
        case 'b'
            delay = m.tubules.tubuleparams.delay_branch;
        case 'c'
            delay = Inf;
        otherwise
            % Should not happen.
            timedFprintf( 1, 'Pending event inserted of unknown type ''%s''.\n',eventtype );
            delay = m.tubules.tubuleparams.delay_cut;
    end
    
    pendingEvent = struct( ...
            'time', m.globalDynamicProps.currenttime + delay, ...
            'vertex', vx, ...
            'FE', splitmt.vxcellindex(vx), ...
            'bc', splitmt.barycoords(vx,:), ...
            'globalpos', splitmt.globalcoords(vx,:), ...
            'eventtype', eventType, ...
            'angleoffset', angleoffset ...
        );
    if isempty( splitmt.status.severance )
        splitmt.status.severance = pendingEvent;
    else
        splitmt.status.severance(end+1) = pendingEvent;
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

