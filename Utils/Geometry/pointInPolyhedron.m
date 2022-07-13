function in = pointInPolyhedron( vxs, polyfaces, polyfacesigns, pts )
    [tris,~,tritoface] = facesToTris( polyfaces );
    facesigns = polyfacesigns * 2 - 1;
    
    in = ones(size(pts,1),1);
    
    for pi = 1:size(pts,1)
        pt = pts(pi,:);
        for i=1:length(tris)
            inside = sideof( pt, vxs(tris(i,:), : ) ) * facesigns( tritoface(i) );
            if inside==-1
                in(pi) = -1;
                break;
            end
            if inside==0
                in(pi) = 0;
            end
        end
    end
end

function s = sideof( pt, trivxs )
    s = sign( det( pt - trivxs ) );
end

function [tris,trisperface,tritoface] = facesToTris( polyfaces )
    trisperface = zeros( length( polyfaces ), 1 );
    tritoface = zeros( length( polyfaces ), 1 );
    numtris = 0;
    for i=1:length(polyfaces)
        trisperface(i) = length( polyfaces{i} ) - 2;
        tritoface( (numtris+1):(numtris+trisperface(i)), 1 ) = i;
        numtris = numtris + trisperface(i);
    end
    
    tris = zeros( numtris, 3 );
    numtris = 0;
    for i=1:length(polyfaces)
        pf1 = polyfaces{i};
        numpf1tris = length(pf1) - 2;
        tris( (numtris+1):(numtris+trisperface(i)), : ) = ...
            [ pf1(1)+zeros(numpf1tris,1), ...
              reshape( pf1(2:(end-1)), [], 1 ), ...
              reshape( pf1(3:end), [], 1 ) ];
        numtris = numtris + trisperface(i);
    end
end
