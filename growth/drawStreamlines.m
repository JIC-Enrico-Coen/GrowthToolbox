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
    xovervxs = false( xnumpoints, 1 );
    length1tracks = false( xnumpoints, 1 );
    a = 1;
    c = 1;
    headstatus = ones(1,length(s));
    tailstatus = ones(1,length(s));
    for i=1:length(s)
        b = a + max(length( s(i).vxcellindex ) - 1,0);
        allcellindex( a:b ) = s(i).vxcellindex;
        allbc( a:b, : ) = s(i).barycoords;
        if length( s(i).iscrossovervx ) == b-a+1
            xovervxs( a:b ) = s(i).iscrossovervx;
        else
            xxxx = 1;
        end
        length1tracks(1) = a==b;

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
        if a >= b
            tailstatus(i) = -1;
        else
            tailstatus(i) = s(i).status.catshrinktail;
        end
        
        a = b+2;
    end
    allvxs = baryToEuc( m, allcellindex, allbc, m.plotdefaults.streamlineoffset );
    allbegin = baryToEuc( m, allbegin_ci, allbegin_bc, m.plotdefaults.streamlineoffset );
    allend = baryToEuc( m, allend_ci, allend_bc, m.plotdefaults.streamlineoffset );
    allmiddle = baryToEuc( m, allmiddle_ci, allmiddle_bc, m.plotdefaults.streamlineoffset );
    
    if isfield( m.tubules.tubuleparams, 'linecolormap' )
        linecolormap = m.tubules.tubuleparams.linecolormap;
    else
        linecolormap = m.plotdefaults.streamlinecolor;
    end
    
    if isfield( m.tubules.tracks(1), 'linecolorindex' )
        linecolorindexes = [ s.linecolorindex ];
        if all( linecolorindexes==1 )
            m.tubules.tubuleparams.linecolormap = m.plotdefaults.streamlinecolor;
        end
    else
        linecolorindexes = ones( 1, length(s) );
    end
    
    
    % if isfield( m.tubules.tracks(1), 'linecolorindex' ) && isfield( m.tubules.tubuleparams, 'linecolormap' )
        vxsPerTubule = zeros( 1, length(s) );
        for si=1:length(s)
            vxsPerTubule(si) = length( s(si).vxcellindex );
        end
        % linecolorindexes = [ s.linecolorindex ];
        [linecolorindexes1,perm] = sort( linecolorindexes );
        [starts,ends] = runends( linecolorindexes1 );
        for ci=1:length(starts)
            linecolorindex1 = linecolorindexes1(starts(ci));
            whichTubules = perm(starts(ci):ends(ci));
            allcellindex1 = [ s(whichTubules).vxcellindex ];
            allbc1 = vertcat( s(whichTubules).barycoords );
            allvxs1 = baryToEuc( m, allcellindex1, allbc1, m.plotdefaults.streamlineoffset );
            vxsPerTubule1 = vxsPerTubule( whichTubules );
            cvxsPerTubule1 = cumsum( vxsPerTubule1 );
            tubuleStarts = [1 cvxsPerTubule1(1:(end-1))+1];
            lineIndex = zeros( 1, length( allcellindex1 ) );
            lineIndex( tubuleStarts ) = 1;
            lineIndex = cumsum(lineIndex) - 1;
            foo2 = lineIndex + (1:length(lineIndex));
            allvxs2 = nan( max(foo2), 3 );
            allvxs2( foo2, : ) = allvxs1;
            slhandles.h_streamlines(ci) = plotpts( theaxes, allvxs2, '-', ...
                'Color', m.tubules.tubuleparams.linecolormap( linecolorindex1, : ), ...
                'LineWidth', m.plotdefaults.streamlinethick );
        end
    % end
    
    
    
%     slhandles.h_streamlines = plotpts( theaxes, allvxs, '-', ...
%         'Color', m.plotdefaults.streamlinecolor, ...
%         'LineWidth', m.plotdefaults.streamlinethick );
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
        taggedheads = false( 1, length(s) );
        
        for si=1:length(s)
            taggedheads(si) = isfield( s(si), 'overrideparams' ) ...
                              && isstruct(s(si).overrideparams) ...
                              && ~isempty(fieldnames(s(si).overrideparams));
        end
        taggedheads = taggedheads & growingheads;
        growingheads = growingheads & ~taggedheads;
        
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
            endcolor = 'm';
            slhandles.end(shrinkingheads) = plotpts( theaxes, allend(shrinkingheads,:), dottype, ...
                'Color', endcolor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize, ...
                'MarkerFaceColor', endcolor );
        end
        if any(taggedheads)
            endcolor = 'r';
            slhandles.end(shrinkingheads) = plotpts( theaxes, allend(taggedheads,:), dottype, ...
                'Color', endcolor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize, ...
                'MarkerFaceColor', 'y' );
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
    
    if isfield( m.plotdefaults, 'streamlinexoversymbol' ) && ~isempty( m.plotdefaults.streamlinexoversymbol ) && (m.plotdefaults.streamlinemiddotsize > 0)
        if any( xovervxs )
            slhandles.xovervxs = plotpts( theaxes, allvxs( xovervxs, : ), m.plotdefaults.streamlinexoversymbol, ...
                'Color', middlecolor, ...
                'MarkerSize', m.plotdefaults.streamlinemiddotsize, ...
                'MarkerFaceColor', middlecolor );
        end
    end
    
    if false && isfield( m.plotdefaults, 'drawstreamlinebranchpoints' ) && m.plotdefaults.drawstreamlinebranchpoints && (m.plotdefaults.streamlineenddotsize > 0)
        if isfield( m.tubules.statistics, 'spontbranchinfo' ) && ~isempty( m.tubules.statistics.spontbranchinfo )
            branchinfo = m.tubules.statistics.spontbranchinfo;
            branchelements = branchinfo(:,1);
            branchbcs = branchinfo(:,2:4);
            branchgcs = meshBaryToGlobalCoords( m, branchelements, branchbcs );
            branchPointColor = [1 0 1];
            slhandles.spontbranch = plotpts( theaxes, branchgcs, 'o', ...
                'Color', branchPointColor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize * 2, ...
                'MarkerFaceColor', branchPointColor );
        end

        if isfield( m.tubules.statistics, 'xoverbranchinfo' ) && ~isempty( m.tubules.statistics.xoverbranchinfo ) && (m.plotdefaults.streamlineenddotsize > 0)
            branchinfo = m.tubules.statistics.xoverbranchinfo;
            branchelements = branchinfo(:,1);
            branchbcs = branchinfo(:,2:4);
            branchgcs = meshBaryToGlobalCoords( m, branchelements, branchbcs );
            branchPointColor = [0 0 1];
            slhandles.xoverbranch = plotpts( theaxes, branchgcs, 'o', ...
                'Color', branchPointColor, ...
                'MarkerSize', m.plotdefaults.streamlineenddotsize * 2, ...
                'MarkerFaceColor', [1 0 0], ...
                'LineWidth', 2 );
        end
    end
    
    set(theaxes,'NextPlot',oldhold);
end
