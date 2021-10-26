function [m,rimnodes] = hexcircle( r, n, c )
% OBSOLETE.  Use newcirclemesh instead.
%m = HEXCIRCLE(r,n,c)  Make a circle triangulated into a hexagon of
%triangles.
%   R           Radius
%   N           Number of concentric circles of triangles
%   C           Centre

    if isempty(r)
        r = 1;
    end

    nodesPerSeg = n*(n+1)/2;
    outedgesPerSeg = nodesPerSeg - n;
    cellsPerSeg = nodesPerSeg + outedgesPerSeg;
    centralNode = nodesPerSeg*6 + 1;

    s3over2 = sqrt(3)/2;
    scale = r/n;
    numrimnodes = 6*n;
    rimnodes = zeros(numrimnodes,1);
    currimnode = numrimnodes;
    for i=1:6 % i indexes the sector.
        theta = (i-1)*pi/3;
        sth = sin(theta);
        cth = cos(theta);
        for j=1:n % j indexes the ring.
            for k=1:j % k indexes position on sector i of ring j.
                pti = pointIndex(n,nodesPerSeg,i,j,k);
                x0 = (j - (k-1)/2)*scale;
                y0 = (k-1)*s3over2*scale;
                alpha = atan2(y0,x0);
                r1 = sin(pi/3)/sin(2*pi/3 - alpha);
                expansion = 1/r1;
                x = (x0*cth - y0*sth)*expansion;
                y = (x0*sth + y0*cth)*expansion;
                m.nodes(pti,:) = [ x, y, 0 ];
                if j==n
                    rimnodes(currimnode) = pti;
                    currimnode = currimnode-1;
                end
                fi0 = cellIndex(cellsPerSeg,nodesPerSeg,i,j,k,0);
                if (k < j)
                    e0p2 = pointIndex(n,nodesPerSeg,i,j,k+1); % pti+1;
                    e1p2 = pointIndex(n,nodesPerSeg,i,j-1,k); % pti-j+1;
                else
                    e0p2 = pointIndex(n,nodesPerSeg,mod(i,6)+1,j,1);
                    if (j==1)
                        e1p2 = centralNode;
                    else
                        e1p2 = pointIndex(n,nodesPerSeg,mod(i,6)+1,j-1,1);
                    end
                end
                m.tricellvxs(fi0,:) = [ pti, e0p2, e1p2 ];
                if j < n
                    fi1 = fi0 + nodesPerSeg;
                    e2p2 = pointIndex(n,nodesPerSeg,i,j+1,k+1); % pti + j + 1;
                    m.tricellvxs(fi1,:) = [ pti, e2p2, e0p2 ];
                end
            end
        end
    end
    m.nodes(centralNode,:) = [0,0,0];
    m.nodes = m.nodes + repmat( c, size(m.nodes,1), 1 );
    m.globalProps.trinodesvalid = true;
    m.globalProps.prismnodesvalid = false;
end

function pti = pointIndex(n,nps,i,j,k)
    pti = (i-1)*nps + j + (k-1)*(n+n-k)/2;
end

function fi = cellIndex(fps,nps,i,j,k,f)
    fi = (i-1)*fps + j*(j-1)/2 + k + f*nps;
end

