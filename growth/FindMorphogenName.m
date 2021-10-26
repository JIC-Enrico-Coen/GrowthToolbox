function mgenname = FindMorphogenName( m, mgen, message )
% Convert any set of morphogens to names.
% mgen can be any of:
%   a single morphogen index
%   an array of morphogen indexes
%   a string
%   a cell array of strings.
% The result is always a cell array of strings.
% Morphogen indexes that are out of range are ignored.
% Morphogen names are checked for validity, and invalid ones ignored.

    if isempty( mgen )
        mgenname = {};
    elseif iscell( mgen )
        mgenname = upper(mgen);
    elseif ischar( mgen )
        mgenname = { upper(mgen) };
    else
        nummgens = length( m.mgenIndexToName );
        mgenname = m.mgenIndexToName(mgen((mgen > 0) & (mgen <= nummgens)));
    end
    mgenname = mgenname( isfield( m.mgenNameToIndex, mgenname ) );
end