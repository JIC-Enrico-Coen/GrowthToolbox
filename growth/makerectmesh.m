function m = makerectmesh( x, y, c, nx, ny, taper )
%m = makerectmesh( x, y, c, nx, ny )
%    Make a rectangular plate divided into triangles.
%    If x is a single number, it is the diameter of the mesh along the x
%    axis.  If it is a pair of numbers, it is the minimum and maximum x
%    value.  y is similar.
%    nx and ny are the number of cells it is subdivided into each way.
%    nx may be a pair of numbers: in this case the first number is the
%    number of divisions along the lower edge (lesser y value) and the
%    second is the number of divisions along the upper edge.
%    c is the position of the centre of the rectangle.

% x, y, nx, and xy must be positive.

    if nargin < 6
        taper = [1 1];
    end

    if length(x)==1
        xmin = -x/2;
        xmax = x/2;
    else
        xmin = x(1);
        xmax = x(2);
    end
    if length(y)==1
        ymin = -y/2;
        ymax = y/2;
    else
        ymin = y(1);
        ymax = y(2);
    end
    
    ycoords = linspace( ymin, ymax, ny+1 );
    if (length(nx)==2) && (nx(1)==0)
        nx = nx(2);
    end
    if length(nx)==1
        numnodes = (nx+1)*(ny+1);
        numhedges = nx*(ny+1);
        numvedges = (nx+1)*ny;
        numdedges = nx*ny;
        numedges = numhedges + numvedges + numdedges;
        numcells = 2*nx*ny;
        lowercellstart = 0;
        uppercellstart = nx*ny;

        m = setemptymesh( numnodes, numedges, numcells );
        m.globalProps.trinodesvalid = true;
        m.globalProps.prismnodesvalid = false;

        xcoords = linspace( xmin, xmax, nx+1 );

        for j=0:ny
            for i=1:nx+1
                pi = point_index(i,j,nx);
                m.nodes(pi,1:2) = [ xcoords(i), ycoords(j+1) ];
                if (i <= nx) && (j < ny)
                    fi_lower = lowercellstart + lcell_index(i,j,nx);
                    fi_upper = uppercellstart + ucell_index(i,j,nx);
                    if mod( i+j, 2 )==0
                        m.tricellvxs( fi_lower, 1:3 ) = ...
                            [ point_index(i,j,nx), ...
                              point_index(i+1,j,nx), ...
                              point_index(i,j+1,nx) ];
                        m.tricellvxs( fi_upper, 1:3 ) = ...
                            [ point_index(i+1,j+1,nx), ...
                              point_index(i,j+1,nx), ...
                              point_index(i+1,j,nx) ];
                    else
                        m.tricellvxs( fi_lower, 1:3 ) = ...
                            [ point_index(i,j,nx), ...
                              point_index(i+1,j,nx), ...
                              point_index(i+1,j+1,nx) ];
                        m.tricellvxs( fi_upper, 1:3 ) = ...
                            [ point_index(i+1,j+1,nx), ...
                              point_index(i,j+1,nx), ...
                              point_index(i,j,nx) ];
                    end
                end
            end
        end
    else
        nx1 = nx(1);
        nx2 = nx(2);
        nxs = arithprog( nx1+1, nx2+1, ny+1 );
        numnodes = sum(nxs);
        numedges = 0;
        numcells = 0;
        m = setemptymesh( numnodes, numedges, numcells );
        m.globalProps.trinodesvalid = true;
        m.globalProps.prismnodesvalid = false;

        nn = 0;
        nc = 0;
        fliprow = false;
        for iy=0:ny
            % Create nodes.
            fliprow = ~fliprow;
            flip = fliprow;
            rowlength = nxs(iy+1);
            ins = (nn+1):(nn+rowlength);
            nn = nn+rowlength;
            m.nodes( ins, : ) = [ ...
                linspace( xmin, xmax, rowlength )', ...
                ycoords(iy+1) * ones(rowlength,1), ...
                zeros(rowlength,1) ];
            % If iy > 0, create cells between current row and previous row.
            if iy > 0
                ir0 = 1;
                ir1 = 1;
                num0 = length(previns);
                num1 = length(ins);
                while (ir0 < num0) && (ir1 < num1)
                    in0 = previns(ir0);
                    in1 = ins(ir1);
                    n0 = m.nodes( in0, : );
                    n1 = m.nodes( in1, : );
                    n0next = m.nodes( in0+1, : );
                    n1next = m.nodes( in1+1, : );
                    d01 = n1next-n0;
                    d01 = sum(d01.*d01);
                    d10 = n0next-n1;
                    d10 = sum(d10.*d10);
                    nc = nc+1;
                    if d01==d10
                        flip = ~flip;
                        diag01 = flip;
                    else
                        diag01 = d01 < d10;
                    end
                    if diag01
                        m.tricellvxs(nc,:) = [ in0, in1+1, in1 ];
                        ir1 = ir1+1;
                    else
                        m.tricellvxs(nc,:) = [ in0, in0+1, in1 ];
                        ir0 = ir0+1;
                    end
                end
                in0 = previns(ir0);
                in1 = ins(ir1);
                if ir0 < num0
                    newcells = num0-ir0;
                    m.tricellvxs((nc+1):(nc+newcells), : ) = ...
                        [ (in0:(in0+newcells-1))', ...
                          ((in0+1):(in0+newcells))', ...
                          repmat( in1, newcells, 1 ) ];
                    nc = nc + newcells;
                elseif ir1 < num1
                    newcells = num1-ir1;
                    m.tricellvxs((nc+1):(nc+newcells), : ) = ...
                        [ repmat( in0, newcells, 1 ), ...
                          ((in1+1):(in1+newcells))', ...
                          (in1:(in1+newcells-1))' ];
                    nc = nc + newcells;
                end
            end
            previns = ins;
        end
    end
    
    haveTaper = any(taper ~= 1);
    if haveTaper
        xwidth1 = xmax-xmin;
        xwidth2 = xwidth1 * taper(1);
        ywidth1 = ymax-ymin;
        ywidth2 = ywidth1 * taper(2);
        x1 = c(1) - xwidth1/2;
        x2 = c(1) + xwidth1/2;
        y1 = c(2) - ywidth1/2;
        y2 = c(2) + ywidth1/2;
        nodes_x = m.nodes(:,1);
        nodes_y = m.nodes(:,2);
        nodes_xx = c(1) + (nodes_x-c(1)) .* (1 - (nodes_y-y1)./(y2-y1) * (1 - xwidth2/xwidth1));
        nodes_yy = c(2) + (nodes_y-c(2)) .* (1 - (nodes_x-x1)./(x2-x1) * (1 - ywidth2/ywidth1));
        m.nodes(:,1) = nodes_xx;
        m.nodes(:,2) = nodes_yy;
        xxxx = 1;
    end
    
    m.nodes = m.nodes + repmat( c, size(m.nodes,1), 1 );

    m.borders = struct( ...
        'xmin', find(m.nodes(:,1)==xmin), ...
        'xmax', find(m.nodes(:,1)==xmax), ...
        'ymin', find(m.nodes(:,2)==ymin), ...
        'ymax', find(m.nodes(:,2)==ymax) );
end

function pi = point_index( i, j, nx )
    pi = (nx+1)*j+i;
end

function lfei = lcell_index( i, j, nx )
    lfei = nx*j+i;
end

function ufei = ucell_index( i, j, nx )
    ufei = nx*j+i;
end

        
