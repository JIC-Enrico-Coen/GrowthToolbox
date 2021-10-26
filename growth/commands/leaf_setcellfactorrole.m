function m = leaf_setcellfactorrole( m, varargin )
%m = leaf_setcellfactorrole( m, rolename, factor, ... )
%   Assign roles to cell factors.  The role names are strings, and the
%   factors can be either strings or factor indexes.  Pass 0 as the factor
%   to remove the role.
%
%   Currently supported roles are:
%       'CELL_AREA'  This displays the cell area.
%       'DIV_COMP'  Competence to divide.  If a factor is associated with
%           this role, a cell will not be split if this factor is below
%           0.5.
%       'DIV_AREA'  Minimal area to divide.  If a factor is associated with
%           this role, a cell will not be split if its area is less than
%           this factor.
%       'CELL_AGE'  This factor is automatically set to the age of the
%           cell.
%
%   Nonexistent roles will be ignored.  If a nonexistent factor is given,
%   it will be treated as if 0 has been given, i.e. the role is removed.

    if isempty(m), return; end
    if isempty(m.secondlayer)
        return;
    end
    
    roles = varargin(1:2:end);
    factors = FindCellValueIndex( m, varargin(2:2:end) );
    okfactors = factors ~= 0;
    roles = roles(okfactors);
    factors = factors(okfactors);
    
    % Remove any current binding of these roles.
    okroles = false(1,length(factors));
    for i=1:length(factors)
        m.secondlayer.cellfactorroles.index2Value(m.secondlayer.cellfactorroles.index2Value==factors(i)) = 0;
        okroles(i) = ~isempty( roles{i} );
    end
    roles = roles(okroles);
    factors = factors(okroles);
    
    % Set new binding of roles.
    m.secondlayer.cellfactorroles = setvaluesInIndex( m.secondlayer.cellfactorroles, roles, factors );
end
