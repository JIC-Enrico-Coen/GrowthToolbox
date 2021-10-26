function p = stageStringToPattern( s )
%p = stageStringToPattern( s )
%   Given the timestamp of a stage file as a string (e.g. 'm001d500'),
%   create a regular expression which will match any equivalent timestamp,
%   by allowing any number of leading and trailing zeroes
%   (e.g. 'm0*1d5(0*)').
%
%   See also: stageTimeToPattern

    if isempty( regexp(s,'[dD]','once') )
        p = regexprep( s, '^([mM])?0*([0-9]+)$', '$10*$2(d0*)?' );
    else
        p = regexprep( s, '^([mM])?([0-9]+([dD]([0-9]*[1-9])?)?)0*$', '$10*$20*' );
    end
end
