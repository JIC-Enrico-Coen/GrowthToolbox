function factors = FindCellRole( m, cellroles )
%factors = FindCellRole( m, cellroles )
%   Given a set of cell factor roles (as names or indexes), find the cell
%   factors that have those roles.  The indexes of the factors are
%   returned, or zero where no factor has been assigned to a role.

    [~,factors] = name2Index( m.secondlayer.cellfactorroles, cellroles );
end
