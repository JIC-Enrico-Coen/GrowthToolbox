function [m,contours,cvals] = plotContours( m, data, numvals, cvals, colors, perVertex, offset, thickness )
    if nargin < 8
        thickness = 2;
    end
    if (nargin < 7) || isempty(offset)
        offset = 1.2;
    end
    if (nargin < 6) || isempty(perVertex)
        perVertex = true;
    end
    if ischar(data) || (numel(data)==1)
        data = FindMorphogenIndex( m, data );
        if isempty(data)
            return;
        end
        data = data(1);
        data = m.morphogens( :, data );
    else
        if ~perVertex
            data = perFEtoperVertex( m, data );
        end
    end
    if (nargin < 4) || isempty(cvals)
        cvals = linspace( min(data), max(data), numvals+2 );
        cvals = cvals(2:(end-1));
    end
    if (nargin < 5) || isempty( colors )
        colors = [0 0 0];
    end
    vxsA = m.prismnodes(1:2:end,:);
    vxsB = m.prismnodes(2:2:end,:);
    vxs = vxsB*((1+offset)/2) + vxsA*((1-offset)/2);
    edges = m.edgeends;
%     if perVertex
%         vxs = m.nodes;
%         edges = m.edgeends;
%     else
%         vxs = squeeze( sum( reshape( m.nodes( m.tricellvxs', : ), 3, [], 3 ), 1 )/3 );
%         edges = m.edgecells;
%         edges = edges(edges(:,2)>0,:);
%     end
    
    contours = cell(1,length(cvals));
    
    endvals = data( edges );
    if (~isempty(m.pictures)) && ishandle(m.pictures(1))
        fig = m.pictures(1);
        h = guidata(fig);
        ax = h.picture;
    else
        fig = 1;
        figure(fig);
        clf;
        ax = gca;
    end
    hold(ax,'on');
    onecolor = size(colors,1)==1;
    if onecolor
        linecolor = colors;
    end
    hh = gobjects(1,length(cvals));
    
    for i=1:length(cvals)
        cvali = cvals(i);
        crossedges = (endvals(:,1) >= cvali) ~= (endvals(:,2) >= cvali);
        beta = (cvali-endvals(crossedges,1))./(endvals(crossedges,2)-endvals(crossedges,1));
        alpha = 1-beta;
        cvxs = vxs( edges(crossedges,1), : ) .* repmat( alpha, 1, 3 ) ...
              + vxs( edges(crossedges,2), : ) .* repmat( beta, 1, 3 );

        if true || perVertex
            ceis = (1:sum(crossedges))'; % find(crossedges);
            zz = sortrows( [ [m.edgecells( crossedges, 1 ), ceis]; [m.edgecells( crossedges, 2 ), ceis] ] );
            zz1 = find( zz(:,1)>0, 1 );
            zz = zz(zz1:end,:);
            lines = zz(1:(end-1),1) == zz(2:end,1);
            cvxs1 = cvxs( zz(lines,2), : );
            cvxs2 = cvxs( zz([false;lines],2), : );
            if ~onecolor
                linecolor = colors(i,:);
            end
%             plotPtsToPts( cvxs1, cvxs2, ...
%                 'Color', linecolor, 'LineWidth', thickness, 'Parent', ax );
            hh(i) = line( [ cvxs1(:,1)'; cvxs2(:,1)' ], ...
                  [ cvxs1(:,2)'; cvxs2(:,2)' ], ...
                  [ cvxs1(:,3)'; cvxs2(:,3)' ], ...
                  'Color', linecolor, 'LineWidth', thickness, 'Parent', ax );
            hh.Tag = sprintf( 'contours%30d', i );
        end
        % plotpts( ax, cvxs, 'o', 'MarkerEdgeColor', rand(1,3) );
        contours{i} = cvxs;
    end
    hold(ax,'off');
    
    m.plothandles.contours = hh;
    
    for i=1:length(cvals)
    end
end
