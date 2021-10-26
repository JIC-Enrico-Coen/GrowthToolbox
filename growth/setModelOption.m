function [m,index] = setModelOption( m, optionname, value )
%[m,index] = setModelOption( m, optionname, value )
%   Set the named model option of m to the given value. Return also the
%   index of the option.
%
%   SEE ALSO: setModelOptions, setUpModelOptions, addModelOptions, setOptions

    [m.modeloptions,index] = setOptionIndex( m.modeloptions, optionname, value );
end
