classdef Geometry < matlab.mixin.Copyable
%classdef Geometry
%   This class represents geometric objects in a form that can be directly
%   converted to any 3D file format, such as OBJ, DAE, or VRML.
%   All of the components are allowed to be empty.
%
%   Color is supported per vertex, per face, or per corner.  Data for at
%   most one of these should be given.  Colors can be specified by vxcolor,
%   facecolor, and facevxcolor as RGB values (vxcolor and facecolor are
%   N*3, facevxcolor is N*K*3), scalars to be mapped through a continuous
%   colour scale (the arrays are N*1 or N*K*1 of floating type), or indexes
%   into a list of colours (the arrays are N*1 or N*K*1 of integer type).
%
%   Material is supported per face.  Material should not be present if
%   colour information is present.
%
%   All fields relating to uv, normal, color, and material are optional.

    properties
        id  % A string.
        material  % An array of Material objects
        vxs  % N*3.  3D coordinates.
        uv  % U*2.  UV coords.
        normal  % Non-zero 3D vectors.
        color  % Non-zero 3D or 1D vectors.
        colorrange  % A pair of numbers, the values represented by the ends of the colorscale.
        alpha % The opacity, a vector of values in the range 0..1.
                
        vxcolor  % Color indexes per vertex.
        facecolor  % Color indexes per face.
        facevxcolor  % Color indexes per corner.
        
        facevxs  % tuples of indexes into vxs, padded with -1 if faces
                 % do not all have the same number of vertexes.

        vxuv  % Indexes into uv, one per vertex.
        facevxuv  % Tuples of indexes into uv, one per face vertex.
        
        vxnormal  % Normal indexes, one per vertex.
        facenormal  % Normal indexes, one per face.
        facevxnormal  % Normal indexes, one per face vertex.
        
        vxalpha  % Alpha indexes, one per vertex.
        facealpha  % Alpha indexes, one per face.
        facevxalpha  % Alpha indexes, one per face vertex.
        
        facemat  % For each face, an index into the material array.
        
        children  % Component Geometry objects
        childtransforms  % Transformations for all the child objects.
        
        mark % For internal purposes only.
        
        plotoptions % A struct for whatever options we might want to add.
    end
    
    methods
        function [g,ok] = Geometry( varargin )
            if (nargin > 0) && isa(varargin{1},'Geometry')
                g = varargin{1}.copy;
            else
                clearGeometry( g );
                % Reset the fields not reset by clearGeometry.
                g.id = uniqueID( 'Geometry' );
                g.children = Geometry.empty();
                g.childtransforms = zeros(4,4,0);
                g.mark = false;
                g.plotoptions = struct();
                
                % Set fields according to the arguments.
                initialiseClass( g, varargin{:} );
                if isempty(g.material) && ~isempty(g.facemat)
                    nummats = max(g.facemat)+1;
                    for i=nummats:-1:1
                        g.material(i) = Material.DefaultMaterial();
                    end
                end
                if isempty(g.childtransforms)
                    g.childtransforms = repmat( eye(4), 1, 1, length(g.children) );
                end
                
                % Force integer types for all arrays of indexes.
                g.facevxs = int32( g.facevxs );
                g.vxuv = int32( g.vxuv );
                g.facevxuv = int32( g.facevxuv );
                g.vxnormal = int32( g.vxnormal );
                g.facenormal = int32( g.facenormal );
                g.facevxnormal = int32( g.facevxnormal );
                g.vxcolor = int32( g.vxcolor );
                g.facecolor = int32( g.facecolor );
                g.facevxcolor = int32( g.facevxcolor );
                g.vxalpha = int32( g.vxalpha );
                g.facealpha = int32( g.facealpha );
                g.facevxalpha = int32( g.facevxalpha );
                g.facemat = int32( g.facemat );
            end
            ok = isValid(g);
        end
        
        function copyFrom( g, g1 )
            fns = fieldnames( g );
            for i=1:length(fns)
                fn = fns{i};
                g.(fn) = g1.(fn);
            end
        end
        
        function g2 = deepcopy( g1 )
            unmarkall( g1 );
            g2 = deepcopy1( g1 );
            unmarkall( g1 );
            
            function g2 = deepcopy1( g1 )
                if isa( g1.mark, 'Geometry' )
                    g2 = g1.mark;
                else
                    g2 = g1.copy();
                    g1.mark = g2;
                    for ci=1:length(g1.children)
                        g2.children(ci) = g1.children(ci).deepcopy();
                    end
                end
            end
        end
        
        function reflect( g, refaxes, centre )
            % Shallow reflection of g.
            g.vxs = reflectPoints( g.vxs, refaxes );
            if isempty( g.normal )
                g.facevxs = g.facevxs( :, end:-1:1 );
                g.facevxuv = g.facevxuv( :, end:-1:1 );
                g.facevxnormal = g.facevxnormal( :, end:-1:1 );
                while true
                    shortfaces = any( isnan(g.facevxs(:,1)), 2 );
                    if any(shortfaces)
                        g.facevxs(shortfaces,:) = g.facevxs(shortfaces,[2:end 1]);
                    else
                        break;
                    end
                end
            else
                g.normal = reflectPoints( g1.normal, refaxes, centre );
            end
        end
        
        function move( g, translation )
            % Shallow translation of g.
            g.vxs = translatePoints( g.vxs, translation );
        end
        
        function shallowTransform( g, transform )
            % Transform the vertexes and normals of g but not its children.
            g.vxs = transformPoints( g.vxs, transform );
            g.normal = rotatePoints( g.normal, transform(1:3,1:3) );
            if isReflectionTransform( transform )
                % We must reverse the face vertex ordering.
                g.facevxs = g.facevxs(:,end:-1:1);
                g.facevxuv = g.facevxuv(:,end:-1:1);
                g.facevxnormal = g.facevxnormal(:,end:-1:1);
            end
        end
        
        function ok = isValidRecursive( g )
            ok = isValid( g );
            for i=1:length(g.children)
                ok1 = isValidRecursive( g.children(i) );
                ok = ok && ok1;
            end
        end
        
        function ok = isValid( g, warnlevel )
            % Check the consistency of g.
            %
            % If warnlevel is 0 (the default), only fatal inconsistencies
            % will be reported (e.g. arrays the wrong size, invalid
            % indexes.)
            %
            % If warnlevel is 1, then unused vertexes, uvs, normals, and
            % colors will be reported to the console, but will not affect
            % the return value.
            %
            % If warnlevel is 2, those warnings will be made, and will be
            % considered fatal errors, i.e. ok will be false.
            
            if nargin < 2
                warnlevel = 0;
            end
            ok = true;
            
            % Check the expected number of values per vertex, uv, and
            % normal.
            ok = checkarraysize( g.vxs, [-1 3], isempty(g.facevxs), ['Invalid Geometry.vxs for ', g.id] ) && ok;
            ok = checkarraysize( g.uv, [-1 2], isempty(g.facevxuv), ['Invalid Geometry.uv for ', g.id] ) && ok;
            ok = checkarraysize( g.normal, [-1 3], isempty(g.facevxnormal), ['Invalid Geometry.normal for ', g.id] ) && ok;
            ok = checkarraysize( g.alpha, [-1 1], isempty(g.facevxalpha), ['Invalid Geometry.alpha for ', g.id] ) && ok;
            
            % Check that the face data arrays contain only valid indexes.
            ok = checkIndexingInto( g.facevxs, g.vxs, true, true, true, ['Invalid Geometry for ', g.id, '(bad facevxs)'] ) && ok;
            ok = checkIndexingInto( g.facevxuv, g.uv, true, true, true, ['Invalid Geometry for ', g.id, '(bad facevxuv)'] ) && ok;
            ok = checkIndexingInto( g.facevxnormal, g.normal, true, true, true, ['Invalid Geometry for ', g.id, '(bad facevxnormal)'] ) && ok;
            ok = checkIndexingInto( g.facemat, g.material, true, true, true, ['Invalid Geometry for ', g.id, '(bad facemat)'] ) && ok;
            ok = checkIndexingInto( g.vxcolor, g.color, true, true, true, ['Invalid Geometry for ', g.id, '(bad vxcolor)'] ) && ok;
            ok = checkIndexingInto( g.facecolor, g.color, true, true, true, ['Invalid Geometry for ', g.id, '(bad facecolor)'] ) && ok;
            ok = checkIndexingInto( g.facevxcolor, g.color, true, true, true, ['Invalid Geometry for ', g.id, '(bad facevxcolor)'] ) && ok;
            ok = checkIndexingInto( g.facevxalpha, g.alpha, true, true, true, ['Invalid Geometry for ', g.id, '(bad facevxalpha)'] ) && ok;
            
            % Check that a transformation exists for every child object and vice versa.
            if numel(g.children) ~= size(g.childtransforms,3)
                fprintf( 1, 'Invalid Geometry for %s: %d children but %d transformations.\n', ...
                    g.id, numel(g.children), size(g.childtransforms,3) );
                ok = false;
            end

            if warnlevel
                % Check that every vertex belongs to at least one face.
                usedvxs = unique(g.facevxs(g.facevxs >= 0));
                if length(usedvxs) < size(g.vxs,1)
                    if warnlevel >= 2, ok = false; end
                    fprintf( 1, 'Geometry warning for %s: %d vertexes are not referenced.\n', ...
                        g.id, size(g.vxs,1) - length(usedvxs) );
                end

                % Check that every uv vertex is used by at least one face.
                useduv = unique([ g.vxuv(g.facevxuv >= 0); g.facevxuv(g.facevxuv >= 0) ]);
                if length(useduv) < size(g.uv,1)
                    if warnlevel >= 2, ok = false; end
                    fprintf( 1, 'Geometry warning for %s: %d UV coords are not referenced.\n', ...
                        g.id, size(g.uv,1) - length(useduv) );
                end

                % Check that every normal is used by at least one face.
                usednorm = unique([ g.vxnormal(g.vxnormal >= 0); g.facenormal(g.facenormal >= 0); g.facevxnormal(g.facevxnormal >= 0) ]);
                if length(usednorm) < size(g.normal,1)
                    if warnlevel >= 2, ok = false; end
                    fprintf( 1, 'Geometry warning for %s: %d normals are not referenced.\n', ...
                        g.id, size(g.normal,1) - length(usednorm) );
                end

                % Check that every color is used by at least one face.
                usedcolor = unique([ g.vxcolor(g.vxcolor >= 0); g.facecolor(g.facecolor >= 0); g.facevxcolor(g.facevxcolor >= 0) ]);
                if length(usedcolor) < size(g.color,1)
                    if warnlevel >= 2, ok = false; end
                    fprintf( 1, 'Geometry warning for %s: %d colors are not referenced.\n', ...
                        g.id, size(g.color,1) - length(usedcolor) );
                end
            end
            
