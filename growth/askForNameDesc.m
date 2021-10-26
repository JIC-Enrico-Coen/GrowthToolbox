function [n,d] = askForNameDesc( n, d )
    if nargin < 1
        n = '';
    end
    if nargin < 2
        d = '';
    end
    [r,s] = performRSSSdialogFromFile( ...
                findGFtboxFile( 'guilayouts/saverunlayout.txt' ), ...
                struct( 'name', n, 'desc', d ), ...
                [], ...
                @setDefaultGUIColors ); % @(h)setGFtboxColourScheme( h, handles ));
    if isempty(r)
        n = [];
        d = [];
    else
        n = r.name;
        d = r.desc;
    end
end
