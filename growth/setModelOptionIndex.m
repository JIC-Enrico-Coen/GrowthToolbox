function [m,index] = setModelOptionIndex( m, optionname, value )
%[m,index] = setModelOptionIndex( m, optionname, value )
%   DEPRECATED. Use setModelOption.

    [m,index] = setModelOption( m, optionname, value );
end
