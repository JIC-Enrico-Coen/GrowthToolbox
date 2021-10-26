function s = getRSSSFromFile( fn, initvals )
%s = getRSSSFromFile( fn, initvals )
%   Read a dialog layout from a file, inserting the given initial values
%   into it.
%
%   See also:
%       buildRSSSdialogFromFile, performRSSSdialogFromFile, modelessRSSSdialogFromFile

    if nargin < 2
        initvals = [];
    end
    s = [];
    ts = opentokenstream( fn );
    if isempty(ts)
        return;
    end
    [ts,ended] = atend( ts );
    if ended
        return;
    end
    [ts,s,err] = parseRSSS( ts, initvals );
    if err
        s = [];
        return;
    end
end
