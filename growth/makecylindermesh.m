function m = makecylindermesh( xwidth, ywidth, centre, height, nx, ny, ...
    topcap, topheight, toprings, ...
    basecap, baseheight, baserings )
%m = makecylindermesh( x, y, centre, height, nx, ny, topcap, basecap, etc... )
%    Make a cylindrical surface divided into triangles.
%    x is the radius and y the height.
%    There are nx cells around and ny cells vertically.
%    nx must be at least 3 and ny at least 1.
%    topcap and basecap are booleans: if true, a hemispherical end will
%    be added to the top or base.
%
% All arguments must be positive.

    if nx < 3
        fprintf( 1, 'A cylinder must have at least 3 cells around, requested number was %d.\n', nx );
        m = setemptymesh( 0, 0, 0 );
        return;
    end
%     if ny < 1
%         fprintf( 1, 'A cylinder must be at least 1 cell tall, requested number was %d.\n', ny );
%         m = setemptymesh( 0, 0, 0 );
%         return;
%     end
    havecylinder = height > 0;
    if ~havecylinder && ~topcap && ~basecap
        fprintf( 1, 'A cylinder must have either positive height or at least one end cap.\n' );
        m = setemptymesh( 0, 0, 0 );
        return;
    end
    
    
    avradius = sqrt(xwidth*ywidth/4);

    if havecylinder
        numnodes = nx*(ny+1);
        numhedges = nx*(ny+1);
        numvedges = nx*ny;
        numdedges = nx*ny;
        numedges = numhedges + numvedges + numdedges;
        numcells = 2*nx*ny;
        lowercellstart = 0;
        uppercellstart = nx*ny;

        mcyl = setemptymesh( numnodes, numedges, numcells );
        mcyl.globalProps.trinodesvalid = true;

        angles = linspace( 0, 2*pi*(1 - 1/nx), nx );
        xcoords = (xwidth/2)*cos(angles);
        ycoords = (ywidth/2)*sin(angles);
        zcoords = linspace( -height/2, height/2, ny+1 );
        for j=0:ny
            for i=1:nx
                i1 = mod(i,nx)+1;
                p_i = point_index(i,j,nx);
                p_i1 = point_index(i1,j,nx);
                mcyl.nodes(p_i,:) = [ xcoords(i), ycoords(i), zcoords(j+1) ];
                if j < ny
                    fi_lower = lowercellstart + lcell_index(i,j,nx);
                    fi_upper = uppercellstart + ucell_index(i,j,nx);
                    p_ij1 = point_index(i,j+1,nx);
                    p_i1j1 = point_index(i1,j+1,nx);
                    if mod( i+j, 2 )==0
                        mcyl.tricellvxs( fi_lower, 1:3 ) = ...
                            [ p_i, p_i1, p_ij1 ];
                        mcyl.tricellvxs( fi_upper, 1:3 ) = ...
                            [ p_i1j1, p_ij1, p_i1 ];
                    else
                        mcyl.tricellvxs( fi_lower, 1:3 ) = ...
                            [ p_i, p_i1, p_i1j1 ];
                        mcyl.tricellvxs( fi_upper, 1:3 ) = ...
                            [ p_i1j1, p_ij1, p_i ];
                    end
                end
            end
        end

        mcyl.globalProps.prismnodesvalid = false;
        cylinderbasenodes = (1:nx)';
        cylindertopnodes = ((numnodes-nx+1):numnodes)';
    end
    
    
    if topcap
        if toprings==0
            toprings = max( 1, ceil(avradius*pi*0.25*ny/topheight) );
        end
        sz = [ xwidth, ywidth, topheight*avradius ];
        [mtop,tcaprim] = newcirclemesh( sz, nx, toprings, [0,0,0], 0, 0, false, 1, 0 );
        mtop.nodes(:,3) = mtop.nodes(:,3) + height/2;
    end
    if basecap
        if baserings==0
            baserings = max( 1, ceil(avradius*pi*0.25*ny/baseheight) );
        end
        sz = [ xwidth, ywidth, -baseheight*avradius ];
        [mbase,bcaprim] = newcirclemesh( sz, nx, baserings, [0,0,0], 0, 0, false, 1, 0 );
        mbase = flipOrientation( mbase );
        mbase.nodes(:,3) = mbase.nodes(:,3) - height/2;
    end
    
    if havecylinder
        m = mcyl;
        if topcap
            m = stitchmeshes( m, mtop, cylindertopnodes, tcaprim );
        end
        if basecap
            m = stitchmeshes( m, mbase, cylinderbasenodes, bcaprim );
        end
    elseif topcap
        if basecap
            m = stitchmeshes( mtop, mbase, tcaprim, bcaprim );
        else
            m = mtop;
        end
    else
        m = mbase;
    end
    m.nodes = m.nodes + repmat( centre, size(m.nodes,1), 1 );
end

function p_i = point_index( i, j, nx )
    p_i = int32(nx*j+i);
end

function lfei = lcell_index( i, j, nx )
    lfei = int32(nx*j+i);
end

function ufei = ucell_index( i, j, nx )
    ufei = int32(nx*j+i);
end

        
