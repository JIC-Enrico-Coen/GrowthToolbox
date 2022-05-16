function [m,rimnodes] = newcirclemesh( sz, circumdivs, nrings, centre, hollow, inneredges, ...
                                       dealign, sector, coneangle )
%[m,rimnodes] = newcirclemesh( sz, circum, nrings, centre, inner, dealign, sector, coneangle )

    m = [];
    rimnodes = [];

    % Fill in default values for all arguments.
    if (nargin < 1) || isempty(sz)
        sz = [2 2 1];
    end
    if (nargin < 2) || isempty(circumdivs) || ((length(circumdivs)==1) && (circumdivs < 3))
        circumdivs = 0;
    end
    if (nargin < 3) || isempty(nrings) || (nrings <= 0)
        nrings = 4;
    end
    if (nargin < 4) || isempty( centre )
        centre = [0,0,0];
    end
    if (nargin < 5) || isempty( hollow )
        hollow = 0;
    end
    if (nargin < 6) || isempty( inneredges )
        inneredges = 0;
    end
    if (nargin < 7) || isempty( dealign )
        dealign = false;
    end
    if (nargin < 8) || isempty( sector )
        sector = 1;
    end
    if (nargin < 9) || isempty( coneangle )
        if sz(3) ~= 0
            coneangle = pi/2;
        else
            coneangle = 0;
        end
    end
    
    circumdivs = max( circumdivs, 3 );
    
    % Some of the zeros we filled in still represent default values, but
    % defaults that depend on other values.  We calculate these now.
    % So far, the following arguments are known to have real values:
    %   sz, nrings, centre, hollow, dealign, sector, coneangle.
    % The remainder must be filled in if zero:
    %   circum, inneredges
    
    % Find the total number of rings there would be if the circle was not
    % hollow.
    totalrings = max( 1, round( nrings/(1-hollow) ) );
    
    % The default for circum is determined by totalrings.
    if circumdivs==0
        circumdivs = totalrings*6;
    end
    
    if length(circumdivs)==1
        % The default for inneredges is determined by circum, hollow, and nrings.
        if inneredges==0
            if hollow==0
                inneredges = max( floor(circumdivs/nrings), 3 );
            else
                inneredges = max( round(circumdivs*hollow), 3 );
            end
        end

        if totalrings==1
            vxsPerRing = circumdivs;
        elseif hollow==0
            vxsPerRing = arithprog( inneredges, circumdivs, nrings );
        else
            vxsPerRing = arithprog( inneredges, circumdivs, nrings+1 );
        end
    else
        % circumdivs must specify the required number of vertexes for every
        % ring.
        numUnspecifiedCircumdivs = nrings + 1 - length(circumdivs) - (hollow==0);
        if numUnspecifiedCircumdivs ~= 0
            fprintf( 1, '%s: circumdivs has length %d, %d expected.\n', ...
                mfilename(), length(circumdivs), length(circumdivs)-numUnspecifiedCircumdivs );
            return;
        end
        vxsPerRing = circumdivs;
    end
    
    if hollow==0
        vxsPerRing = [ 1 vxsPerRing ];
    end
