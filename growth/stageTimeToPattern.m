function p = stageTimeToPattern( t )
%p = stageStringToPattern( s )
%   Given the timestamp of a stage file as a real (e.g. -1.5),
%   create a regular expression which will match any equivalent timestamp,
%   by allowing any number of leading and trailing zeroes
%   (e.g. 'm0*1d5(0*)').
%
%   See also: stageStringToPattern

    p = stageStringToPattern( stageTimeToText( t ) );
end
