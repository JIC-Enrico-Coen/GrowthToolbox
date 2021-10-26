classdef FiniteElementSet
    % A FiniteElementSet is a set of finite elements, all of the same type.
    % We use a set rather than a single element, in order to allow
    % vectorisation of computations over such a set, which would not be
    % possible if a set was represented as a struct array of single finite
    % elements.
    
    properties
        fetype = '';
        vxindexes = [];
        % VXINDEXES will be an NxK array of vertex indexes, which will index
        % an array of vertex coordinates.  Since Matlab does not have
        % references, the vertex coordinate array cannot be part of this
        % class, since in general there may be several FiniteElementSets
        % using the same vertex coordinate array.  Therefore the vertex
        % coordinate array must be passed as a parameter to whichever
        % member functions need it.
    end
    
    methods (Static)
        function fe = newFE( type, vxis )
            global FiniteElementDatabase;
            if isfield( FiniteElementDatabase, type )
                fe = FiniteElementSet();
                fe.fetype = type;
                fe.vxindexes = vxis;
            else
                fe = [];
            end
        end
    end
    
    methods
        function ev = iso2euc( fe, iv, vxcoords )
            % Calculate the position in Euclidean coordinates of a point
            % specified in isoparametric coordinates.
            
            global FiniteElementDatabase;
            fetypestruct = FiniteElementDatabase.(fe.fetype);
            ev = [0 0 0];
            for i=1:length(fetypestruct.shapeFunctions)
                ev = ev + ...
                     fetypestruct.shapeFunctions(i).fulleval( {'X','Y','Z'}, iv ) ...
                     * vxcoords( fe.vxindexes(i), : );
            end
        end
    end
end
