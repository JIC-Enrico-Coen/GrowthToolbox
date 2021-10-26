function img = gethiresimage( m, mag, antialias, filename )
    start = tic();
    export_args = { sprintf( '-m%g', mag ), '-transparent' };
    if antialias
        export_args{end+1} = '-a2';
    else
        export_args{end+1} = '-a1';
    end
    backcolor = trimnumber( 0, round( m.plotdefaults.bgcolor * 255 ), 255 );
    wantcolorbar = m.plotdefaults.drawcolorbar;
    wantscalebar = m.plotdefaults.drawscalebar;
    wantlegend = m.plotdefaults.drawlegend;
    colorbar = [];
    scalebar = [];
    legend = [];
    if wantcolorbar || wantscalebar || wantlegend
        handles = guidata( m.pictures(1) );
        if wantcolorbar && isfield( handles, 'colorbar' ) && ishghandle( handles.colorbar ) % && ~isempty( get(handles.colorbar,'Children') )
            colorbar = handles.colorbar;
        end
        if wantscalebar && isfield( handles, 'scalebar' ) && ishghandle( handles.scalebar )
            scalebar = handles.scalebar;
        end
        if wantlegend && isfield( handles, 'legend' ) && ishghandle( handles.legend )
            legend = handles.legend;
        end
    end
    
    img = get1image( m, 1, backcolor, [colorbar,scalebar,legend], export_args );
    if length(m.pictures) >= 2
        % Stereo pair
        img2 = get1image( m, 2, backcolor, [colorbar,scalebar,legend], export_args );
        REDGREEN = true;
        if REDGREEN
            img = combineRedGreen( img, img2, backcolor );
        else
            img = abutImages( img, img2 );
        end
    end
    
    if (nargin >= 4) && ~isempty( filename )
        imwrite( img, filename, 'png' );
    end
    interval = toc(start);
    fprintf( 1, '%s: %g seconds, mag %g, aa %c.\n', mfilename, interval, mag, boolchar(antialias) );

end

function img = get1image( m, pic, backcolor, otherhandles, export_args )
    [img, alph] = export_fig( [m.pictures(pic), otherhandles], export_args{:} );
    img = cleanimg( img, alph, backcolor );
end

function im = cleanimg( im, al, backcolor )
    if size(im,3)==1
        % Convert grayscale to RGB.
        im = repmat(im,1,1,3);
    end
    
    % Fill transparent parts by the background colour.
    for i=1:3
        i1 = im(:,:,i);
        i1(al==0) = backcolor(i);
        im(:,:,i) = i1;
    end
end

function img = abutImages( img1, img2, c )
    h = max( size(img1,1), size(img2,1) );
    img1 = padvertical( img1, h, c );
    img2 = padvertical( img2, h, c );
    img = [img1,img2];
end

function img = combineRedGreen( img1, img2, c )
    h = max( size(img1), size(img2) );
    img1 = padvertical( img1, h(1), c );
    img2 = padvertical( img2, h(1), c );
    img1 = padhorizontal( img1, h(2), c );
    img2 = padhorizontal( img2, h(2), c );
    img = rgbToGray( img1 );
    img(:,:,2) = rgbToGray( img2 );
    img(:,:,3) = img(:,:,2);
end

function img = rgbToGray( img )
    isint = isinteger(img);
    img = sum(img,3)/size(img,3);
    if isint
        img = uint8(img);
    end
end

function img = padvertical( img, h, c )
    h0 = size(img,1);
    if h > h0
        range = (h0+1) : h;
        for i=1:length(c)
            img(range,:,i) = c(i);
        end
    end
end

function img = padhorizontal( img, h, c )
    h0 = size(img,2);
    if h > h0
        range = (h0+1) : h;
        for i=1:length(c)
            img(:,range,i) = c(i);
        end
    end
end
