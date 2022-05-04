function [allvxs,alledges,allpolyvxs,allpolyedges,polypairs,borderedges,p] = blockHexCells( varargin )
    allvxs = [];
    alledges = [];
    allpolyvxs = [];
    allpolyedges = [];
    polypairs = [];
    borderedges = [];
    p = [];
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'bbox', [0 2 0 3 0 4], ...
        'faces', [true true false; true true true], ... % All faces except the bottom.
        'divisions', 2, ...
        'spacing', 0.5, ...
        'firsthexoffsets', [0.2 0.5 1], ...
        'lasthexoffsets', [0.2 0.5 1], ...
        'angle', 30, ...
        'noise', 0, ...
        'plot', true );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'bbox', 'faces', 'divisions', 'spacing', 'firsthexoffsets', 'lasthexoffsets', 'angle', 'noise', 'plot' );
    if ~ok, return; end
    
    s.bbox = reshape( s.bbox, 2, 3 );
    bboxsize = s.bbox(2,:) - s.bbox(1,:);
    bboxcentre = (s.bbox(1,:) + s.bbox(2,:))/2;
    centredbbox = s.bbox - bboxcentre;
    
    s.faces = reshape( s.faces, 2, 3 );
    
    if isempty( s.divisions )
        s.divisions = bboxsize./s.spacing;
    end
    if numel(s.divisions) == 1
        s.divisions = bboxsize * (s.divisions/mean(bboxsize));
    end
    s.divisions = round(s.divisions);
    evens = mod( s.divisions, 2 ) == 0;
    s.divisions(evens) = s.divisions(evens) + 1;
    
    vxs = cell(2,3);
    edges = cell(2,3);
    polyvxs0 = cell(2,3);
    polyvxs = cell(2,3);
    polyedges = cell(2,3);
    numvxs = 0;
    numedges = 0;
    for fi=1:6
        [signi,axi] = ind2sub( size(vxs), fi );
        % si indexes the signs: 1 is the negative face, 2 the positive face.
        % xi indexes the axes.
        [yi,zi] = othersOf3( axi );
        % Order is -x, +x, -y, +y, -z, +z.
        sgn = signi*2-3;
        if s.faces(signi,axi)
            s1 = s;
            s1.bbox = centredbbox(:,[yi,zi]);
            s1.divisions = s.divisions([yi,zi]);
            s1 = rmfield( s1, 'faces' );
            if axi==3
                % No squaring of the border cells on the Z faces.
                s1.firsthexoffsets = [3 1;1 3];
                s1.lasthexoffsets = [3 1;1 3];
            else
                % No squaring of the cells at the foot of the X and Y faces.
                if (axi==2) && (sgn==1)
                    s1.lasthexoffsets = [];
                else
                    s1.firsthexoffsets = [];
                end
            end
            s1.plot = false;
            % Rotate the Y and Z faces
            rotationNeeded = axi ~= 1;
            if rotationNeeded
                s1.bbox = s1.bbox(:,[2 1]);
                s1.divisions = s1.divisions([2 1]);
                s1.spacing = [];
            end
            [vxs1,edges{signi,axi},polyvxs{signi,axi},polyedges{signi,axi}] = rectHexCells( s1 );
            if rotationNeeded
                rotmat = [0 1;-1 0];
                vxs1 = vxs1 * rotmat;
            end
            if signi==1
                vxs1(:,1) = -vxs1(:,1);
            end
%                 vxs1 = [vxs1,zeros(size(vxs1,1),1)];
            vxs1(:,[yi zi axi]) = [vxs1,zeros(size(vxs1,1),1)];
            vxs1 = vxs1 + bboxcentre;
            vxs1(:,axi) = bboxcentre(axi) + bboxsize(axi)*sgn/2;
            vxs{signi,axi} = vxs1;
            edges{signi,axi} = edges{signi,axi} + numvxs;
            polyvxs0{signi,axi} = cellToRaggedArray( polyvxs{signi,axi}, NaN );
            polyvxs{signi,axi} = polyvxs0{signi,axi} + numvxs;
            polyedges{signi,axi} = cellToRaggedArray( polyedges{signi,axi}, NaN );
            polyedges{signi,axi} = polyedges{signi,axi} + numedges;
            numvxs = numvxs + size(vxs1,1);
            numedges = numedges + size(edges{signi,axi},1);
        end
    end
    
    allvxs = cell2mat( vxs(s.faces) );
    alledges = cell2mat( edges(s.faces) );

    % Ensure that all vertexes that are supposed to be on the surface of
    % the bounding box are exactly on the surface.
    allvxs2 = allvxs;
    for i=1:3
        tol = 0.1 * bboxsize(i)/s.divisions(i);
        allvxs( allvxs(:,i) < s.bbox(1,i)+tol, i ) = s.bbox(1,i);
        allvxs( allvxs(:,i) > s.bbox(2,i)-tol, i ) = s.bbox(2,i);
    end
