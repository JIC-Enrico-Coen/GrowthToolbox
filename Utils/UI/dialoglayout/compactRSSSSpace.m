function s = compactRSSSSpace( s )
%s = compactRSSSSpace( s )
%   Given a structure s describing a dialog layout, set the position
%   attributes of every object to fit everything into the smallest possible
%   space.

    for i=1:length(s.children)
        s.children{i} = compactRSSSSpace( s.children{i} );
    end
    if strcmp( s.type, 'menu' )
        return;
    end
    switch s.type
        case { 'panel', 'figure', 'radiogroup', 'group' }
            if s.attribs.singlechild
                minsize = [0 0];
                for i=1:length(s.children)
                    minsize = max( minsize, s.children{i}.attribs.minsize );
                end
                minrowheights = minsize(2);
                mincolwidths = minsize(1);
            else
                widths = zeros( s.attribs.rows, s.attribs.columns );
                heights = zeros( s.attribs.rows, s.attribs.columns );
                c = 1;
                for j=1:s.attribs.columns
                    for i=1:s.attribs.rows
                        if c > length(s.children)
                            widths(i,j) = 0;
                            heights(i,j) = 0;
                        else
                            widths(i,j) = s.children{c}.attribs.minsize(1);
                            heights(i,j) = s.children{c}.attribs.minsize(2);
                        end
                        c = c+1;
                    end
                end
                minrowheights = max( heights, [], 2 );
                if s.attribs.equalheights
                    minrowheights(:) = max( minrowheights );
                end
                mincolwidths = max( widths, [], 1 );
                if s.attribs.equalwidths
                    mincolwidths(:) = max( mincolwidths );
                end
            end
            imhoriz = s.attribs.innermargin(1)*max(0,s.attribs.columns-1);
            imvert = s.attribs.innermargin(2)*max(0,s.attribs.rows-1);
            outer = s.attribs.outermargin([1 3]) + s.attribs.outermargin([2 4]);
            newminsize = max( s.attribs.minsize, ...
                [ sum(mincolwidths)+imhoriz+outer(1), sum(minrowheights)+imvert+outer(2) ] );
            if isfield( s.attribs, 'interiorsize' )
                sizechange = newminsize - s.attribs.interiorsize([3 4]);
                s.attribs.position = [ ...
                    s.attribs.position(1), ...
                    s.attribs.position(2) - sizechange(2), ...
                    s.attribs.position([3 4]) + sizechange ];
                s.attribs.interiorsize([3 4]) = newminsize;
            else
                sizechange = newminsize - s.attribs.position([3 4]);
                s.attribs.position = [ ...
                    s.attribs.position(1), ...
                    s.attribs.position(2) - sizechange(2), ...
                    newminsize ];
            end
    end
    if s.attribs.square
        s.attribs.position([3 4]) = max(s.attribs.position([3 4]));
    end
    switch s.type
        case {'slider', 'xlabel', 'ylabel', 'zlabel' }
            % Nothing
        otherwise
            if size( s.attribs.position, 2 ) >= 4
                s.attribs.minsize = max( s.attribs.minsize, s.attribs.position([3 4]) );
            end
    end
  % s_a_ms = s.attribs.minsize
end
