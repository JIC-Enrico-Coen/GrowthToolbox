function drawSphere( ax, resLat, resLong, color )
    if isempty(resLong)
        resLong = resLat * 2;
    end
    
    resLat = 6;
    resLon = 8;
    latitudes = linspace( -pi/2, pi/2, resLat+1 );
    longitudes = linspace( -pi, pi, resLon+1 );
    longitudes(end) = [];
    slat = sin( latitudes )';
    clat = cos( latitudes )';
    slon = sin( longitudes );
    clon = cos( longitudes );
    
    X = clat * clon;
    Y = clat * slon;
    Z = repmat( slat, 1, length(latitudes) );
    
    basicFace = [ 0 0 1 0 1 1 0 1 ]; % lon lat lon lat lon lat lon lat
    offsetsLon = repmat( (1:resLon)', resLat, 1 );
    offsetsLat = reshape( repmat( 1:resLat, resLon, 1 ), [], 1 );
    
    fooLon = offsetsLon + basicFace( [1 3 5 7] );
    fooLon( fooLon==(length( longitudes )+1) ) = 1;
    fooLat = offsetsLat + basicFace( [2 4 6 8] );
    fooLat( fooLat==(length( latitudes )+1) ) = 1;
    
    X = X(:);
    Y = Y(:);
    Z = Z(:);
    
    latIndexes = 1:length( latitudes );
    latIndexes1 = [ (2:(length( latitudes ))) 1 ];
    lonIndexes = 1:length( longitudes );
    lonIndexes1 = [ (2:(length( longitudes ))) 1 ];
    facesLat = repmat( [ latIndexes(:) latIndexes1(:) latIndexes1(:) latIndexes(:) ], resLat, 1 );
    facesLon = repmat( [ lonIndexes(:) lonIndexes(:) lonIndexes1(:) lonIndexes1(:) ], resLat, 1 );
    faces = [ repmat( [ latIndexes(:) latIndexes1(:) ], length( longitudes )-1, 1 )
        
    reshape[ lonIndexes; lonIndexes1; lonIndexes1; lonIndexes ];
    
    1
end