%     checkallvxs = all(allvxs2(:)==allvxs(:))
    
    
    allpolyvxs = cellToRaggedArray( polyvxs(s.faces) );
    allpolyedges = cellToRaggedArray( polyedges(s.faces) );
    
    % Eliminate duplicate vertexes.
    TOL = 1e-5;
    [uvxs,vxsia,vxsic] = uniqueRowsTol( allvxs, TOL ); % 'rows', 'stable' );
    allvxs = uvxs;
    
    % Transform the arrays that contain vertex indexes.
    alledges = vxsic( alledges );
    alledges = sort(alledges,2);
    allpolyvxs(~isnan(allpolyvxs)) = vxsic( allpolyvxs(~isnan(allpolyvxs)) );
    
    % Find the shared edges.
    [uedges,ueia,ueic] = unique( alledges, 'rows', 'stable' );
    % uedges = alledges(ueia,:)
    % alledges = uedges(ueic,:)
    % ic(ia) maps each row of alledges to its 
    ueiaa = ueia(ueic);
    d1 = find( ueiaa ~= (1:size(alledges,1))' );
    d2 = ueiaa(d1);
    duplicateedges = sort([d1;d2]);
    duplicateEdgeMap = false( size(alledges,1), 1 );
    duplicateEdgeMap( duplicateedges ) = true;
    
    numpolys = size( allpolyvxs, 1 );
    edgepolys1 = [ shiftdim( allpolyedges', -1 ); shiftdim( repmat( (1:numpolys), size(allpolyedges,2), 1 ), -1 ) ];
    edgepolys2 = reshape( edgepolys1, 2, numel(allpolyedges) )';
    edgepolys3 = edgepolys2;
    edgepolys3( isnan(edgepolys3(:,1)), : ) = [];
    edgepolys3( ~duplicateEdgeMap(edgepolys3(:,1)), : ) = [];
    edgepolys3 = sortrows(edgepolys3);
    edgepolys4 = [ ueiaa(edgepolys3(:,1)), edgepolys3(:,2) ];
    edgepolys5 = sortrows( edgepolys4 );
    polypairs = reshape( edgepolys5(:,2), 2, [] )';
    polypairs = sortrows( sort( polypairs, 2, 'descend' ) ); %#ok<UDIM>
    foo = [false; polypairs(1:(end-1),1)==polypairs(2:end,1) ];
    polypairs1 = polypairs;
    polypairs1(foo,:) = [];
    polypairs = polypairs1;
    polyremap = (1:numpolys)';
    polyremap( polypairs(:,1) ) = polypairs(:,2);
    xxxx = 1;
    
    
    if s.plot
        [f,ax] = getFigure();
        cla(ax);
        if ~isempty( allpolyvxs )
            faceColors = rand(size(allpolyvxs,1),3);
            faceColors = faceColors( polyremap, : );
            p = patch( 'Parent', ax, 'Faces', allpolyvxs, 'Vertices', allvxs, ...
                'LineWidth', 1, 'LineStyle', '-', 'Marker', '.', 'MarkerSize', 20, 'FaceAlpha', 0.9, ...
                'FaceVertexCData', faceColors, 'FaceColor', 'flat' );
        end
        axis( ax, 'equal' );
        axis( ax, reshape( [ s.bbox(1,:)-bboxsize*0.5; s.bbox(2,:)+bboxsize*0.5 ], [], 1 ) );
        
        
%         [f2,ax2] = getFigure();
%         cla(ax2);
%         if ~isempty( allpolyvxs )
%             for si=1:2
%                 for xi=1:3
%                     faceColors = rand(size(polyvxs0{si,xi},1),3);
%                     p(si,xi) = patch( 'Faces', polyvxs0{si,xi}, 'Vertices', vxs{si,xi}, 'Parent', ax2, ...
%                         'LineWidth', 1, 'LineStyle', '-', 'Marker', '.', 'MarkerSize', 20, 'FaceAlpha', 0.9, ...
%                         'FaceVertexCData', faceColors, 'FaceColor', 'flat' );
%                 end
%             end
%             xxxx = 1;
%         end
%         axis( ax2, 'equal' );
%         axis( ax2, reshape( [ s.bbox(1,:)-bboxsize*0.5; s.bbox(2,:)+bboxsize*0.5 ], [], 1 ) );
%         
%         
%         [f3,ax3] = getFigure();
%         cla(ax3);
%         if ~isempty( allpolyvxs )
%             for xi=1:3
%                 for si=1:2
%                     if ~isempty( polyvxs{si,xi} )
%                         faceColors = rand(size(polyvxs{si,xi},1),3);
%                         h(si,xi) = patch( 'Faces', polyvxs{si,xi}, 'Vertices', allvxs, 'Parent', ax3, ...
%                             'LineWidth', 1, 'LineStyle', '-', 'Marker', '.', 'MarkerSize', 20, 'FaceAlpha', 0.9, ...
%                             'FaceVertexCData', faceColors, 'FaceColor', 'flat' );
%                         p(si,xi) = h(si,xi);
%                         cxxxx = 1;
%                     end
%                 end
%             end
%             xxxx = 1;
%         end
%         axis( ax3, 'equal' );
%         axis( ax3, reshape( [ s.bbox(1,:)-bboxsize*0.5; s.bbox(2,:)+bboxsize*0.5 ], [], 1 ) );
    end
end

