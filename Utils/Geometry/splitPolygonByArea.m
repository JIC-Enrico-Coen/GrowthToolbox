function splitpoint = splitPolygonByArea( d, vxs, n, arearatio )
    numvxs = size(vxs,1);
    xx = dot( vxs, repmat( d, numvxs, 1 ), 2 );
    v3 = cross( n, d );
    v3 = v3/norm(v3);
    yy = dot( vxs, repmat( v3, numvxs, 1 ), 2 );
    
    [X,Yleft,Yright,Area] = polygonArea2( [xx,yy] );

    splitarea = arearatio*Area(end);
    split = binsearchupper( Area, splitarea );
    if splitarea==Area(split)
        splitx = Area(split);
    else
        x1 = X(split-1);
        x2 = X(split);
        dx = x2 - x1;
        y1 = Yright(split-1);
        y2 = Yleft(split);
        dy = y2 - y1;
        grad = dy/dx;
        QA = grad/2;
        QB = y1 - x1*grad;
        QC = Area(split-1) + x1*(grad*x1/2 - y1) - splitarea;
        disc = sqrt( QB*QB - 4*QA*QC);
        splitx = (-QB + disc)/(2*QA);
        if (splitx < x1) || (splitx > x2)
            fprintf( 1, '%s: neg root required.\n', mfilename() );
            splitx = (-QB - disc)/(2*QA);
            if (splitx < x1) || (splitx > x2)
                fprintf( 1, '%s: neither root valid.\n', mfilename() );
                splitx = (x1+x2)/2;
            end
        end
      % checksplitarea = Area(split-1) + z*z*(dy/(2*dx)) + z*y1;
    end
    % Now find the edges that splitx splits.
    splitpoint = splitx*d; % [ splitx*d(1), splitx*v3(1), splitx*n(1) ]
end
