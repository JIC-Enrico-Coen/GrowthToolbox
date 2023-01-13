function slhandles = drawStreamlines( theaxes, m, s )
%drawStreamlines( theaxes, m, s )
%   Draw the streamlines described by s for the mesh m in axes ax.
%   s is either an array of streamlines or an array of streamline indexes.
%   If omitted it defaults to m.streamlines.
%   theaxes defaults to m.pictures(1), if it exists.
%
%   The result is a struct containing handles for the resulting graphic
%   objects.

    if isempty(theaxes) || ~ishandle(theaxes)
        return;
    end
    if nargin < 3
        s = m.tubules.tracks;
    elseif isnumeric(s)
        s = m.tubules.tracks(s);
    end
    if isempty(s)
        return;
    end
    
    oldhold = get(theaxes,'NextPlot');
    hold(theaxes,'on');
    numlines = length(s);
    numpoints = length( [s.vxcellindex] );
    xnumpoints = numpoints + numlines;
    allcellindex = ones( xnumpoints, 1 );
    allbc = nan( xnumpoints, 3 );
    allbegin_ci = nan( numlines, 1 );
    allbegin_bc = nan( numlines, 3 );
    allend_ci = nan( numlines, 1 );
    allend_bc = nan( numlines, 3 );
    allmiddle_ci = nan( numpoints-numlines*2, 1 );
    allmiddle_bc = nan( numpoints-numlines*2, 3 );
    issevvx = false( size( allmiddle_ci ) );
    a = 1;
    c = 1;
    headstatus = ones(1,length(s));
    tailstatus = ones(1,length(s));
    for i=1:length(s)
%         if length( s(i).vxcellindex ) > 1
            b = a + max(length( s(i).vxcellindex ) - 1,0);
            allcellindex( a:b ) = s(i).vxcellindex;
            allbc( a:b, : ) = s(i).barycoords;
            a = b+2;

            allbegin_ci(i) = s(i).vxcellindex(1);
            allbegin_bc(i,:) = s(i).barycoords(1,:);
            allend_ci(i) = s(i).vxcellindex(end);
            allend_bc(i,:) = s(i).barycoords(end,:);

            d = c + max( length( s(i).vxcellindex ) - 3, -1 );
            if d<0
                xxxx = 1;
            end
            allmiddle_ci(c:d) = s(i).vxcellindex(2:(end-1));
            allmiddle_bc(c:d,:) = s(i).barycoords(2:(end-1),:);
            
            if ~isempty( s(i).status.severance )
                sevvxs = [s(i).status.severance.vertex];
                sevvxs = sort( sevvxs( (sevvxs > 1) & (sevvxs < length(s(i).vxcellindex) ) ) );
                issevvx(c - 2 + sevvxs) = true;
            end
            
            c = d+1;

            headstatus(i) = s(i).status.head;
            tailstatus(i) = s(i).status.catshrinktail;
%         end
    end
    allvxs = baryToEuc( m, allcellindex, allbc, m.plotdefaults.streamlineoffset );
    allbegin = baryToEuc( m, allbegin_ci, allbegin_bc, m.plotdefaults.streamlineoffset );
    allend = baryToEuc( m, allend_ci, allend_bc, m.plotdefaults.streamlineoffset );
    allmiddle = baryToEuc( m, allmiddle_ci, allmiddle_bc, m.plotdefaults.streamlineoffset );
    
    
    
    slhandles.h_streamlines = plotpts( theaxes, allvxs, '-', ...
        'Color', m.plotdefaults.streamlinecolor, ...
        'LineWidth', m.plotdefaults.streamlinethick );
    dottype = 'o';
    
    if (size(allvxs,1) > 1) && (m.plotdefaults.streamlineenddotsize > 0)
        shrinkingtails = tailstatus==0;
        cattails = tailstatus==1;
        if any(shrinkingtails)
            begincolor = [0.25 0.25 0.25];
            slhandles.begin = plotpts( theaxes, allbegin(shrinkingtails,:), dottype, ...
                'Color', begincolor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize, ...
                'MarkerFaceColor', begincolor );
        end
        if any(cattails)
            begincolor = [1 0.45 0.6];
            slhandles.begin = plotpts( theaxes, allbegin(cattails,:), dottype, ...
                'Color', begincolor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize, ...
                'MarkerFaceColor', begincolor );
        end
    end
    
    if m.plotdefaults.streamlineenddotsize > 0
%             endcolor = 'g';
%             slhandles.end = plotpts( theaxes, allend, dottype, ...
%                 'Color', endcolor, ...
%                 'MarkerSize', m.plotdefaults.streamlineenddotsize, ...
%                 'MarkerFaceColor', endcolor );
        growingheads = headstatus==1;
        stoppedheads = headstatus==0;
        shrinkingheads = headstatus==-1;
        
        if any(growingheads)
            endcolor = 'g';
            slhandles.end(growingheads) = plotpts( theaxes, allend(growingheads,:), dottype, ...
                'Color', endcolor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize, ...
                'MarkerFaceColor', endcolor );
        end
        if any(stoppedheads)
            endcolor = 'b';
            slhandles.end(stoppedheads) = plotpts( theaxes, allend(stoppedheads,:), dottype, ...
                'Color', endcolor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize, ...
                'MarkerFaceColor', endcolor );
        end
        if any(shrinkingheads)
            endcolor = 'r';
            slhandles.end(shrinkingheads) = plotpts( theaxes, allend(shrinkingheads,:), dottype, ...
                'Color', endcolor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize, ...
                'MarkerFaceColor', endcolor );
        end
    end
    
    if m.plotdefaults.streamlineseverdotsize > 0
        if any( issevvx )
            middlecolor = m.plotdefaults.streamlinecolor;
            slhandles.middle = plotpts( theaxes, allmiddle(issevvx,:), 'o', ...
                'Color', middlecolor, ...
                'MarkerSize', m.plotdefaults.streamlineseverdotsize, ...
                'MarkerFaceColor', middlecolor );
            xxxx = 1;
        end
    end
    
    if m.plotdefaults.streamlinemiddotsize > 0
        if any( ~issevvx )
            middlecolor = m.plotdefaults.streamlinecolor;
            slhandles.middle = plotpts( theaxes, allmiddle(~issevvx,:), dottype, ...
                'Color', middlecolor, ...
                'MarkerSize', m.plotdefaults.streamlinemiddotsize, ...
                'MarkerFaceColor', middlecolor );
        end
    end
    
    set(theaxes,'NextPlot',oldhold);
end
