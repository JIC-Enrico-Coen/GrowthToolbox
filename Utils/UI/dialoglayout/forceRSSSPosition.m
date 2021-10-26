function s = forceRSSSPosition( s, pos )
if any(pos([3 4]) <= 0 )
    fprintf( 1, 'forcePosition: bad position [%f %f %f %f]\n', pos );
    error('ads:asd','afrfe');
end
%    if ~isempty( s.handle )
%        set( s.handle, 'Position', pos );
%    end
    pos([1 3]) = alignpos( pos([1 3]), s.attribs.minsize(1), s.attribs.halign );
    pos([2 4]) = alignpos( pos([2 4]), s.attribs.minsize(2), s.attribs.valign );
    if s.attribs.square && (pos(3) ~= pos(4))
        if pos(3) < pos(4)
            pos(4) = pos(3);
            valign = s.attribs.valign;
            if strcmp( valign, 'fill' )
                valign = 'center';
            end
            pos([2 4]) = alignpos( pos([2 4]), s.attribs.minsize(2), valign );
        else
            pos(3) = pos(4);
            halign = s.attribs.halign;
            if strcmp( halign, 'fill' )
                halign = 'center';
            end
            pos([1 3]) = alignpos( pos([1 3]), s.attribs.minsize(1), halign );
        end
    end
    if isfield( s.attribs, 'interiorsize' )
        s.attribs.interiorsize([3 4]) = s.attribs.interiorsize([3 4]) + pos([3 4]) - s.attribs.position([3 4]);
    end
    s.attribs.position = pos;
    if length(pos) ~= 4
        error('Bad pos');
    end
    switch s.type
        case { 'panel', 'figure', 'radiogroup', 'group' }
            excesssize = max( s.attribs.position([3 4]) - s.attribs.minsize, 0 );
            if isfield( s.attribs, 'interiorsize' )
                interiorposition = s.attribs.interiorsize;
            else
                interiorposition = s.attribs.position;
            end
            xstart = interiorposition(1) + s.attribs.outermargin(1);
            ystart = interiorposition(2) + interiorposition(4) - s.attribs.outermargin(2);
            switch s.attribs.halign
                case 'center'
                    xstart = xstart + excesssize(1)/2;
                case 'right'
                    xstart = xstart + excesssize(1);
            end
            switch s.attribs.valign
                case 'center'
                    ystart = ystart - excesssize(2)/2;
                case 'bottom'
                    ystart = ystart - excesssize(2);
            end
            if ~isempty( s.children )
                if s.attribs.singlechild
                    innerpos = interiorposition + s.attribs.outermargin([1 2 1 2]).*[1 1 -2 -2];
                    for c=1:length(s.children)
                        s.children{c} = forceRSSSPosition( s.children{c}, innerpos );
                    end
                else
                    hfills = true( s.attribs.rows, s.attribs.columns );
                    vfills = true( s.attribs.rows, s.attribs.columns );
                    widths = zeros( s.attribs.rows, s.attribs.columns );
                    heights = zeros( s.attribs.rows, s.attribs.columns );
                    c = 1;
                    for j=1:s.attribs.columns
                        for i=1:s.attribs.rows
                            if c <= length(s.children)
                                hfills(i,j) = strcmp( s.children{c}.attribs.halign, 'fill' );
                                vfills(i,j) = strcmp( s.children{c}.attribs.valign, 'fill' );
                                widths(i,j) = s.children{c}.attribs.minsize(1);
                                heights(i,j) = s.children{c}.attribs.minsize(2);
                            end
                            c = c+1;
                        end
                    end
                    if s.attribs.equalwidths
                        widths(:) = max(widths(:));
                    end
                    if s.attribs.equalheights
                        heights(:) = max(heights(:));
                    end
                    fillingrows = any( vfills, 2 );
                    if ~any(fillingrows), fillingrows(:) = true; end
                    fillingcols = any( hfills, 1 );
                    if ~any(fillingcols), fillingcols(:) = true; end
                    rowheights = max( heights, [], 2 );
                    colwidths = max( widths, [], 1 );
                    rowheights(fillingrows) = rowheights(fillingrows) + excesssize(2)/sum(fillingrows);
                    colwidths(fillingcols) = colwidths(fillingcols) + excesssize(1)/sum(fillingcols);
                    c = 1;
                    x = xstart;
                    for j=1:s.attribs.columns
                        y = ystart;
                        for i=1:s.attribs.rows
                            y = y - rowheights(i);
                            if c <= length(s.children)
                                s.children{c} = forceRSSSPosition( s.children{c}, [x y colwidths(j) rowheights(i)] );
                            end
                            y = y - s.attribs.innermargin(2);
                            c = c+1;
                        end
                        x = x + colwidths(j) + s.attribs.innermargin(1);
                    end
                end
            end
        otherwise
    end
end

function pos = alignpos( pos, sz, alignment )
    switch alignment
        case 'fill'
            % Nothing.
        case { 'left', 'bottom' }
            pos(2) = sz;
        case 'center'
            pos(1) = pos(1) + (pos(2) - sz)/2;
            pos(2) = sz;
        case { 'right', 'top' }
            pos(1) = pos(1) + pos(2) - sz;
            pos(2) = sz;
    end
end