%             if ~ok
%                 xxxx = 1;  % Debug hook
%             end
        end
        
        function clearGeometry( g )
            % We cannot just create an empty Geometry object and copy it to
            % g, because this procedure is called from the creator
            % procedure.
            
            % Keep the values of g.id, g.children, g.childtransforms, and
            % mark.  Reset all other fields.
            g.material = Material.empty();
            g.vxs = zeros(0,3,'double');
            g.uv = zeros(0,2,'double');
            g.normal = zeros(0,3,'double');
            g.color = zeros(0,3,'double');
            g.colorrange = [0 1];
            g.alpha = zeros(0,1,'double');
            
            g.facevxs = zeros(0,3,'int32');
            
            g.vxcolor = zeros(0,1,'int32');
            g.facecolor = zeros(0,1,'int32');
            g.facevxcolor = zeros(0,3,'int32');
            
            g.vxalpha = zeros(0,1,'int32');
            g.facealpha = zeros(0,1,'int32');
            g.facevxalpha = zeros(0,3,'int32');
            
            g.vxuv = zeros(0,1,'int32');
            g.facevxuv = zeros(0,3,'int32');
            
            g.vxnormal = zeros(0,1,'int32');
            g.facenormal = zeros(0,1,'int32');
            g.facevxnormal = zeros(0,3,'int32');
            
            g.facemat = zeros(0,1,'int32');
        end
        
        function [bbox,h] = draw( g, ax, colorramp )
        %draw( g, ax )
        % Draw the geometry into the given axes object.
        
            if nargin < 3
                colorramp = false;
            end
            [bbox,h] = draw1( g, ax, eye(4), colorramp );
            bbox = expandBbox( bbox, 0.1 );
