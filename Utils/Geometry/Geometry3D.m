classdef Geometry3D < matlab.mixin.Copyable

    properties
        vxs  % double N*3 matrix. N 3-ples of coordinates. Vertexes in 3D space. 
        vxsets  % int32 P*K matrix. P tuples of K vertex indexes. In principle a ragged array padded with zeroes.
        
        % Other fields we might need would be:
%         polytypes  % int16 P*1 array
%         polytypedata  % Perhaps static. This would list the faces and edges of the polyhedron of each type.
    end
    
    methods (Static)
        function g = union( gs )
            % Take the union of an array of Geometry3D objects.
            if isempty(gs)
                g = Geometry3D();
                return;
            end
            g = gs(1).copy();
            ng = numel(gs);
            for i=2:ng
                g.unionWith( gs(i) );
            end
        end
    end
    
    methods
        function [g,ok] = Geometry3D( varargin )
            if (nargin > 0) && isa(varargin{1},'Geometry3D')
                g = varargin{1}.copy;
            else
                clearGeometry3D( g );
            end
            % Set fields according to the arguments.
            initialiseClass( g, varargin{:} );
            ok = isValid( g );
        end
        
        function g = clearGeometry3D( g )
            % We cannot just create an empty Geometry3D object and copy it to
            % g, because this procedure is called from the creator
            % procedure.
            g.vxs = [];
            g.vxsets = int32([]);
        end
        
        function g = unionWith( g, g1 )
            % Append the vertexes and vertex sets of g1 to g.
            vv = g1.vxsets + size(g.vxs,1);
            vv(g1.vxsets==0) = 0;
            g.vxs = [ g.vxs; g1.vxs ];
            g.vxsets = [ g.vxsets; vv ];
        end
        
        function g = mergeNearVertexes( g, tol )
            [uvxs,~,ic] = uniqueRowsTol( g.vxs, tol );
            
            g.vxs = uvxs;
            g.vxsets( g.vxsets ~= 0 ) = ic( g.vxsets( g.vxsets ~= 0 ) );
            
            g.mergeIdenticalVxsets();
            g = deleteDegenerateVxsets( g );
        end
        
        function g = deleteDegenerateVxsets( g )
            % Every set of vertexes containing any represted vertex is
            % deleted.
            svxsets = sort( g.vxsets, 2 );
            reps = find( svxsets(:,1:(end-1)) == svxsets(:,2:end) );
            reps(svxsets(reps)==0) = [];
            [vxsi, vxi] = ind2sub( size(svxsets), reps );
            g.vxsets(vxsi,:) = [];
        end
        
        function g = mergeIdenticalVxsets( g )
            vv = sort( g.vxsets, 2 );
            [~,ia,~] = unique( vv, 'rows', 'stable' );
            g.vxsets = g.vxsets( ia,: );
        end
        
        function rotate( g, rotmat, rotcentre )
            if nargin < 3
                g.vxs = g.vxs * rotmat;
            else
                g.vxs = (g.vxs - rotcentre) * rotmat + rotcentre;
            end
        end
        
        function g = translate( g, v )
            g.vxs = g.vxs + v;
        end
        
        function c = centre( g )
            c = mean( g.vxs, 1 );
        end
        
        function b = bbox( g )
            b = [ min(g.vxs); max(g.vxs) ];
        end
        
        function c = centreBbox( g )
            b = bbox( g );
            c = mean(b,1);
        end
        
        function isequal = equalToTol( g, g1, tol )
            if nargin < 3
                tol = 0;
            end
            isequal = (length(size(g.vxs))==length(size(g1.vxs))) ...
                      && all(size(g.vxs)==size(g1.vxs)) ...
                      && (length(size(g.vxsets))==length(size(g1.vxsets))) ...
                      && all(size(g.vxsets)==size(g1.vxsets)) ...
                      && all( g.vxsets(:) == g1.vxsets(:) ) && (max( abs( g.vxs(:)-g1.vxs(:) ) ) <= tol);
        end
        
        function ok = isValid( g, warnlevel ) %#ok<INUSD>
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
                warnlevel = 0; %#ok<NASGU>
            end
            ok = true;
            ok = checkarraysize( g.vxs, [-1 3], isempty(g.vxsets), 'Invalid Geometry3D.vxs' ) && ok;
            ok = checkIndexingInto( g.vxsets, g.vxs, false, false, true, 'Invalid Geometry3D.vxsets' ) && ok;
            ok = validRaggedArray( g.vxsets, 'Invalid Geometry3D.vxsets' ) && ok;
        end
            
    end
end