%     epts = ellipsePoints( xsemidiam, ysemidiam, numpts )
    radii = linspace( hollow, 1, length(vxsPerRing) );
    edgesPerRing = vxsPerRing;
    if sector ~= 1
        edgesPerRing = edgesPerRing - 1;
    end
    if hollow==0
        edgesPerRing(1) = 0;
    end
    numtris = 2*sum(edgesPerRing) - edgesPerRing(1) - edgesPerRing(end);
    
    
    r = sqrt(sz(1)*sz(2))/2;
    if length(sz)==2 || (sz(3)==0)
        if coneangle==0
            sz(3) = 0;
        else
            if abs(coneangle) < 0.001
                h = coneangle*r/2;
            else
                h = r*(1-cos(coneangle))/sin(coneangle);
                if coneangle < 0
                    h = -h;
                end
            end
            sz(3) = h;
            coneangle = abs(coneangle);
        end
    elseif (sz(3) ~= 0) && (coneangle == 0)
        coneangle = pi/2;
    end
    
    offsets = zeros( 1, length(vxsPerRing) );
    if dealign
        for i=length(vxsPerRing):-1:1
            m = vxsPerRing(i);
            n = vxsPerRing(i+1);
            g = gcd(m,n);
            desynch = randi([1,n])*m/n;
            desynch = desynch - floor(desynch);
            offsets(i) = ((-1)^i)*g/(2*n) + desynch;
        end
    end
    sectorAngle = sector*pi*2;
    if coneangle ~= 0
        csc_ca = 1/sin(coneangle);
        cos_ca = cos(coneangle);
    end
    
    if hollow==0
        pts = [0.0 0.0 sz(3)];
    else
        pts = zeros(0,3);
    end
    np = 0;
    angles = cell(1,nrings);
    for i=1:length(vxsPerRing)
        cn = vxsPerRing(i);
        if cn==1
            angles{i} = 0;
            pts(1,:) = [0 0 sz(3)];
        else
            radius = radii(i);
            if sector==1
                angleStep = sectorAngle/cn;
            else
                angleStep = sectorAngle/(cn-1);
            end
            angles{i} = (((0:(cn-1)) + offsets(i))*angleStep)';
            if sz(3) ~= 0
                phi = coneangle*radius;
                h0 = csc_ca*(1-cos_ca);
                cphi = cos(phi);
                sphi = sin(phi);
                hphi = csc_ca*(cphi-cos_ca);
                rphi = csc_ca*sphi;
                pts((np+1):(np+cn),[1 2]) = ...
                    [ cos(angles{i}), sin(angles{i}) ] * rphi;
                pts((np+1):(np+cn),3) = sz(3) * hphi / h0;
            else
                pts((np+1):(np+cn),[1 2]) = ...
                    [ cos(angles{i}), sin(angles{i}) ]*radius;
            end
        end
        np = np+cn;
    end
    tri = zeros(numtris,3);
    if hollow==0
        if sector==1
            lastVx = 2;
        else
            lastVx = vxsPerRing(2)+1;
        end
        tri(1:edgesPerRing(2),1:3) = [ ones(edgesPerRing(2),1), ...
                                      (2:(edgesPerRing(2)+1))', ...
                                      [(3:(edgesPerRing(2)+1))'; lastVx] ];
        generateRingsFrom = 2;
        ntri = edgesPerRing(2);
        pis_inner = 2:(vxsPerRing(2)+1);
    else
        generateRingsFrom = 1;
        ntri = 0;
        pis_inner = 1:vxsPerRing(generateRingsFrom);
    end
    for i = generateRingsFrom:(length(vxsPerRing)-1)
        outerStart = pis_inner(end)+1;
        pis_outer = outerStart : (outerStart - 1 + vxsPerRing(i+1));
        iistart = 1;
        ii = iistart;
        imax = length(pis_inner);
        oistart = 1;
        oi = oistart;
        omax = length(pis_outer);
        detectend = false;
        while true
            if (sector ~= 1) && ((ii==imax) || (oi==omax))
                break;
            end
            ii1 = ii+1; if ii1 > imax, ii1 = 1; end
            oi1 = oi+1; if oi1 > omax, oi1 = 1; end
            outerPt = pts( pis_outer(oi), : );
            innerPt = pts( pis_inner(ii), : );
            outerPt1 = pts( pis_outer(oi1), : );
            innerPt1 = pts( pis_inner(ii1), : );
            outerDiag = norm( outerPt1 - innerPt );
            innerDiag = norm( outerPt - innerPt1 );
            nextOuter = outerDiag <= innerDiag;
            if nextOuter
                nextIndex = pis_outer(oi1);
            else
                nextIndex = pis_inner(ii1);
            end
            ntri = ntri+1;
            tri(ntri,:) = [ pis_inner(ii), pis_outer(oi), nextIndex ];
            if nextOuter
                oi = oi1;
            else
                ii = ii1;
            end
          % fprintf( 1, 'ii %d oi %d\n', ii, oi );
            if detectend && ((ii==iistart) || (oi==oistart))
                break;
            end
            if (ii ~= iistart) && (oi ~= oistart)
                detectend = true;
            end
        end
        if sector ~= 1
            if ii==imax
                while oi < omax
                    oi1 = oi+1;
                    ntri = ntri+1;
                    tri(ntri,:) = [ pis_inner(ii), pis_outer(oi), pis_outer(oi1) ];
                    oi = oi1;
                end
            else
                % oi==omax
                ii1 = ii+1;
                ntri = ntri+1;
                tri(ntri+1,:) = [ pis_inner(ii1), pis_inner(ii), pis_outer(oi) ];
            end
        else
            if ii==iistart
                % oi ~= oistart
              % fprintf( 1, 'ii == iistart == %d, oi %d oistart %d\n', ...
              %     ii, oi, oistart );
                while oi ~= oistart
                    oi1 = oi+1;  if oi1 > omax, oi1 = 1; end
                    ntri = ntri+1;
                    tri(ntri,:) = [ pis_inner(ii), pis_outer(oi), pis_outer(oi1) ];
                    oi = oi1;
                end
            else
                while ii ~= iistart
                    ii1 = ii+1;  if ii1 > imax, ii1 = 1; end
                    ntri = ntri+1;
                    tri(ntri,:) = [ pis_inner(ii1), pis_inner(ii), pis_outer(oi) ];
                    ii = ii1;
                end
            end
        end
        
        pis_inner = pis_outer;
    end
    pts(:,1) = pts(:,1) * (sz(1)/2);
    pts(:,2) = pts(:,2) * (sz(2)/2);
    pts = pts + repmat( centre, size(pts,1), 1 );
    
    
    m = struct( 'nodes', pts, 'tricellvxs', tri );
    m.globalProps.trinodesvalid = true;
    m.globalProps.prismnodesvalid = false;

    numnodes = size(m.nodes,1);
%         rimnodes = [ (numnodes-circums(totalrings)+1); ...
%                      (numnodes:-1:(numnodes-circums(totalrings)+2))' ];
    rimnodes = ((numnodes-vxsPerRing(end)+1):numnodes)';
end
