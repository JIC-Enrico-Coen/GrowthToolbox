function [cmap,pos] = readMorphographXColormap( filename )
%[cmap,pos] = readMorphographXColormap( filename )
%   Read a color map in the form exported from MorphographX.
%   CMAP will be an N*3 array of N RGB colors. POS will be an N*1 array of
%   the positions on a scale of 0 to 1 that the colors are to be mapped to.
%
%   If the file cannot be read the results are both empty.

    fid = fopen( filename, 'r' );
    if fid==-1
        timedFprintf( 'Cannot read file ''%s''\n', filename );
        cmap = [];
        return;
    end
    
    cmap = zeros(0,3);
    pos = zeros(0,1);
    
    prefix = 'ColoredPos: ';
    linenum = 0;
    
    while true
        linenum = linenum+1;
        ln = fgetl( fid );
        if ~ischar(ln)
            break;
        end
        if ~startsWith( ln, prefix )
            continue;
        end
        
        ln( 1:length(prefix) ) = [];
        tokens = split( ln, ',' );
        if length(tokens) ~= 4
            timedFprintf( 'Line %d: expected 4 tokens, found %d.\n', linenum, length(tokens) );
            break;
        end
        
        firstHyphen = find( tokens{1}=='-', 1 );
        if ~isempty( firstHyphen )
            postoken = tokens{1}(1:(firstHyphen-1));
            token1b = tokens{1}((firstHyphen+1):end);
            tokens = { token1b, tokens{2}, tokens{3} };
        end
        
        cmap(end+1,:) = string2num(tokens); %#ok<AGROW>
        pos(end+1,:) = string2num( postoken ); %#ok<AGROW>
    end
end