%             axis equal;
%             axis( bbox(:)' );
        
            function [bbox,hh] = draw1( g, ax, transform, colorramp )
            %draw( g, ax )
            % Draw the geometry into the given axes object.

                bbox = [];
                hh = gobjects(1,length(g.children));
                for i=1:length(g.children)
                    [bbox1,hh(i)] = draw1( g.children(i), ax, g.childtransforms(:,:,i)*transform, colorramp );
                    bbox = unionBbox( bbox, bbox1 );
                end
                
                if isEmptyGeometry( g )
                    return;
                end

                materialoptions = {};
                if ~isempty( g.facemat )
                    if ~colorramp && isprop( g.material, 'facecolor' )
                        materialoptions = [ materialoptions, { 'FaceColor', g.material.facecolor, 'FaceLighting', 'flat' } ];
                    end
                    if isprop( g.material, 'facealpha' )
                        materialoptions = [ materialoptions, { 'FaceAlpha', g.material.facealpha } ];
                    end
                    if isprop( g.material, 'edgecolor' )
                        materialoptions = [ materialoptions, { 'EdgeColor', g.material.edgecolor } ];
                    end
                    if isprop( g.material, 'edgealpha' )
                        materialoptions = [ materialoptions, { 'EdgeAlpha', g.material.edgealpha } ];
                    end
                elseif ~isempty( g.vxcolor )
%                     materialoptions = [ materialoptions, ...
%                                         { 'FaceVertexCData', g.vxcolor+1, ...
%                                           'CData', g.color, ...
%                                           'CDataMapping', 'direct', ...
%                                           'FaceColor', 'interp' } ];
                    materialoptions = [ materialoptions, ...
                                        { 'FaceVertexCData', g.color(g.vxcolor+1,:), ...
                                          'FaceColor', 'interp' } ];
                elseif ~isempty( g.facecolor )
%                     materialoptions = [ materialoptions, ...
%                                         { 'FaceVertexCData', g.vxcolor+1, ...
%                                           'CData', g.color, ...
%                                           'CDataMapping', 'direct', ...
%                                           'FaceColor', 'interp' } ];
                    materialoptions = [ materialoptions, ...
                                        { 'FaceVertexCData', g.color(g.facecolor+1,:), ...
                                          'FaceColor', 'flat' } ];
                end

                if false && isempty( g.normal )
                    % Calculate face corner normals and use those per-vertex.
                    [tnormal,tfacevxnormal] = defaultVertexNormals( g.vxs, g.facevxs, true );
                else
                    tnormal = g.normal;
                    tfacevxnormal = g.facevxnormal;
                end
                tvxs = transformPoints( g.vxs, transform );
                tnormal = rotatePoints( tnormal, transform );
                
                if false && (~isempty( g.facevxuv ) || ~isempty( g.facevxnormal ))
                    [tvxs1,facevxs1] = splitEdges( tvxs, g.facevxs );
                    [uv1,~] = splitEdges( g.uv, g.facevxuv );
%                     [normal1,facevxnormal1] = splitEdges( g.normal, g.facevxnormal );
%                     [material1,facemat1] = splitEdges( g.material, g.facemat );
                else
                    tvxs1 = tvxs;
                    facevxs1 = g.facevxs;
                    uv1 = [];
%                     facevxuv1 = [];
%                     normal1 = [];
%                     facevxnormal1 = [];
%                     material1 = g.material;
%                     facemat1 = g.facemat;
                end
                facevxs1(facevxs1==-1) = NaN;
                
                if colorramp
                    if isempty( g.uv )
                        faceVertexCData = ones( size(tvxs1,1), 3 );
                    else
                        faceVertexCData = colorFromRamp( uv1(:,1), uv1(:,2) );
                    end
                    materialoptions = [ materialoptions, ...
                                        { 'FaceVertexCData', faceVertexCData, ...
                                          'CData', g.color, ...
                                          ... % Should CDataMapping be set to something?
                                          'FaceColor', 'interp' } ];
                end
                
                if isempty( g.alpha )
                    alph = 0.8;
                else
                    alph = g.alpha;
                end
                htop = patch( 'Faces', facevxs1+1, 'Vertices', tvxs1, ...
                       'Tag', g.id, ...
                       'FaceLighting', 'gouraud', ...
                       'EdgeLighting', 'flat', ...
                       'LineStyle', 'none', ...
                       'Parent', ax, ...
                       'FaceAlpha', alph, ...
                       materialoptions{:} );
                bbox1 = [ min(tvxs,[],1); max(tvxs,[],1) ];
                bbox = unionBbox( bbox, bbox1 );

                drawedges = isfield( g.plotoptions,'drawedges') && (g.plotoptions.drawedges > 1);
                if drawedges
                % We do not want to draw edges twice, once for each surface
                % face they belong to.
                %
                % If we have face normal data, we do not want to draw edges
                % for which the vertexes at each end have the same normals
                % in both adjoining faces.
                    numfaces = size(g.facevxs,1);
                    numcorners = size(g.facevxs,2);
                    edges = reshape( [ g.facevxs'; circshift(g.facevxs,-1,2)' ], numcorners, 2, numfaces );
                    edges(:,3,:) = shiftdim( repmat( 1:numfaces, numcorners, 1 ), -1 );
                    edges(:,4,:) = shiftdim( repmat( (1:numcorners)', 1, numfaces ), -1 );
                    edges(:,5,:) = shiftdim( repmat( ([2:numcorners 1])', 1, numfaces ), -1 );
                    edges = reshape( permute( edges, [2 1 3] ), size(edges,2), [] )';
                    nan1 = isnan(edges(:,1));
                    nan2 = isnan(edges(:,2));
                    edges(nan2,5) = 1;
                    edges(nan2,2) = g.facevxs( sub2ind( size(g.facevxs), edges(nan2,3), edges(nan2,5)) );
    %                 edges(nan2,5) = 1;
    %                 edges(nan2,[2 5]) = edges(nan1,[1 4]);
                    edges( nan1, : ) = [];



    %                 edges( isnan(edges(:,1)), : ) = [];
    %                 foo = isnan(edges(:,2));
    %                 edges( foo, 2 ) = 0;
    %                 edges( foo, 5 ) = 1;
    %                 edges = reshape( permute( edges, [2 1 3] ), size(edges,2), [] )';

                    flip = edges(:,1) > edges(:,2);
                    edges(flip,:) = edges(flip,[2 1 3 5 4]);
                    edges = sortrows(edges);
                    repeatedEdges = all( edges(1:(end-1),[1 2])==edges(2:end,[1 2]), 2 );
                    e1 = [repeatedEdges; false];
                    e2 = [false; repeatedEdges];

                    havenormals = ~isempty( tfacevxnormal );

                    if havenormals
                        normal1aindex = tfacevxnormal(sub2ind( size(g.facevxs), edges(e1,3), edges(e1,4) ));
                        normal1a = tnormal(1+normal1aindex,:);
                        normal1bindex = tfacevxnormal(sub2ind( size(g.facevxs), edges(e1,3), edges(e1,5) ));
                        normal1b = tnormal(1+normal1bindex,:);
                        normal2aindex = tfacevxnormal(sub2ind( size(g.facevxs), edges(e2,3), edges(e2,4) ));
                        normal2a = tnormal(1+normal2aindex,:);
                        normal2bindex = tfacevxnormal(sub2ind( size(g.facevxs), edges(e2,3), edges(e2,5) ));
                        normal2b = tnormal(1+normal2bindex,:);
                        samenormals = all(normal1a==normal2a,2) & all(normal1b==normal2b,2);
                        flatedges = repeatedEdges;
                        flatedges(repeatedEdges) = samenormals;
                        selectedEdges = ~([flatedges;false] | [false;repeatedEdges]);
                    else
                        selectedEdges = [ true; repeatedEdges ];
                    end
        %             drawedges( [flatedges;false] | [false;repeatedEdges], : ) = [];
        %             edges( [false;repeatedEdges], : ) = [];

                    % EDGES is an N*5 array in which each row represents an edge
                    % of a face.  The columns are vertex 1, vertex 2, face,
                    % face-corner 1, face-corner 2.
                    % If we have vertex normals then we add those.  Otherwise we
                    % calculate and use the face normals.

                    if any(selectedEdges)
                        drawedges = edges( selectedEdges, : );
                        edgestartindexes = 1+g.facevxs(sub2ind( size(g.facevxs), drawedges(:,3), drawedges(:,4) ));
                        edgestarts = tvxs( edgestartindexes, : )';
                        edgeendindexes = 1+g.facevxs(sub2ind( size(g.facevxs), drawedges(:,3), drawedges(:,5) ));
                        edgeends = tvxs( edgeendindexes, : )';
                        numedges = size(edgestarts,2);
                        dividers = nan(1,numedges);
                        xdata = reshape( [ edgestarts(1,:); edgeends(1,:); dividers ], [], 1 );
                        ydata = reshape( [ edgestarts(2,:); edgeends(2,:); dividers ], [], 1 );
                        zdata = reshape( [ edgestarts(3,:); edgeends(3,:); dividers ], [], 1 );
                        htop(2) = line( 'Parent', ax, 'XData', xdata, 'YData', ydata, 'ZData', zdata, 'Color', 'k' );
                    end

                    if havenormals
                        selectedEdges = [flatedges;false];
                        if any(selectedEdges)
                            drawedges = edges( selectedEdges, : );
                            edgestartindexes = 1+g.facevxs(sub2ind( size(tfacevxnormal), drawedges(:,3), drawedges(:,4) ));
                            edgestarts = tvxs( edgestartindexes, : )';
                            edgeendindexes = 1+g.facevxs(sub2ind( size(tfacevxnormal), drawedges(:,3), drawedges(:,5) ));
                            edgeends = tvxs( edgeendindexes, : )';
                            numedges = size(edgestarts,2);
                            dividers = nan(1,numedges);
                            xdata2 = reshape( [ edgestarts(1,:); edgeends(1,:); dividers ], [], 1 );
                            ydata2 = reshape( [ edgestarts(2,:); edgeends(2,:); dividers ], [], 1 );
                            zdata2 = reshape( [ edgestarts(3,:); edgeends(3,:); dividers ], [], 1 );
                            htop(3) = line( 'Parent', ax, 'XData', xdata2, 'YData', ydata2, 'ZData', zdata2, 'Color', 'k' );
                        end
                    end
                end
                
                hh = [ htop hh ];
            end
        end
        
        function uniquefy( g )
            unmarkall( g );
            uniquefy1( g );
            unmarkall( g );
        end
        
        function [selectors,reindexers] = uniquefy1( g )
            % Remove duplicate vertexes, uvs, normals, colors, and alpha
            % values. Note that duplicate materials are not removed.
            selectors = [];
            reindexers = [];
            
            if g.mark
                return;
            end
            g.mark = true;
            
            % These are all the fields of g that contain data that other
            % fields of g index into.
            valuefields = { 'vxs' 'uv' 'color' 'alpha' 'normal' 'material' };
            
            % These are the prefixes of the other fields of g that are
            % indexed by vertex or face. Each of these followed by a value
            % field makes a possible field of g, but not all combinations
            % exist.
            domains = { 'vx', 'face', 'facevx' };
            
            selectors = struct();
            revaluers = struct();
            % Remove duplicates from uv, color, alpha, normal, and
            % material.
            for i=2:length(valuefields)
                vf = valuefields{i};
                [g.(vf),selectors.(vf),revaluers.(vf)] = unique( g.(vf), 'rows', 'stable' );
                revaluers.(vf) = [ 0; revaluers.(vf) ];
            end
            
            % Revalue all arrays that contain indexes into uv, color,
            % alpha, normal, or material.
            for i=2:length(valuefields)
                vf = valuefields{i};
                for j=1:length(domains)
                    df = [ domains{j} vf ];
                    if isprop( g, df ) && ~isempty( g.(df) )
                        g.(df) = reshape( revaluers.(vf)( g.(df)+2 ) - 1, size( g.(df) ) );
                    end
                end
            end
            
%             for i=2:length(valuefields)
%                 vf = valuefields{i};
%                 df = ['vx' vf];
%                 if isprop( g, df ) && ~isempty( g.(df) )
%                     g.(df) = g.(df)(selectors.(vf),:);
%                 end
%             end
            
%             [g.facevxs,selectors.facevxs,revaluers.facevxs] = unique( g.facevxs, 'rows', 'stable' );
            
            vxdata = zeros( size(g.vxs,1), 9, 'int32' );  % 9 is the maximum number of integer data values per vertex,
                                                          % but it does not matter if the number here is not accurate.
            vxj = 0;
            for i=2:length(valuefields)
                vf = valuefields{i};
                df = ['vx' vf];
                if isprop( g, df ) && ~isempty( g.(df) )
                    vxj1 = vxj + size(g.(df),2);
                    vxdata( :, (vxj+1):(vxj+vxj1) ) = g.(df);
                    vxj = vxj1;
                end
            end
            vxdata(:, (vxj+1):end ) = [];
            vxdata = [ g.vxs, double( vxdata ) ];
            [~,selectors.vxs,revaluers.vxs] = unique( vxdata, 'rows', 'stable' );
            revaluers.vxs = [ 0; revaluers.vxs ];
            
            g.vxs = g.vxs( selectors.vxs, : );
            for i=2:length(valuefields)
                vf = valuefields{i};
                df = [ 'vx' vf ];
                if isprop( g, df ) && ~isempty( g.(df) )
                    g.(df) = g.(df)( selectors.vxs, : );
                end
            end
            g.facevxs = reshape( revaluers.vxs( g.facevxs+2 ) - 1, size( g.facevxs ) );
            fdata = zeros( size(g.facevxs,1), 9, 'int32' );
            fj = 0;
            for i=1:length(valuefields)
                vf = valuefields{i};
                for j=2:length(domains)
                    df = [ domains{j} vf ];
                    if isprop( g, df ) && ~isempty( g.(df) )
                        fj1 = fj + size(g.(df),2);
                        fdata( :, (fj+1):(fj+fj1) ) = g.(df);
                        fj = fj1;
                    end
                end
            end
            fdata(:, (fj+1):end ) = [];
            [~,selectors.faces,revaluers.faces] = unique( fdata, 'rows', 'stable' );
            g.facevxs = g.facevxs( selectors.faces, : );
            
            for i=1:length(g.children)
                uniquefy1( g.children(i) );
            end
        end
        
        function [maps,reindexers] = removeUnused( g )
            unmarkall( g );
            [maps,reindexers] = removeUnused1( g );
            unmarkall( g );
        end
        
        function [maps,revaluers] = removeUnused1( g )
            % Remove from g all data that is unreferenced by any face.
            
            maps = [];
            revaluers =[];
            
            if g.mark
                return;
            end
            g.mark = true;
            
            % These are all the fields of g that contain data that other
            % fields of g index into.
            valuefields = { 'vxs' 'uv' 'color' 'alpha' 'normal' 'material' };
            
            % These are the prefixes of the other fields of g that are
            % indexed by vertex or face. Each of these followed by a value
            % field makes a possible field of g, but not all combinations
            % exist.
            domains = { 'vx', 'face', 'facevx' };
            
            % Generate the boolean maps and reindexing functions.
            for i=1:length(valuefields)
                vf = valuefields{i};
                maps.(vf) = false( size(g.(vf),1), 1 );
                for j=1:length(domains)
                    df = [ domains{j} vf ];
                    if isprop( g, df ) && ~isempty( g.(df) )
                        if (j==1) && (i>1)
                            map = g.(df)(maps.vxs)+1;
                        else
                            map = g.(df)(:)+1;
                        end
                        maps.(vf)(map(map>0)) = true;
                    end
                end
                revaluers.(vf) = zeros(size(maps.(vf)),'int32');
                revaluers.(vf)(maps.(vf)) = int32(1:sum(maps.(vf)))';
                revaluers.(vf) = [int32(0); revaluers.(vf)];
            end
            
            % Eliminate the unused data.
            for i=1:length(valuefields)
                vf = valuefields{i};
                g.(vf) = g.(vf)(maps.(vf),:);
            end
            
            % For every array indexed by vertex, eliminate the data for
            % unused vertexes.
            for i=2:length(valuefields)
                vf = valuefields{i};
                df = ['vx' vf];
                if isprop( g, df ) && ~isempty( g.(df) )
                    g.(df) = g.(df)(maps.(vf),:);
                end
            end
            
            % Reindex every array whose values are indexes into other
            % arrays, to index the new versions of those other arrays.
            for i=1:length(valuefields)
                vf = valuefields{i};
                for j=1:length(domains)
                    df = [ domains{j} vf ];
                    if isprop( g, df ) && ~isempty( g.(df) )
                        g.(df) = reshape( revaluers.(vf)( g.(df)+2 ) - 1, size(g.(df)) );
                    end
                end
            end
            
            % Apply recursively.
            for i=1:length(g.children)
                removeUnused1( g.children(i) );
            end
        end
        
        function renumbervxs = elideVertexPairs( g, vxpairs )
            if isempty(vxpairs)
                renumbervxs = (0:size(g.vxs,1)-1)';
                return;
            end
            gr = graph(vxpairs(:,1)+1,vxpairs(:,2)+1);
            renumbervxs = conncomp(gr) - 1;
            maxrenvxs = max( renumbervxs );
            numunassignedvxs = size(g.vxs,1) - length(renumbervxs);
            renumbervxs( (end+1):(end+numunassignedvxs) ) = (maxrenvxs+1):(maxrenvxs+numunassignedvxs);
%             usedvxs = false( size(g.vxs,1), 1 );
%             usedvxs(renumbervxs+1) = true;
            [~,usedvxs,~] = unique( renumbervxs, 'stable' );
            g.vxs = g.vxs(usedvxs,:);
            if ~isempty( g.vxuv )
                g.vxuv = g.vxuv(usedvxs,:);
            end
            if ~isempty( g.vxnormal )
                g.vxnormal = g.vxnormal(usedvxs,:);
            end
            if ~isempty( g.vxcolor )
                g.vxcolor = g.vxcolor(usedvxs,:);
            end
            if ~isempty( g.vxalpha )
                g.vxalpha = g.vxalpha(usedvxs,:);
            end
            g.facevxs = renumbervxs( g.facevxs+1 );
            % Deal with faces that have had some of their vertexes merged,
            % and faces that have been merged together.
            [~,retainedfaces,~] = unique( sort( g.facevxs, 2 ), 'rows', 'stable' );
            g.facevxs = g.facevxs(retainedfaces,:);
            if ~isempty( g.facevxuv )
                g.facevxuv = g.facevxuv(retainedfaces,:);
            end
            if ~isempty( g.facenormal )
                g.facenormal = g.facenormal(retainedfaces,:);
            end
            if ~isempty( g.facevxnormal )
                g.facevxnormal = g.facevxnormal(retainedfaces,:);
            end
            if ~isempty( g.facecolor )
                g.facecolor = g.facecolor(retainedfaces,:);
            end
            if ~isempty( g.facevxcolor )
                g.facevxcolor = g.facevxcolor(retainedfaces,:);
            end
            if ~isempty( g.facealpha )
                g.facealpha = g.facealpha(retainedfaces,:);
            end
            if ~isempty( g.facevxalpha )
                g.facevxalpha = g.facevxalpha(retainedfaces,:);
            end
        end
        
        function e = isEmptyGeometry( g )
            e = isempty( g.facevxs );
        end
        
        function uniqueids( g )
            gd = unique( [ g, allDescendants( g ) ] );
            ids = { gd.id };
            [idu,~,ic] = unique( ids );
            if length(idu)==length(ids)
                return;
            end
            numused = zeros(1,length(idu));
            for i=1:length(gd)
                count = numused(ic(i));
                if count > 0
                    gd(i).id = sprintf( '%s.%03d', idu{ic(i)}, count );
                end
                numused(ic(i)) = count+1;
            end
        end
        
        function unshare( g )
            % Remove all sharing from g.
            % This must be called on the root Geometry object.
            unmarkall( g );
            unshare1( g );
            unmarkall( g );
            
            function g1 = unshare1( g )
                if ismarked(g)
                    g1 = g.copy();
                else
                    setmark(g);
                    g1 = g;
                end
                for i=1:length(g.children)
                    g.children(i) = unshare1( g.children(i) );
                end
            end
        end
        
        function applyTransformsUnshared( g )
            % Applies all transformations in g, assuming that g contains
            % no sharing.  It does this by applying transformations in
            % place everywhere.
            %
            % If g does contain sharing, this will go wrong.  Do not use it
            % on any Geometry object not known to contain no sharing.
            
            applyTransformsUnshared1( g, eye(4) );
            
            function applyTransformsUnshared1( g, transform )
                shallowTransform( g, transform );
                for i=1:length(g.children)
                    applyTransformsUnshared1( g.children(i), g.childtransforms(:,:,i) * transform );
                end
                g.childtransforms = repmat( eye(4), 1, 1, length(g.children) );
            end
        end
        
        function applyTransforms( g )
            % Like unshare, but also applies transformations as it goes.
            % The presence of transformations forces this to do more
            % copying than unshare.
            
            g1 = applyTransforms1( g, eye(4) );
            g.copyFrom( g1 );
            
            function g1 = applyTransforms1( g, transform )
                g1 = g.copy();
                g1.vxs = transformPoints( g1.vxs, transform );
                g1.normal = rotatePoints( g1.normal, transform );
                if isReflectionTransform( transform )
                    % We must reverse the face vertex ordering.
                    g1.facevxs = g1.facevxs(:,end:-1:1);
                    g1.facevxuv = g1.facevxuv(:,end:-1:1);
                    g1.facevxnormal = g1.facevxnormal(:,end:-1:1);
                end
                for i=1:length(g.children)
                    g1.children(i) = applyTransforms1( g.children(i), g.childtransforms(:,:,i) * transform );
                    g1.childtransforms(:,:,i) = eye(4);
                end
                g1.childtransforms = repmat( eye(4), 1, 1, length(g.children) );
            end
        end
        
        function XapplyTransforms( g, t )
        %applyTransforms( g )
        %   Apply all transforms in g to its points, replacing the
        %   transforms by the identity.  This requires eliminating all
        %   sharing from g.
            
            if nargin < 2
                t = eye(4);
                unshare(g);
            end
            g.vxs = transformPoints( g.vxs, t );
            for i=1:length(g.children)
                applyTransforms( g.children(i), composeTransforms( getChildTransform( g, i ), t ) );
            end
            g.childtransforms = repmat( eye(4), 1, 1, length(g.children) );
        end
        
        function flatten( g )
        %flatten( g )
        %   If g has no children, do nothing.
        %   Otherwise, unshare g, apply all transformations, make an array of g
        %   and all its descendants, with their own children arrays made
        %   empty.  Replace g with an object having empty geometry and
        %   those children, unless there is just one non-empty geometry, in
        %   which case make g equal to it.
        
            if isempty(g.children)
                return;
            end
            
            unshare( g );
            applyTransformsUnshared( g )
%             applyTransforms( g );
            gd = allDescendants( g );
            empties = false( 1, length(gd) );
            for i=1:length(gd)
                gd(i).children = Geometry.empty();
                gd(i).childtransforms = zeros(4,4,0);
                empties(i) = isEmptyGeometry( gd(i) );
            end
            delete( gd(empties) );
            gd = gd(~empties);
            if isempty(gd)
                g.children = Geometry.empty();
            elseif isEmptyGeometry(g)
                if length(gd)==1
                    copyFrom( g, gd );
                    delete( gd );
                    g.children = Geometry.empty();
                else
                    g.children = gd;
                end
            else
                g1 = g.copy;
                g.children = [ g1, gd ];
                clearGeometry(g);
            end
            g.childtransforms = repmat( eye(4), 1, 1, length(g.children) );
        end
        
        function [gd,gp] = allDescendants( g )
            %[gd,gp] = allDescendants( g )
            %   Return an array of all the descendants of g, not including
            %   g.
            %   They are listed in breadth-first order, but that should not
            %   be relied on.
            %   The second output is a list of the corresponding parents.
            
            if isempty(g.children)
                gd = Geometry.empty();
                gp = Geometry.empty();
            else
                nd = numitems(g)-1;
                gd(nd) = Geometry();
                gp(nd) = Geometry();
                nc = length(g.children);
                k = nc;
                for i=1:nc
                    [gds1,gps1] = allDescendants(g.children(i));
                    nd1 = length(gds1);
                    gd( (k+1):(k+nd1) ) = gds1;
                    gp( (k+1):(k+nd1) ) = gps1;
                    k = k + nd1;
                end
                gd(1:nc) = g.children;
                gp(1:nc) = repmat(g,1,nc);
            end
        end
        
        function n = numitems( g )
            n = 1;
            for i=1:length(g.children)
                n = n+numitems(g.children(i));
            end
        end
        
        function m = ismarked(g)
            m = g.mark;
        end
        
        function setmark(g)
            g.mark = true;
        end
        
        function unmark(g)
            g.mark = false;
        end
        
        function unmarkall(g)
            g.mark = false;
            for i=1:length(g.children)
                unmark( g.children(i) );
            end
        end
        
        function t = getChildTransform( g, i )
            if i > size(g.childtransforms,3)
                t = eye(4);
            else
                t = g.childtransforms(:,:,i);
                if isempty(t)
                    t = eye(4);
                end
            end
        end
        
        function triangulate( g, deep )
            % Incomplete: needs function triarray().
            if nargin < 2
                deep = true;
            end
            % Split all quads and ngons into triangles.
            if ~isempty(g.facevxs)
                numfacevxs = size( g.facevxs, 2 ) - sum( g.facevxs==-1, 2 );
                vxsperface = unique(numfacevxs);
                maps = cell( 1, length(vxsperface) );
                for i=1:length(vxsperface)
                    maps{i} = numfacevxs==vxsperface(i);
                end
                numsizes = length(vxsperface);
                trifacevxs = cell(numsizes,1);
                if ~isempty(g.facevxuv)
                    trifacevxuv = cell(numsizes,1);
                end
                if ~isempty(g.facevxnormal)
                    trifacevxnormal = cell(numsizes,1);
                end
                renumberfaces = cell(numsizes,1);
                for i=1:numsizes
                    nvxs = vxsperface(i);
                    trifacevxs{i} = triarray( g.facevxs(maps{i},1:nvxs) );
                    if ~isempty(g.facevxuv)
                        trifacevxuv{i} = triarray( g.facevxuv(maps{i},1:nvxs) );
                    end
                    if ~isempty(g.facevxnormal)
                        trifacevxnormal{i} = triarray( g.facevxnormal(maps{i},1:nvxs) );
                    end
                    if ~isempty(g.facemat)
                        renumberfaces{i} = reshape( repmat( g.facemat(maps{i})', nvxs-2, 1 ), [], 1 );
                    end
                end
                g.facevxs = cell2mat( trifacevxs );
                if ~isempty(g.facevxuv)
                    g.facevxuv = cell2mat( trifacevxuv );
                end
                if ~isempty(g.facevxnormal)
                    g.facevxnormal = cell2mat( trifacevxnormal );
                end
                if ~isempty(g.facemat)
                    g.facemat = cell2mat( renumberfaces );
                end
            end
            
            if deep
                for i=1:length(g.children)
                    g.children(i).triangulate( false );
                end
            end
        end
        
        function mergeSubtree( g )
            % Merge everything in the subtree rooted at g into g.  This
            % will do the same to every node below g.  Other references to
            % those nodes will see that merging.
            
            % Merge each child.
            empty = false(1,length(g.children));
            for i=1:length(g.children)
                mergeSubtree( g.children(i) );
                empty(i) = isEmptyGeometry( g.children(i) );
            end
            
            % Eliminate empty children.
            g.children = g.children(~empty);
            
            % Nothing to do if nothing left to merge.
            if isempty( g.children )
                return;
            end
            
            % Add g itself to the list.
            if isEmptyGeometry(g)
                geometries = g.children;
            else
                geometries = [g g.children];
            end
            
            % Count the arrays.
            numgeoms = length(geometries);
            vxsperchild = zeros(1,numgeoms);
            uvperchild = zeros(1,numgeoms);
            normperchild = zeros(1,numgeoms);
            matperchild = zeros(1,numgeoms);
            facesperchild = zeros(1,numgeoms);
            facevxuvperchild = zeros(1,numgeoms);
            facevxnormalperchild = zeros(1,numgeoms);
            facematperchild = zeros(1,numgeoms);
            for i=1:numgeoms
                vxsperchild(i) = size( geometries(i).vxs, 1 );
                uvperchild(i) = size( geometries(i).uv, 1 );
                normperchild(i) = size( geometries(i).normal, 1 );
                matperchild(i) = length( geometries(i).material );
                facesperchild(i) = size( geometries(i).facevxs, 1 );
                facevxuvperchild(i) = size( geometries(i).facevxuv, 1 );
                facevxnormalperchild(i) = size( geometries(i).facevxnormal, 1 );
                facematperchild(i) = length( geometries(i).facemat );
            end
            
            % If some geometries have uvs and some do not, we must invent
            % uvs.
            if any(facevxuvperchild>0) && any(facevxuvperchild==0)
                missing = facevxuvperchild==0;
                for i=find(missing)
                    geometries(i).uv = [ 0 0; geometries(i).uv ];
                    geometries(i).facevxuv = zeros( size(g.facevxs) );
                    geometries(i).facevxuv( isnan( g.facevxg.facevxs) ) = NaN;
                    uvperchild(i) = size( geometries(i).uv, 1 );
                    facevxuvperchild(i) = size( geometries(i).facevxuv, 1 );
                end
            end
            
            % If some geometries have normals and some do not, we must invent
            % normals.
            if any(facevxnormalperchild>0) && any(facevxnormalperchild==0)
                missing = facevxnormalperchild==0;
                for i=find(missing)
                    geometries(i).normal = [ 0 0; geometries(i).normal ];
                    geometries(i).facevxnormal = zeros( size(g.facevxs) );
                    geometries(i).facevxnormal( isnan( g.facevxg.facevxs) ) = NaN;
                    normperchild(i) = size( geometries(i).normal, 1 );
                    facevxnormalperchild(i) = size( geometries(i).facevxnormal, 1 );
                end
            end
            
            % If some geometries have materials and some do not, we must invent
            % materials.  We set all unassigned materials to -1.  Later,
            % these will be reassigned to zero.
            if any(matperchild>0) && any(matperchild==0)
                missing = matperchild==0;
                for i=find(missing)
                    geometries(i).facemat = -ones( size(g.facevxs), 1 );
                end
            end
            
            allvxs = vertConcat( { geometries.vxs }' );
            alluv = vertConcat( { geometries.uv }' );
            allnorm = vertConcat( { geometries.normal }' );
            matoffsets = [ 0 cumsum( matperchild ) ];
            totmats = matoffsets(end);
            allmat(totmats) = Material();
            for i=1:numgeoms
                allmat( (matoffsets(i)+1):matoffsets(i+1) ) = geometries(i).material;
            end
            [allmat,~,renumbermat] = unique(allmat);
            allmat = allmat(:);
            allfacevxs = vertConcat( { geometries.facevxs }' );
            allfacevxuv = vertConcat( { geometries.facevxuv }' );
            allfacevxnormal = vertConcat( { geometries.facevxnormal }' );
            allfacemat = vertConcat( { geometries.facemat }' );
            faceoffsets = [ 0 cumsum( facesperchild ) ];
            vxoffsets = [ 0 cumsum( vxsperchild ) ];
            uvoffsets = [ 0 cumsum( uvperchild ) ];
            normoffsets = [ 0 cumsum( normperchild ) ];
            haveuv = ~isempty(alluv);
            havenorm = ~isempty(allnorm);
            for i=1:length(geometries)
                facerange = (faceoffsets(i)+1):faceoffsets(i+1);
                allfacevxs( facerange, : ) = allfacevxs( facerange, : ) + vxoffsets(i);
                if haveuv
                    allfacevxuv( facerange, : ) = allfacevxuv( facerange, : ) + uvoffsets(i);
                end
                if havenorm
                    allfacevxnormal( facerange, : ) = allfacevxnormal( facerange, : ) + normoffsets(i);
                end
                allfacemat( facerange ) = allfacemat( facerange ) + matoffsets(i);
            end
            allfacemat(allfacemat==-1) = 1;
            allfacemat = renumbermat( allfacemat+1 ) - 1;  % +1 and -1 for zero-indexing.
            
            g.vxs = allvxs;
            g.uv = alluv;
            g.normal = allnorm;
            g.material = allmat;
            g.facevxs = allfacevxs;
            g.facevxuv = allfacevxuv;
            g.facevxnormal = allfacevxnormal;
            g.facemat = allfacemat;
            g.children = [];
            g.childtransforms = zeros(4,4,0);
        end
        
        function ok = writeobj( g, file, includeuv, includenorm, transform, ~ ) % Final arg is vxoffset, not currently used.
            if nargin < 3
                includeuv = true;
            end
            if nargin < 4
                includenorm = true;
            end
            if nargin < 5
                transform = eye(4);
            end
%             if nargin < 6
%                 vxoffset = 0;
%             end
            ok = true;
            if ischar(file)
                fid = fopen( file, 'w' );
            else
                fid = file;
            end
            if fid==-1
                ok = false;
                return;
            end
            [~,~,~] = writeobj1( g, fid, transform, 0, 0, 0 );
            
            function [nvxs,nuv,nnorm] = writeobj1( g, fid, transform, nvxs, nuv, nnorm )
                if ~isempty(g.id)
                    fprintf( fid, 'o %s\n', g.id );
                end
                writeObjArray( fid, 'v', g.vxs );
                vertexinfo = { g.facevxs+1+nvxs };
                if includeuv
                    writeObjArray( fid, 'vt', g.uv );
                    vertexinfo{2} = g.facevxuv+1+nuv;
                end
                if includenorm
                    writeObjArray( fid, 'vn', g.normal );
                    vertexinfo{3} = g.facevxnormal+1+nnorm;
                end
                writeObjRaggedInterleavedArrays( fid, 'f', vertexinfo{:} );

                fprintf( fid, '\n' );
                nvxs = nvxs + size( g.vxs,1 );
                nuv = nuv + size( g.uv,1 );
                nnorm = nnorm + size( g.normal,1 );
                for i=1:length(g.children)
                    [nvxs,nuv,nnorm] = writeobj1( g.children(i), fid, g.childtransforms(:,:,i)*transform, nvxs, nuv, nnorm );
                end
            end
        end
    end

end
