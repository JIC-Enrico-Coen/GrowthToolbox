function m = leaf_mgen_color( m, varargin )
%m = leaf_mgen_color( m, ... )
%   Associate colours with morphogens.
%   Options:
%       'morphogen'    The morphogens to attach colours to.  This can be a
%                      single morphogen name, an array of morphogen
%                      indexes, or a cell array of morphogen names.
%       'color'        Either a single letter, as used in various Matlab
%                      plotting functions, a single RGB triple (row or
%                      column), or a 3*N array of colours, one for each of
%                      the N morphogens specified by the morphogen
%                      argument.  If you give an N*3 array instead it will
%                      transpose it for you, unless N=3, in which case you
%                      have to get it right yourself.  The colours are the
%                      columns, not the rows.
%                      Instead of a single letter, it can be a pair of
%                      letters, in which case the first is used for the
%                      color of positive values and the second for negative
%                      values.  If numerical values are supplied, color can
%                      be an 3*N*2 array, in which color(:,:,1) is used as
%                      described above for the positive values, and
%                      color(:,:,2) is used for the negative values.
%                      If colours are not provided for negative values,
%                      colours opposite to those supplied for positive
%                      values will automatically be used.
%       'poscolor'     The color for positive values.
%       'negcolor'     The color for negative values.
%
%   Topics: Morphogens, Plotting.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'morphogen', [], 'color', 'r', 'poscolor', 'r', 'negcolor', 'b' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'morphogen', 'color', 'poscolor', 'negcolor' );
    if ~ok, return; end
    
    if isempty( s.morphogen )
        return;
    end
    
    s.color = rectifyColor( s.color );
    s.poscolor = rectifyColor( s.poscolor );
    s.negcolor = rectifyColor( s.negcolor );
    
    if isempty(s.color)
        if isempty(s.poscolor)
            if isempty(s.negcolor)
                colors = reshape( [ [1;0;0], [0;0;1] ], [1 3 2] );
            else
                colors = oppositeColor( s.negcolor );
                colors(:,:,2) = s.negcolor;
            end
        else
            colors = s.poscolor;
            colors(:,:,2) = oppositeColor( s.poscolor );
        end
    else
        colors = s.color;
    end
    csz = size(colors);
    if length(csz) > 3
        complain( '%s: Wrong shape of colour array: %d dimensions found, no more than 3 required.', ...
            mfilename(), length(csz) );
        return;
    end
    mgenindexes = FindMorphogenIndex( m, s.morphogen, mfilename() );
    if isempty( mgenindexes )
        return;
    end
    if (size(colors,2)==1) && (length(mgenindexes) > 1)
        colors = repmat( colors, 1, length(mgenindexes) );
    end
    if size(colors,2) ~= length(mgenindexes)
        complain( '%s: Wrong number of colours: %d found, %d morphogens.\n', ...
            mfilename(), size(colors,2), length(mgenindexes) );
        return;
    end
    if size(colors,3)==1
        colors(:,:,2) = oppositeColor( colors' )';
    end
    
    mgenindexes = mgenindexes(mgenindexes ~= 0);
    m.mgenposcolors(:,mgenindexes) = colors(:,1:length(mgenindexes),1);
    m.mgennegcolors(:,mgenindexes) = colors(:,1:length(mgenindexes),2);
end

function c = rectifyColor( c )
% Convert named colors to rgb values as a 3*N array.
% If c is already numeric, swap its first two dimensions c if that will
% make the first dimension have length 3.

    if ischar(c)
        c = namedColor( c )';
    end
    cs = size(c);
    if (cs(1) ~= 3) && (cs(2)==3)
        cs([1 2]) = cs([2 1]);
        c = reshape( c, cs );
    end
end

% function c = rgbFromColorName( c )
% % Convert a string of color names to a 3*N array of colors.
% % If the argument is numeric it is left unchanged.
%     if ischar(c)
%         c = namedColor( cname )';
%     end
%     
% %     if ischar(c)
% %         rgb = zeros( 3, length(c) );
% %         for i=1:length(c)
% %             switch c(i)
% %                     case 'r'
% %                         rgb(:,i) = [1;0;0];
% %                     case 'g'
% %                         rgb(:,i) = [0;1;0];
% %                     case 'b'
% %                         rgb(:,i) = [0;0;1];
% %                     case 'c'
% %                         rgb(:,i) = [0;1;1];
% %                     case 'm'
% %                         rgb(:,i) = [1;0;1];
% %                     case 'y'
% %                         rgb(:,i) = [1;1;0];
% %                     case 'o'
% %                         rgb(:,i) = [1;0.5;0];
% %                     case 'k'
% %                         rgb(:,i) = [0;0;0];
% %                     case 'w'
% %                         rgb(:,i) = [1;1;1];
% %                     otherwise
% %                         % Unexpected colour name.
% %                         rgb(:,i) = [1;1;1];
% %             end
% %         end
% %     else
% %         rgb = c;
% %     end
% end
