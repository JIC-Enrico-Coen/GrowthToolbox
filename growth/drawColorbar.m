function drawColorbar( h, clabels, cmap, crange, cmaptype, backgroundColor, redraw )
%drawColorbar( h, cmap, crange, cmaptype, backgroundColor )
%   Draw a color bar filling the axes object h, displaying the colormap
%   cmap, annotated with scale crange.  The colorbar is drawn along the
%   longer dimension of h.  Does nothing if h is not a handle.
%   The parameters are stored in the userdata, in order to allow for
%   erasing and then restoring the colorbar without requiring a replot.
%   If no parameters are given, the parameters are retrieved from the
%   userdata and the colorbar is redrawn.

    if ~ishandle(h), return; end
    
    % set( h, 'Visible', 'on' );
    userdata = get(h,'Userdata');

%     if nargin==2
%         % Second argument is a struct holding the parameters.
%         params = clabels;
%         clabels = params.clabels;
%         if ischar(clabels)
%             clabels = {clabels,'',''};
%             params.clabels = clabels;
%         end
%         cmap = params.cmap;
%         cmaptype = params.cmaptype;
%         crange = params.crange;
%         backgroundColor = params.backgroundColor;
%     end
    
    if isempty(userdata)
        if nargin==1
            return;
        end
        needColorbarUpdate = true;
    elseif nargin==1
        needColorbarUpdate = true;
        clabels = userdata.clabels;
        cmap = userdata.cmap;
        cmaptype = userdata.cmaptype;
        crange = userdata.crange;
        backgroundColor = userdata.backgroundColor;
        redraw = true;
    else
        needColorBounds = any( crange([1 2]) ~= userdata.crange([1 2]) );
        needColorbarUpdate = needColorBounds || ~strcmp( cmaptype, userdata.cmaptype ) ...
            || (size(cmap,1) ~= size(userdata.cmap,1)) ...
            || any(cmap(:) ~= userdata.cmap(:) );
    end
    
    if ischar(clabels)
        clabels = {clabels,'',''};
    end
    ctitle = clabels{1};
    clabelhi = clabels{2};
    clabello = clabels{3};
    
    userdata.clabels = {ctitle,clabelhi,clabello};
    userdata.cmap = cmap;
    userdata.cmaptype = cmaptype;
    userdata.crange = crange;
    userdata.backgroundColor = backgroundColor;
    set(h,'Userdata',userdata);
    
    if ~redraw
        return;
    end
    
    % showhideAxisContents( h, true );    

    if (~needColorbarUpdate) % || (needColorbarUpdate && (nargin==1))
        % Colorbar is already correct.
        return;
    end
        
    hpos = get( h, 'Position' );
    
    ncolors = size( cmap, 1 );
    if isempty( crange )
        crange = [1 1];
    end
    
    if (ncolors==0) || (crange(1)==crange(2))
        blankColorBar( h, backgroundColor );
        hfig = guidata( h );
        if isfield( hfig, 'colortextlo' ) && isfield( hfig, 'colortexthi' )
            set( hfig.colortextlo, 'String', '', 'Visible', 'off' );
            set( hfig.colortexthi, 'String', '', 'Visible', 'off' );
            set( hfig.colornamelo, 'String', '', 'Visible', 'off' );
            set( hfig.colornamehi, 'String', '', 'Visible', 'off' );
            set( hfig.colortitle, 'String', '', 'Visible', 'off' );
        end
        return;
    end
    
    if crange(1)==crange(2)
        cmap = cmap(1,:);
        ncolors = size( cmap, 1 );
    end
    
    haveText = ncolors > 1;

    if ncolors==1
        cmap = [ cmap; cmap ];
        ncolors = size( cmap, 1 );
    end
    ntiles = ncolors-1;
    vertical = hpos(3) < hpos(4);
    [ticks,ranks] = scaleticks( crange(1), crange(2) );
    tickratios = (ticks - min(ticks))/(max(ticks) - min(ticks));
    numticks = length(ticks);
    if vertical
        % Draw vertically.
        x = [ zeros( 1, ntiles ); ones( 2, ntiles ) * hpos(3); zeros( 1, ntiles ) ];
        ys = (0:ntiles)*(hpos(4)/ntiles);
        y = [ ys(1:ntiles); ys(1:ntiles); ...
              ys(2:ntiles+1); ys(2:ntiles+1) ];
        ticklinesX = [ zeros( 1, numticks ); ones( 1, numticks )*hpos(3) ];
        tickheights = hpos(4)*tickratios;
        tickheights(1) = max( tickheights(1), ranks(1)/2+0.5 ); % To avoid the bottom tick falling off the edge.
        tickheights(end) = min( tickheights(end), hpos(4)-ranks(end)/2 ); % To avoid the top tick falling off the edge.
        ticklinesY = repmat( tickheights, 2, 1 );
    else
        % Draw horizontally.
        xs = (0:ntiles)*(hpos(3)/ntiles);
        x = [ xs(1:ntiles); xs(1:ntiles); ...
              xs(2:ntiles+1); xs(2:ntiles+1) ];
        y = [ zeros( 1, ntiles ); ones( 2, ntiles ) * hpos(3); zeros( 1, ntiles ) ];
        ticklinesY = [ zeros( 1, numticks ); ones( 1, numticks )*hpos(4) ];
        tickheights = hpos(3)*tickratios;
        tickheights(1) = max( tickheights(1), ranks(1)/2+0.5 ); % To avoid the leftmost tick falling off the edge.
        tickheights(end) = min( tickheights(end), hpos(3)-ranks(end)/2 ); % To avoid the rightmost tick falling off the edge.
        ticklinesX = repmat( tickheights, 2, 1 );
    end
    
    c = ones( 4, ntiles, 3 );
    c(1,:,:) = cmap( 1:ntiles, : );
    c(2,:,:) = cmap( 1:ntiles, : );
    c(3,:,:) = cmap( 2:ncolors, : );
    c(4,:,:) = cmap( 2:ncolors, : );

    cla(h);
    hold( h, 'on' );
    axis( h, [ 0 hpos(3) 0 hpos(4) ] );
    axis( h, 'off' );
    view( h, 0, 90 );

    patch( x, y, c, 'LineStyle', 'none', 'Parent', h );
    for i=1:length(ticks)
        line( ticklinesX(:,i), ticklinesY(:,i), ...
              'LineStyle', '-', 'LineWidth', ranks(i), 'Color', 'k', ...
              ... % 'LineSmoothing', 'on', ... % LineSmoothing is deprecated.
              'Parent', h );
    end
    if haveText
        hfig = guidata( h );
        if isfield( hfig, 'colortextlo' ) && isfield( hfig, 'colortexthi' )
            set( hfig.colortextlo, 'String', sprintf( '%g', crange(1) ), 'Visible', 'on' );
            set( hfig.colortexthi, 'String', sprintf( '%g', crange(2) ), 'Visible', 'on' );
            set( hfig.colornamelo, 'String', clabello, 'Visible', 'on' );
            set( hfig.colornamehi, 'String', clabelhi, 'Visible', 'on' );
            set( hfig.colortitle, 'String', ctitle, 'Visible', 'on' );
        else
          % fprintf( 1, 'drawcolorbar: no colortextlo\n' );
            units = get( h, 'Units' );
            if strcmp(units, 'pixels')
                textOffset = get( h, 'FontSize' )/2;
            else
                textOffset = 0;
            end
            if vertical
                text( hpos(3) + textOffset, textOffset, sprintf( '%g', crange(1) ), 'Parent', h );
                text( hpos(3) + textOffset, hpos(4)-textOffset, sprintf( '%g', crange(2) ), 'Parent', h );
            else
                text( textOffset, hpos(4) - textOffset, sprintf( '%g', crange(1) ), 'Parent', h );
                text( hpos(3)-textOffset, hpos(4) - textOffset, sprintf( '%g', crange(2) ), 'Parent', h );
            end
          % set( h, 'Units', oldUnits );
        end
    end
    hold( h, 'off' );
%   axes( oldaxes );
end

